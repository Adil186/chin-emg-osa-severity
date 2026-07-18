function outputTable = run_ucddb_feature_extraction(cfg)
%RUN_UCDDB_FEATURE_EXTRACTION Harmonized UCDDB extraction, one row per MU.

arguments
    cfg struct = example_config()
end
rng(cfg.seed);
manifest=readtable(cfg.ucddb.manifestFile,'TextType','string');
required=["SubjectID","Severity","EDFFile","EventFile"];
if ~all(ismember(required,string(manifest.Properties.VariableNames)))
    error('UCDDB manifest must contain SubjectID, Severity, EDFFile, and EventFile.');
end
if ~isfolder(cfg.outputDir),mkdir(cfg.outputDir);end
parts=cell(height(manifest),1);
for s=1:height(manifest)
    [emg,originalFs,label]=read_edf_channel(manifest.EDFFile(s),cfg.ucddb.emgAliases);
    targetFs=cfg.preprocessing.targetFs;
    if originalFs/2 < cfg.preprocessing.bandpassHz(2)
        warning('UCDDB:NyquistLimit', ...
            ['%s was acquired at %.3g Hz (Nyquist %.3g Hz). Resampling to %.3g Hz ', ...
             'standardizes downstream implementation but cannot recover content above %.3g Hz.'], ...
            manifest.SubjectID(s),originalFs,originalFs/2,targetFs,originalFs/2);
    end
    emg=resample_signal(emg,originalFs,targetFs,"polyphase");
    emg=apply_chin_emg_filter(emg,targetFs,cfg);
    events=read_ucddb_events(manifest.EventFile(s),cfg);
    rows=table;
    epochSamples=round(cfg.ucddb.epochDurationSec*targetFs);
    half=floor(epochSamples/2);
    for e=1:height(events)
        center=round(events.TimeSec(e)*targetFs)+1;
        idx=(center-half):(center-half+epochSamples-1);
        idx=idx(idx>=1 & idx<=numel(emg));
        if numel(idx)<epochSamples,continue;end
        segment=emg(idx);
        try
            [features,diag]=decompose_and_extract_mu_features(segment,targetFs,cfg);
        catch ME
            warning('UCDDB subject %s event %d skipped: %s',manifest.SubjectID(s),e,ME.message);continue;
        end
        nMU=height(features); if nMU==0,continue;end
        metadata=table(repmat(manifest.SubjectID(s),nMU,1),repmat(manifest.Severity(s),nMU,1), ...
            repmat(events.Type(e),nMU,1),repmat(e,nMU,1),repmat(originalFs,nMU,1), ...
            repmat(label,nMU,1),repmat(diag.nRetainedSources,nMU,1), ...
            'VariableNames',{'Subject','Severity','EventType','EventIndex','OriginalFs','EMGChannel','RetainedSources'});
        rows=[rows;metadata features]; %#ok<AGROW>
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
outFile=fullfile(cfg.outputDir,'UCDDB_MU_features.csv');writetable(outputTable,outFile);
fprintf('Saved %d UCDDB MU rows to %s\n',height(outputTable),outFile);
end
