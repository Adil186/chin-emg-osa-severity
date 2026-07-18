function test_build_emg_epochs()
x=(1:1000)';e=build_emg_epochs(x,[201;601],[250;650]);
assert(numel(e.event)==2);assert(numel(e.event{1})==50);assert(all(e.normal{1}<151 | e.normal{1}>700));
end
