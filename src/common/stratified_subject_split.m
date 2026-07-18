function split = stratified_subject_split(subjects, subjectLabels, nTestPerClass, seed)
%STRATIFIED_SUBJECT_SPLIT Select complete subjects by class.

arguments
    subjects
    subjectLabels
    nTestPerClass
    seed (1,1) double = 1
end
rng(seed);
subjects = string(subjects(:));
subjectLabels = string(subjectLabels(:));
if numel(subjects) ~= numel(subjectLabels)
    error('subjects and subjectLabels must have equal length.');
end
classes = unique(subjectLabels,'stable');
if isscalar(nTestPerClass)
    nTestPerClass = repmat(nTestPerClass,numel(classes),1);
else
    nTestPerClass = nTestPerClass(:);
end
if numel(nTestPerClass) ~= numel(classes)
    error('nTestPerClass must be scalar or one value per class.');
end
selected = strings(0,1);
for k = 1:numel(classes)
    candidates = subjects(subjectLabels==classes(k));
    if numel(candidates) < nTestPerClass(k)
        error('Class %s has %d subjects but %d were requested.',classes(k),numel(candidates),nTestPerClass(k));
    end
    order = randperm(numel(candidates),nTestPerClass(k));
    selected = [selected; candidates(order)]; %#ok<AGROW>
end
split.testSubjects = selected;
split.trainSubjects = subjects(~ismember(subjects,selected));
end
