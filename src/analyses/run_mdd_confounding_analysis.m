function results = run_mdd_confounding_analysis(input)
%RUN_MDD_CONFOUNDING_ANALYSIS Descriptive MDD-status performance analysis.
%
% The required input is intentionally external because MDD status is
% sensitive. Required columns: MDD (0/1) plus one or more numeric metrics.

if istable(input),T=input;else,T=readtable(input);end
if ~ismember('MDD',T.Properties.VariableNames),error('Input must contain an MDD column coded 0/1.');end
mdd=double(T.MDD(:)); if any(~ismember(mdd,[0 1])),error('MDD must be coded 0 or 1.');end
metricNames=string(T.Properties.VariableNames(varfun(@isnumeric,T,'OutputFormat','uniform')));
metricNames=metricNames(metricNames~="MDD");
results=table;
for name=metricNames
    x=double(T.(name)); x0=x(mdd==0);x1=x(mdd==1);
    [p,~,stats]=ranksum(x0,x1);
    W=stats.ranksum; n0=numel(x0); U0=W-n0*(n0+1)/2;
    r=corr(mdd,x,'Rows','complete','Type','Pearson');
    row=table(name,numel(x0),numel(x1),mean(x0,'omitnan'),mean(x1,'omitnan'),U0,p,r, ...
        'VariableNames',{'Metric','N_NoMDD','N_MDD','Mean_NoMDD','Mean_MDD','MannWhitneyU','PValue','PointBiserialR'});
    results=[results;row]; %#ok<AGROW>
end
warning('This small-sample analysis is descriptive and hypothesis-generating, not confirmatory.');
end
