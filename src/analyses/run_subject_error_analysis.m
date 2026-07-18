function summary = run_subject_error_analysis(input)
%RUN_SUBJECT_ERROR_ANALYSIS Ordinal subject-level severity error summary.
% input is a table or a CSV/XLSX file containing TrueSeverity and PredictedSeverity.

if istable(input),T=input;else,T=readtable(input,'TextType','string');end
required=["TrueSeverity","PredictedSeverity"];
if ~all(ismember(required,string(T.Properties.VariableNames)))
    error('Input must contain TrueSeverity and PredictedSeverity.');
end
levels=["Mild","Moderate","Severe"];
trueCode=severity_code(string(T.TrueSeverity),levels); predCode=severity_code(string(T.PredictedSeverity),levels);
signedError=predCode-trueCode; absoluteError=abs(signedError);
summary=struct('n',numel(absoluteError), ...
    'exactAgreement',mean(absoluteError==0), ...
    'oneStepError',mean(absoluteError==1), ...
    'twoStepError',mean(absoluteError==2), ...
    'overestimation',mean(signedError>0), ...
    'underestimation',mean(signedError<0), ...
    'meanAbsoluteError',mean(absoluteError));
T.SignedOrdinalError=signedError;T.AbsoluteOrdinalError=absoluteError;
disp(summary)
end

function code=severity_code(value,levels)
code=nan(numel(value),1);
for k=1:numel(levels),code(value==levels(k))=k;end
if any(isnan(code)),error('Severity labels must be Mild, Moderate, or Severe.');end
end
