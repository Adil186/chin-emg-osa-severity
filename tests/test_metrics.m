function test_metrics()
y=categorical(["Mild";"Mild";"Moderate";"Severe"]);p=categorical(["Mild";"Moderate";"Moderate";"Severe"]);
m=macro_metrics(y,p,["Mild","Moderate","Severe"]);assert(abs(m.accuracy-0.75)<1e-12);assert(m.f1Macro>0 && m.f1Macro<=1);
end
