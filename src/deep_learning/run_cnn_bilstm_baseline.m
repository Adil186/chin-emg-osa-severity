function output = run_cnn_bilstm_baseline(cfg)
%RUN_CNN_BILSTM_BASELINE End-to-end 30 s chin-EMG baseline.
%
% Manifest columns: SubjectID, Severity, EDFFile. No real identifiers are
% embedded in the public code.

arguments
    cfg struct = example_config()
end
rng(cfg.seed);
manifest=readtable(cfg.acpn.manifestFile,'TextType','string');
required=["SubjectID","Severity","EDFFile"];
if ~all(ismember(required,string(manifest.Properties.VariableNames)))
    error('Manifest must contain SubjectID, Severity, and EDFFile.');
end

allWindows=cell(0,1); allLabels=categorical; allSubjects=strings(0,1);
for s=1:height(manifest)
    [emg,fs]=load_preprocess_acpn_emg(manifest.EDFFile(s),cfg);
    nSamples=round(cfg.deepLearning.windowDurationSec*fs);
    nWindows=floor(numel(emg)/nSamples);
    for w=1:nWindows
        x=emg((w-1)*nSamples+1:w*nSamples);
        sd=std(x); if sd>0,x=(x-mean(x))/sd;else,x=x-mean(x);end
        allWindows{end+1,1}=single(x(:).'); %#ok<AGROW>
        allLabels(end+1,1)=categorical(manifest.Severity(s)); %#ok<AGROW>
        allSubjects(end+1,1)=manifest.SubjectID(s); %#ok<AGROW>
    end
end

uniqueSubjects=unique(allSubjects,'stable'); subjectLabels=strings(numel(uniqueSubjects),1);
for k=1:numel(uniqueSubjects),subjectLabels(k)=string(allLabels(find(allSubjects==uniqueSubjects(k),1)));end
classes=unique(subjectLabels,'stable');
valCount=ones(numel(classes),1); testCount=ones(numel(classes),1);
moderate=find(strcmpi(classes,'Moderate'),1); if ~isempty(moderate),testCount(moderate)=2;end
valSplit=stratified_subject_split(uniqueSubjects,subjectLabels,valCount,cfg.seed);
remaining=valSplit.trainSubjects;
remainingLabels=strings(numel(remaining),1);
for k=1:numel(remaining),remainingLabels(k)=subjectLabels(uniqueSubjects==remaining(k));end
testSplit=stratified_subject_split(remaining,remainingLabels,testCount,cfg.seed+1);
valSubjects=valSplit.testSubjects; testSubjects=testSplit.testSubjects; trainSubjects=testSplit.trainSubjects;
trainMask=ismember(allSubjects,trainSubjects); valMask=ismember(allSubjects,valSubjects); testMask=ismember(allSubjects,testSubjects);

XTrain=allWindows(trainMask);YTrain=allLabels(trainMask);XVal=allWindows(valMask);YVal=allLabels(valMask);XTest=allWindows(testMask);YTest=allLabels(testMask);
inputLength=numel(XTrain{1});
classNames=categories(allLabels);
counts=countcats(removecats(YTrain)); weights=numel(YTrain)./(numel(counts)*counts); weights=weights/mean(weights);

layers=[ ...
    sequenceInputLayer(1,'MinLength',inputLength)
    convolution1dLayer(7,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling1dLayer(2,'Stride',2)
    convolution1dLayer(7,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling1dLayer(2,'Stride',2)
    bilstmLayer(32,'OutputMode','last')
    dropoutLayer(cfg.deepLearning.dropout)
    fullyConnectedLayer(numel(classNames))
    softmaxLayer
    classificationLayer('Classes',categorical(classNames),'ClassWeights',weights)];

options=trainingOptions('adam', ...
    'InitialLearnRate',cfg.deepLearning.initialLearnRate, ...
    'L2Regularization',cfg.deepLearning.l2Regularization, ...
    'MiniBatchSize',cfg.deepLearning.miniBatchSize, ...
    'MaxEpochs',cfg.deepLearning.maxEpochs, ...
    'Shuffle','every-epoch','ValidationData',{XVal,YVal}, ...
    'Verbose',false,'Plots','training-progress');
net=trainNetwork(XTrain,YTrain,layers,options);
[predTest,scoreTest]=classify(net,XTest,'MiniBatchSize',cfg.deepLearning.miniBatchSize);
windowMetrics=multiclass_metrics(YTest,predTest,scoreTest,classNames);

subjectCorrect=false(numel(testSubjects),1); subjectPrediction=strings(numel(testSubjects),1); subjectTruth=strings(numel(testSubjects),1);
for k=1:numel(testSubjects)
    idx=find(allSubjects(testMask)==testSubjects(k));
    pred=predTest(idx); subjectPrediction(k)=string(mode(pred)); subjectTruth(k)=string(YTest(idx(1)));
    subjectCorrect(k)=subjectPrediction(k)==subjectTruth(k);
end
subjectTable=table(testSubjects,subjectTruth,subjectPrediction,subjectCorrect, ...
    'VariableNames',{'Subject','TrueSeverity','PredictedSeverity','Correct'});
output=struct('network',net,'windowMetrics',windowMetrics,'subjectTable',subjectTable, ...
    'trainSubjects',trainSubjects,'validationSubjects',valSubjects,'testSubjects',testSubjects);
if ~isfolder(cfg.outputDir),mkdir(cfg.outputDir);end
save(fullfile(cfg.outputDir,'Baseline1DCNN_BiLSTM.mat'),'output','-v7.3');
writetable(subjectTable,fullfile(cfg.outputDir,'CNN_BiLSTM_subject_predictions.csv'));
end
