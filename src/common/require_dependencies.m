function report = require_dependencies()
%REQUIRE_DEPENDENCIES Check required external functions and MATLAB products.

functions = ["jfemg","run_decomposition","edfread","edfinfo","fitcensemble","shapley"];
found = arrayfun(@(f) exist(f,'file')==2 || exist(f,'builtin')==5,functions);
report = table(functions.',found.','VariableNames',{'Function','Available'});
disp(report)
if any(~found)
    warning('One or more required functions are unavailable. See docs/EXTERNAL_DEPENDENCIES.md.');
end
end
