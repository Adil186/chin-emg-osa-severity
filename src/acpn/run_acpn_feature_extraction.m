function outputTable = run_acpn_feature_extraction(cfg)
%RUN_ACPN_FEATURE_EXTRACTION Manifest-driven ACPN feature extraction.
%
% Required manifest columns: SubjectID, Severity, EDFFile.
% Optional column: ExpectedEvents.

arguments
    cfg struct = example_config()
end
rng(cfg.seed);
manifest = readtable(cfg.acpn.manifestFile,'TextType','string');
required = ["SubjectID","Severity","EDFFile"];
if ~all(ismember(required,string(manifest.Properties.VariableNames)))
    error('ACPN manifest must contain SubjectID, Severity, and EDFFile.');
end
if ~isfolder(cfg.outputDir), mkdir(cfg.outputDir); end

parts = cell(height(manifest),1);
for s = 1:height(manifest)
    subjectID = manifest.SubjectID(s);
    severity = manifest.Severity(s);
    fprintf('ACPN subject %s (%s)\n',subjectID,severity);
    signals = load_acpn_signals_from_edf(manifest.EDFFile(s),cfg);
    expected = NaN;
    if ismember('ExpectedEvents',manifest.Properties.VariableNames)
        expected = manifest.ExpectedEvents(s);
    end
    events = detect_apnea(signals.airflow,signals.fs, ...
        shortestDurationSec=cfg.apnea.shortestDurationSec, ...
        longestDurationSec=cfg.apnea.longestDurationSec, ...
        expectedEvents=expected, ...
        initialThreshold=cfg.apnea.initialThreshold, ...
        thresholdStep=cfg.apnea.thresholdStep, ...
        maxIterations=cfg.apnea.maxIterations);
    epochs = build_emg_epochs(signals.emg,events.start,events.end);
    rows = table;
    for k = 1:numel(epochs.event)
        fullEvent = [epochs.pre{k};epochs.event{k};epochs.post{k}];
        segmentList = {fullEvent,epochs.normal{k}};
        typeList = ["Event","NonEvent"];
        for j = 1:2
            segment = segmentList{j};
            if numel(segment)<2*signals.fs, continue; end
            try
                [features,diag] = decompose_and_extract_mu_features(segment,signals.fs,cfg);
            catch ME
                warning('Subject %s segment %d (%s) skipped: %s',subjectID,k,typeList(j),ME.message);
                continue;
            end
            nMU=height(features);
            if nMU==0, continue; end
            metadata=table(repmat(subjectID,nMU,1),repmat(severity,nMU,1), ...
                repmat(typeList(j),nMU,1),repmat(k,nMU,1), ...
                repmat(diag.nRawSources,nMU,1),repmat(diag.nRetainedSources,nMU,1), ...
                'VariableNames',{'Subject','Severity','SegmentType','SegmentIndex','RawSources','RetainedSources'});
            rows=[rows;metadata features]; %#ok<AGROW>
        end
    end
    parts{s}=rows;
end
nonempty=~cellfun(@isempty,parts);
if any(nonempty)
    outputTable=vertcat(parts{nonempty});
else
    def=canonical_feature_definition();
    outputTable=array2table(zeros(0,41),'VariableNames',cellstr(def.Name));
end
outFile=fullfile(cfg.outputDir,'ACPN_MU_features.csv');
writetable(outputTable,outFile);
fprintf('Saved %d MU rows to %s\n',height(outputTable),outFile);
end
