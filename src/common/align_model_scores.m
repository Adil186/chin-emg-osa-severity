function aligned = align_model_scores(rawScores, modelClassNames, targetClassNames)
%ALIGN_MODEL_SCORES Align predict-score columns to a fixed global class order.
modelClassNames = string(modelClassNames(:));
targetClassNames = string(targetClassNames(:));
aligned = nan(size(rawScores,1),numel(targetClassNames));
for k = 1:numel(targetClassNames)
    idx = find(modelClassNames==targetClassNames(k),1);
    if ~isempty(idx), aligned(:,k)=rawScores(:,idx); end
end
end
