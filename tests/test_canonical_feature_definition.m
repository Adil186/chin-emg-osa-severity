function test_canonical_feature_definition()
def=canonical_feature_definition();
assert(height(def)==41);assert(numel(unique(def.Name))==41);
assert(all(def.Name(14:17)==["AutoregressionModelT1";"AutoregressionModelT2";"AutoregressionModelT3";"AutoregressionModelT4"]));
end
