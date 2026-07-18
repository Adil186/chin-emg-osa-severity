function [values, names] = compute_canonical_features(x, options)
%COMPUTE_CANONICAL_FEATURES Compute the ordered 41-feature vector.
%
% values = 1 x 41 numeric vector
% names  = 1 x 41 string array
%
% options.thresholdMode: "fixed" (submitted constants) or "relative"
% options.generalThreshold: default 0.01
% options.myopThreshold: default 0.016

arguments
    x {mustBeNumeric, mustBeVector}
    options.thresholdMode (1,1) string = "fixed"
    options.generalThreshold (1,1) double {mustBeNonnegative} = 0.01
    options.myopThreshold (1,1) double {mustBeNonnegative} = 0.016
end

if exist('jfemg', 'file') ~= 2
    error('compute_canonical_features:MissingDependency', ...
        'jfemg was not found. Install the EMG Feature Extraction Toolbox and add it to the MATLAB path.');
end

x = double(x(:).');
if numel(x) < 8 || any(~isfinite(x))
    error('compute_canonical_features:InvalidSignal', ...
        'The MU signal must contain at least 8 finite samples.');
end

switch lower(options.thresholdMode)
    case "fixed"
        scale = 1;
    case "relative"
        scale = std(x, 0, 2);
        if ~isfinite(scale) || scale == 0
            scale = 1;
        end
    otherwise
        error('thresholdMode must be "fixed" or "relative".');
end

generalThreshold = options.generalThreshold * scale;
myopThreshold = options.myopThreshold * scale;

values = nan(1,41);
idx = 0;

[values,idx] = append_feature(values,idx,'emav',x,struct());
[values,idx] = append_feature(values,idx,'ewl',x,struct());
[values,idx] = append_feature(values,idx,'fzc',x,struct());
[values,idx] = append_feature(values,idx,'asm',x,struct());
[values,idx] = append_feature(values,idx,'ass',x,struct());
[values,idx] = append_feature(values,idx,'ltkeo',x,struct());
[values,idx] = append_feature(values,idx,'card',x,struct('thres',generalThreshold));
[values,idx] = append_feature(values,idx,'ldasdv',x,struct());
[values,idx] = append_feature(values,idx,'ldamv',x,struct());
[values,idx] = append_feature(values,idx,'dvarv',x,struct());
[values,idx] = append_feature(values,idx,'vo',x,struct('order',2));
[values,idx] = append_feature(values,idx,'tm',x,struct('order',3));
[values,idx] = append_feature(values,idx,'damv',x,struct());

arValues = double(jfemg('ar', x, struct('order',4)));
arValues = arValues(:).';
if numel(arValues) ~= 4
    error('compute_canonical_features:ARLength', ...
        'Fourth-order AR extraction returned %d values instead of 4.', numel(arValues));
end
for k = 1:4
    idx = idx + 1;
    values(idx) = real_if_numerically_complex(arValues(k), sprintf('ar%d',k));
end

[values,idx] = append_feature(values,idx,'mad',x,struct());
[values,idx] = append_feature(values,idx,'iqr',x,struct());
[values,idx] = append_feature(values,idx,'skew',x,struct());
[values,idx] = append_feature(values,idx,'kurt',x,struct());
[values,idx] = append_feature(values,idx,'cov',x,struct());
[values,idx] = append_feature(values,idx,'sd',x,struct());
[values,idx] = append_feature(values,idx,'var',x,struct());
[values,idx] = append_feature(values,idx,'ae',x,struct());
[values,idx] = append_feature(values,idx,'iemg',x,struct());
[values,idx] = append_feature(values,idx,'mav',x,struct());
[values,idx] = append_feature(values,idx,'ssc',x,struct('thres',generalThreshold));
[values,idx] = append_feature(values,idx,'zc',x,struct('thres',generalThreshold));
[values,idx] = append_feature(values,idx,'wl',x,struct());
[values,idx] = append_feature(values,idx,'rms',x,struct());
[values,idx] = append_feature(values,idx,'aac',x,struct());
[values,idx] = append_feature(values,idx,'dasdv',x,struct());
[values,idx] = append_feature(values,idx,'ld',x,struct());
[values,idx] = append_feature(values,idx,'mmav',x,struct());
[values,idx] = append_feature(values,idx,'mmav2',x,struct());
[values,idx] = append_feature(values,idx,'myop',x,struct('thres',myopThreshold));
[values,idx] = append_feature(values,idx,'ssi',x,struct());
[values,idx] = append_feature(values,idx,'vare',x,struct());
[values,idx] = append_feature(values,idx,'wa',x,struct('thres',generalThreshold));
[values,idx] = append_feature(values,idx,'mfl',x,struct());

if idx ~= 41
    error('Internal feature count is %d instead of 41.', idx);
end
if any(~isfinite(values))
    warning('compute_canonical_features:NonFinite', ...
        'One or more feature values are non-finite. Inspect the input signal.');
end

def = canonical_feature_definition();
names = def.Name.';
end

function [values,idx] = append_feature(values,idx,code,x,opts)
idx = idx + 1;
if isempty(fieldnames(opts))
    value = jfemg(code,x);
else
    value = jfemg(code,x,opts);
end
if ~isscalar(value)
    error('Feature %s returned %d values; one scalar was expected.',code,numel(value));
end
values(idx) = real_if_numerically_complex(value,code);
end

function y = real_if_numerically_complex(value,label)
value = double(value);
if ~isreal(value)
    tolerance = 1e-10 * max(1,abs(real(value)));
    if abs(imag(value)) <= tolerance
        value = real(value);
    else
        error('Feature %s returned a materially complex value.',label);
    end
end
y = value;
end
