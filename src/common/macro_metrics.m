function metrics = macro_metrics(yTrue, yPred, classNames)
%MACRO_METRICS Per-class and macro precision, recall, and F1.

yTrue = categorical(string(yTrue), string(classNames));
yPred = categorical(string(yPred), string(classNames));
classNames = string(classNames(:));
n = numel(classNames);
precision = nan(n,1); recall = nan(n,1); f1 = nan(n,1); support = zeros(n,1);
for k = 1:n
    cls = classNames(k);
    tp = sum(string(yTrue)==cls & string(yPred)==cls);
    fp = sum(string(yTrue)~=cls & string(yPred)==cls);
    fn = sum(string(yTrue)==cls & string(yPred)~=cls);
    support(k) = sum(string(yTrue)==cls);
    if tp+fp > 0, precision(k)=tp/(tp+fp); end
    if tp+fn > 0, recall(k)=tp/(tp+fn); end
    if isfinite(precision(k)) && isfinite(recall(k)) && precision(k)+recall(k)>0
        f1(k)=2*precision(k)*recall(k)/(precision(k)+recall(k));
    end
end
metrics = struct;
metrics.classNames = classNames;
metrics.precision = precision;
metrics.recall = recall;
metrics.f1 = f1;
metrics.support = support;
metrics.precisionMacro = mean(precision,'omitnan');
metrics.recallMacro = mean(recall,'omitnan');
metrics.f1Macro = mean(f1,'omitnan');
metrics.accuracy = mean(string(yTrue)==string(yPred));
end
