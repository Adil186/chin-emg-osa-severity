function [featureTable, diagnostics] = decompose_and_extract_mu_features(segment, fs, cfg)
%DECOMPOSE_AND_EXTRACT_MU_FEATURES Decompose one epoch and compute 41 features per MU.

arguments
    segment {mustBeNumeric, mustBeVector}
    fs (1,1) double {mustBePositive}
    cfg struct
end

x = double(segment(:));
if isfield(cfg, 'preprocessing') && isfield(cfg.preprocessing, 'standardizeEpoch') ...
        && cfg.preprocessing.standardizeEpoch
    sigma = std(x);
    if isfinite(sigma) && sigma > 0
        x = (x - mean(x)) ./ sigma;
    else
        x = x - mean(x);
    end
end

opts = cfg.decomposition;
motorUnit = run_decomposition_compat(x, fs, ...
    extensionParameter=opts.extensionParameter, ...
    maxSources=opts.maxSources, ...
    whitenFlag=opts.whitenFlag, ...
    snr=opts.snr, ...
    silhouetteThreshold=opts.silhouetteThreshold);

source = double(motorUnit.source);
if size(source,1) < size(source,2) && size(source,1) < numel(x)/2
    source = source.';
end

if isempty(source)
    def = canonical_feature_definition();
    featureTable = array2table(zeros(0,41), ...
        'VariableNames', cellstr(def.Name));
    diagnostics = struct('nRawSources',0,'nRetainedSources',0,'pcaExplained',[]);
    return;
end

nRawSources = size(source,2);
explained = [];
if opts.usePCA && size(source,2) > 1
    [~, score, ~, ~, explained] = pca(source, 'Centered', true);
    cumulative = cumsum(explained);
    nRetained = find(cumulative >= opts.pcaVariance, 1, 'first');
    if isempty(nRetained)
        nRetained = size(score,2);
    end
    retained = score(:,1:nRetained);
else
    retained = source;
    nRetained = size(retained,2);
end

featureValues = nan(nRetained,41);
featureNames = strings(1,41);
for c = 1:nRetained
    [featureValues(c,:), featureNames] = compute_canonical_features( ...
        retained(:,c), ...
        thresholdMode=cfg.features.thresholdMode, ...
        generalThreshold=cfg.features.generalThreshold, ...
        myopThreshold=cfg.features.myopThreshold);
end

featureTable = array2table(featureValues, 'VariableNames', cellstr(featureNames));
diagnostics = struct( ...
    'nRawSources', nRawSources, ...
    'nRetainedSources', nRetained, ...
    'pcaExplained', explained, ...
    'silhouetteScores', get_optional_field(motorUnit, 'silhouette_score', []));
end

function value = get_optional_field(s, fieldName, defaultValue)
if isfield(s, fieldName)
    value = s.(fieldName);
else
    value = defaultValue;
end
end
