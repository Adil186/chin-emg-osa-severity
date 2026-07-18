function metricsTable = run_acpn_loso(cfg)
%RUN_ACPN_LOSO Subject-wise LOSO with subject-balanced training weights.

arguments
    cfg struct = example_config()
end
rng(cfg.seed);
data=load_feature_table(cfg.featureTable,cfg.firstFeatureColumn);
T=data.table; X=data.X; y=data.y; subject=data.subjects;
subjects=categories(subject); classes=categories(y);
nSubjects=numel(subjects);

subjectID=strings(nSubjects,1); trueSeverity=strings(nSubjects,1); predictedSeverity=strings(nSubjects,1);
muAccuracy=zeros(nSubjects,1); precisionMacro=zeros(nSubjects,1); recallMacro=zeros(nSubjects,1); f1Macro=zeros(nSubjects,1);
trainCVMean=nan(nSubjects,1); trainCVStd=nan(nSubjects,1); subjectCorrect=false(nSubjects,1);
allTrue=strings(0,1); allPred=strings(0,1);

for i=1:nSubjects
    testMask=subject==subjects{i}; trainMask=~testMask;
    XTrainRaw=X(trainMask,:); XTestRaw=X(testMask,:);
    yTrain=y(trainMask); yTest=y(testMask); sTrain=subject(trainMask);
    [XTrain,XTest]=zscore_train_test(XTrainRaw,XTestRaw);

    trainSubjectNames=categories(removecats(sTrain));
    K=min(cfg.innerFolds,numel(trainSubjectNames));
    assignments=subject_fold_assignments(trainSubjectNames,K);
    cvAcc=nan(K,1);
    for k=1:K
        valSubjects=trainSubjectNames(assignments==k);
        innerVal=ismember(string(sTrain),string(valSubjects)); innerTrain=~innerVal;
        [Xin,Xval]=zscore_train_test(XTrainRaw(innerTrain,:),XTrainRaw(innerVal,:));
        win=make_subject_balanced_weights(sTrain(innerTrain),yTrain(innerTrain),true);
        innerModel=train_base_model(cfg.modelName,Xin,yTrain(innerTrain),win);
        yhat=predict(innerModel,Xval);
        cvAcc(k)=mean(yhat==yTrain(innerVal));
    end

    weights=make_subject_balanced_weights(sTrain,yTrain,true);
    mdl=train_base_model(cfg.modelName,XTrain,yTrain,weights);
    [yPred,scoreRaw]=predict(mdl,XTest);
    scores=align_model_scores(scoreRaw,mdl.ClassNames,classes);
    m=macro_metrics(yTest,yPred,classes);
    meanScores=mean(scores,1,'omitnan'); [~,winner]=max(meanScores);

    subjectID(i)=string(subjects{i}); trueSeverity(i)=string(yTest(1)); predictedSeverity(i)=string(classes{winner});
    muAccuracy(i)=m.accuracy; precisionMacro(i)=m.precisionMacro; recallMacro(i)=m.recallMacro; f1Macro(i)=m.f1Macro;
    trainCVMean(i)=mean(cvAcc,'omitnan'); trainCVStd(i)=std(cvAcc,0,'omitnan'); subjectCorrect(i)=predictedSeverity(i)==trueSeverity(i);
    allTrue=[allTrue;string(yTest)]; %#ok<AGROW>
    allPred=[allPred;string(yPred)]; %#ok<AGROW>
end

metricsTable=table(subjectID,trueSeverity,predictedSeverity,muAccuracy,recallMacro,precisionMacro,f1Macro,trainCVMean,trainCVStd,subjectCorrect, ...
    'VariableNames',{'Subject','TrueSeverity','PredictedSeverity','Accuracy','RecallMacro','PrecisionMacro','F1Macro','TrainCV_AccMean','TrainCV_AccStd','SubjectLevelCorrect'});
if ~isfolder(cfg.outputDir),mkdir(cfg.outputDir);end
writetable(metricsTable,fullfile(cfg.outputDir,sprintf('ACPN_LOSO_%s_metrics_per_subject.csv',cfg.modelName)));
save(fullfile(cfg.outputDir,sprintf('ACPN_LOSO_%s_metrics.mat',cfg.modelName)),'metricsTable','classes','allTrue','allPred');
fprintf('Subject-level accuracy: %.1f%% (%d/%d)\n',100*mean(subjectCorrect),sum(subjectCorrect),nSubjects);
end

function assignment=subject_fold_assignments(subjects,K)
order=randperm(numel(subjects)); assignment=zeros(numel(subjects),1);
for k=1:numel(subjects),assignment(order(k))=mod(k-1,K)+1;end
end
