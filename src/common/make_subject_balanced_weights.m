function weights = make_subject_balanced_weights(subjects, labels, balanceClasses)
%MAKE_SUBJECT_BALANCED_WEIGHTS Give each subject equal total training weight.

arguments
    subjects
    labels
    balanceClasses (1,1) logical = true
end
subjects = categorical(subjects);
labels = categorical(labels);
weights = zeros(numel(subjects),1);
subjectNames = categories(subjects);
for k = 1:numel(subjectNames)
    idx = subjects == subjectNames{k};
    weights(idx) = 1/sum(idx);
end
if balanceClasses
    classNames = categories(labels);
    for k = 1:numel(classNames)
        idx = labels == classNames{k};
        if any(idx)
            weights(idx) = weights(idx)/sum(weights(idx));
        end
    end
end
weights = weights*numel(weights)/sum(weights);
end
