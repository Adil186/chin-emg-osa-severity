function mdl = train_base_model(modelName, X, y, weights)
%TRAIN_BASE_MODEL Train a fixed-hyperparameter model from the article.

arguments
    modelName (1,1) string
    X double
    y
    weights double = []
end

useWeights = ~isempty(weights);
if useWeights, weights = weights(:); end

switch lower(modelName)
    case "adaboost"
        learner = templateTree('MaxNumSplits',28);
        args = {'Method','AdaBoostM2','Learners',learner, ...
            'NumLearningCycles',70,'LearnRate',0.92532,'Prior','uniform'};
        if useWeights, mdl=fitcensemble(X,y,args{:},'Weights',weights); else, mdl=fitcensemble(X,y,args{:}); end
    case "rusboost"
        learner = templateTree('MaxNumSplits',305);
        args = {'Method','RUSBoost','Learners',learner, ...
            'NumLearningCycles',12,'LearnRate',0.9962,'Prior','uniform'};
        if useWeights, mdl=fitcensemble(X,y,args{:},'Weights',weights); else, mdl=fitcensemble(X,y,args{:}); end
    case "randomforest"
        learner = templateTree('MaxNumSplits',961);
        args = {'Method','Bag','Learners',learner, ...
            'NumLearningCycles',159,'Prior','uniform'};
        if useWeights, mdl=fitcensemble(X,y,args{:},'Weights',weights); else, mdl=fitcensemble(X,y,args{:}); end
    case "decisiontree"
        args = {'MaxNumSplits',145,'SplitCriterion','deviance','Prior','uniform'};
        if useWeights, mdl=fitctree(X,y,args{:},'Weights',weights); else, mdl=fitctree(X,y,args{:}); end
    otherwise
        error('Unknown modelName: %s',modelName);
end
end
