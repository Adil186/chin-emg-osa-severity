function results = run_acpn_subject_split_models(cfg)
%RUN_ACPN_SUBJECT_SPLIT_MODELS Four-model 16/4-style subject split.

arguments
    cfg struct = example_config()
end
rng(cfg.seed);
data=load_feature_table(cfg.featureTable,cfg.firstFeatureColumn);
subjectNames=categories(data.subjects);
subjectLabels=strings(numel(subjectNames),1);
for i=1:numel(subjectNames),subjectLabels(i)=string(data.y(find(data.subjects==subjectNames{i},1)));end
classes=unique(subjectLabels,'stable');
% Default article-era allocation: one test subject per class, with one extra moderate subject.
nTest=ones(numel(classes),1); moderate=find(strcmpi(classes,'Moderate'),1); if ~isempty(moderate),nTest(moderate)=2;end
split=stratified_subject_split(subjectNames,subjectLabels,nTest,cfg.seed);
testMask=ismember(string(data.subjects),split.testSubjects); trainMask=~testMask;
[XTrain,XTest]=zscore_train_test(data.X(trainMask,:),data.X(testMask,:));
yTrain=data.y(trainMask); yTest=data.y(testMask);
weights=make_subject_balanced_weights(data.subjects(trainMask),yTrain,true);
models=["DecisionTree","AdaBoost","RUSBoost","RandomForest"];
results=table;
for m=1:numel(models)
    mdl=train_base_model(models(m),XTrain,yTrain,weights);
    [pred,raw]=predict(mdl,XTest);
    scores=align_model_scores(raw,mdl.ClassNames,categories(data.y));
    metric=multiclass_metrics(yTest,pred,scores,categories(data.y));
    results=[results;table(models(m),metric.accuracy,metric.recallMacro,metric.precisionMacro,metric.f1Macro,metric.aucMacro, ...
        'VariableNames',{'Model','Accuracy','RecallMacro','PrecisionMacro','F1Macro','AUCMacro'})]; %#ok<AGROW>
end
if ~isfolder(cfg.outputDir),mkdir(cfg.outputDir);end
writetable(results,fullfile(cfg.outputDir,'ACPN_subject_split_model_results.csv'));
end
