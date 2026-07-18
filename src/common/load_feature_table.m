function data = load_feature_table(fileName, fallbackFirstFeatureColumn)
%LOAD_FEATURE_TABLE Load metadata plus the canonical 41-feature matrix.

arguments
    fileName (1,1) string
    fallbackFirstFeatureColumn (1,1) double {mustBeInteger,mustBePositive} = 8
end

if ~isfile(fileName)
    error('load_feature_table:MissingFile', 'Feature table not found: %s', fileName);
end
T = readtable(fileName, 'VariableNamingRule','preserve');
required = ["Subject","Severity"];
for name = required
    if ~ismember(name,string(T.Properties.VariableNames))
        error('load_feature_table:MissingColumn', 'Required column %s is missing.', name);
    end
end

T.Subject = fillmissing(string(T.Subject),'previous');
T.Severity = fillmissing(string(T.Severity),'previous');
T = T(strlength(strtrim(T.Subject))>0 & strlength(strtrim(T.Severity))>0,:);
T.Subject = categorical(strtrim(T.Subject));
T.Severity = categorical(strtrim(T.Severity));

def = canonical_feature_definition();
canonical = def.Name;
variables = string(T.Properties.VariableNames);
if all(ismember(canonical,variables))
    featureNames = canonical.';
    featureIdx = zeros(1,41);
    for k = 1:41
        featureIdx(k) = find(variables == canonical(k),1);
    end
else
    if width(T) < fallbackFirstFeatureColumn + 40
        error('load_feature_table:FeatureCount', ...
            'Could not find canonical columns and fewer than 41 fallback columns are available.');
    end
    featureIdx = fallbackFirstFeatureColumn:(fallbackFirstFeatureColumn+40);
    featureNames = variables(featureIdx);
    warning('load_feature_table:FallbackColumns', ...
        'Canonical names were not found. Using columns %d:%d.', ...
        featureIdx(1), featureIdx(end));
end

X = nan(height(T),41);
for k = 1:41
    col = T{:,featureIdx(k)};
    if isnumeric(col)
        X(:,k) = double(col);
    else
        text = string(col);
        text = regexprep(text, '\s*[+-]\s*[0-9\.Ee-]+i\s*$', '');
        X(:,k) = str2double(text);
    end
end

keep = all(isfinite(X),2);
if any(~keep)
    warning('load_feature_table:DroppedRows', ...
        'Dropping %d rows containing non-finite feature values.',sum(~keep));
end
T = T(keep,:);
X = X(keep,:);

data = struct('table',T,'X',X,'y',T.Severity,'subjects',T.Subject, ...
    'featureNames',featureNames,'featureIdx',featureIdx);
end
