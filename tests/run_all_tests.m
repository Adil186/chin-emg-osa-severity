function results = run_all_tests()
%RUN_ALL_TESTS Run repository helper tests.
tests={@test_canonical_feature_definition,@test_detect_apnea,@test_build_emg_epochs,@test_metrics,@test_compute_features_if_available};
names=string(cellfun(@func2str,tests,'UniformOutput',false));passed=false(numel(tests),1);message=strings(numel(tests),1);
for k=1:numel(tests)
    try
        tests{k}();passed(k)=true;message(k)="PASS";
    catch ME
        message(k)="FAIL: "+string(ME.message);
    end
end
results=table(names.',passed,message,'VariableNames',{'Test','Passed','Message'});disp(results)
if any(~passed),error('%d repository tests failed.',sum(~passed));end
end
