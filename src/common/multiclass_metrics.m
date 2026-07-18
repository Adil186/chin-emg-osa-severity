function metrics = multiclass_metrics(yTrue, yPred, scores, classNames)
%MULTICLASS_METRICS Macro metrics plus one-vs-rest AUC when estimable.

metrics = macro_metrics(yTrue,yPred,classNames);
classNames = string(classNames(:));
auc = nan(numel(classNames),1);
if nargin >= 3 && ~isempty(scores)
    if size(scores,2) ~= numel(classNames)
        error('Score matrix has %d columns for %d classes.',size(scores,2),numel(classNames));
    end
    for k = 1:numel(classNames)
        binary = string(yTrue)==classNames(k);
        if any(binary) && any(~binary)
            [~,~,~,auc(k)] = perfcurve(binary,scores(:,k),true);
        end
    end
end
metrics.auc = auc;
metrics.aucMacro = mean(auc,'omitnan');
end
