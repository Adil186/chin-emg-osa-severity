function result = detect_apnea(signal, fs, options)
%DETECT_APNEA Detect sustained low-amplitude airflow regions.
%
% This is a boundary-safe implementation of the threshold/run-length logic
% used in the submitted ADA helper. ExpectedEvents is optional.

arguments
    signal {mustBeNumeric,mustBeVector}
    fs (1,1) double {mustBePositive}
    options.shortestDurationSec (1,1) double {mustBePositive} = 10
    options.longestDurationSec (1,1) double {mustBePositive} = 120
    options.expectedEvents double = NaN
    options.initialThreshold (1,1) double {mustBePositive} = 0.10
    options.thresholdStep (1,1) double {mustBePositive} = 0.0005
    options.maxIterations (1,1) double {mustBeInteger,mustBePositive} = 1000
end

x = abs(double(signal(:)));
scale = max(x);
if ~isfinite(scale) || scale<=0
    result = empty_result(numel(x),options.initialThreshold);
    return;
end
minSamples = max(1,round(options.shortestDurationSec*fs));
maxSamples = max(minSamples,round(options.longestDurationSec*fs));
threshold = options.initialThreshold;
expectedFinite = isscalar(options.expectedEvents) && isfinite(options.expectedEvents) && options.expectedEvents>=0;

for iteration = 1:options.maxIterations
    lowMask = x <= threshold*scale;
    [starts,ends] = logical_runs(lowMask);
    lengths = ends-starts+1;
    keep = lengths>=minSamples & lengths<=maxSamples;
    starts = starts(keep); ends = ends(keep);
    if ~expectedFinite || numel(starts)<=options.expectedEvents || threshold<=options.thresholdStep
        break;
    end
    threshold = threshold-options.thresholdStep;
end

mask = false(numel(x),1);
for k = 1:numel(starts), mask(starts(k):ends(k))=true; end
result = struct('start',starts(:),'end',ends(:), ...
    'durationSec',(ends(:)-starts(:)+1)/fs, ...
    'mask',mask,'nEvents',numel(starts),'threshold',threshold);
end

function [starts,ends] = logical_runs(mask)
mask = logical(mask(:));
d = diff([false;mask;false]);
starts = find(d==1);
ends = find(d==-1)-1;
end

function r = empty_result(n,threshold)
r = struct('start',zeros(0,1),'end',zeros(0,1), ...
    'durationSec',zeros(0,1),'mask',false(n,1),'nEvents',0,'threshold',threshold);
end
