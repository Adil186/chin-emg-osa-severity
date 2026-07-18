function test_compute_features_if_available()
if exist('jfemg','file')~=2
    fprintf('SKIP test_compute_features_if_available: jfemg is not on the path.\n');
    return;
end
rng(1);x=randn(1,1000);[values,names]=compute_canonical_features(x);assert(numel(values)==41);assert(numel(names)==41);
end
