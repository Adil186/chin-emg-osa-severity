function severityProfiles = run_acpn_loso_shap(cfg)
%RUN_ACPN_LOSO_SHAP Subject-level mean |SHAP| profiles under outer LOSO.

arguments
    cfg struct = example_config()
end
rng(cfg.seed);
data=load_feature_table(cfg.featureTable,cfg.firstFeatureColumn);
X=data.X; y=data.y; subjects=data.subjects;
subjectNames=categories(subjects); classNames=categories(y);
subjectProfiles=nan(numel(subjectNames),41);
subjectSeverity=strings(numel(subjectNames),1);

for i=1:numel(subjectNames)
    testMask=subjects==subjectNames{i}; trainMask=~testMask;
    [XTrain,XTest]=zscore_train_test(X(trainMask,:),X(testMask,:));
    weights=make_subject_balanced_weights(subjects(trainMask),y(trainMask),true);
    mdl=train_base_model("AdaBoost",XTrain,y(trainMask),weights);

    % Background: all training MUs; query points: all MUs from held-out subject.
    explainer=shapley(mdl,XTrain,"QueryPoints",XTest);
    meanAbsTable=explainer.MeanAbsoluteShapley;
    classColumns=string(meanAbsTable.Properties.VariableNames(2:end));
    trueClass=string(y(find(testMask,1)));
    classIndex=find(classColumns==trueClass,1);
    if isempty(classIndex)
        error('True class %s was not found in the SHAP output columns.',trueClass);
    end
    profile=meanAbsTable{:,classIndex+1}.';
    if numel(profile)~=41
        error('SHAP profile contains %d values instead of 41.',numel(profile));
    end
    subjectProfiles(i,:)=profile;
    subjectSeverity(i)=trueClass;
end

severityProfiles=table(string(classNames),'VariableNames',{'Severity'});
for f=1:41
    values=nan(numel(classNames),1);
    for c=1:numel(classNames)
        values(c)=mean(subjectProfiles(subjectSeverity==string(classNames{c}),f),'omitnan');
    end
    severityProfiles.(char(data.featureNames(f)))=values;
end
if ~isfolder(cfg.outputDir),mkdir(cfg.outputDir);end
writetable(severityProfiles,fullfile(cfg.outputDir,'ACPN_LOSO_AdaBoost_severity_SHAP.csv'));
subjectTable=array2table(subjectProfiles,'VariableNames',cellstr(data.featureNames));
subjectTable=addvars(subjectTable,string(subjectNames),subjectSeverity,'Before',1, ...
    'NewVariableNames',{'Subject','Severity'});
writetable(subjectTable,fullfile(cfg.outputDir,'ACPN_LOSO_AdaBoost_subject_SHAP.csv'));
save(fullfile(cfg.outputDir,'ACPN_LOSO_AdaBoost_subject_SHAP.mat'), ...
    'subjectProfiles','subjectSeverity','severityProfiles');
end
