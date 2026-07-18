function y = resample_signal(x, fsIn, fsOut, method)
%RESAMPLE_SIGNAL Resample a vector, including nearest-neighbor label support.

arguments
    x {mustBeNumeric, mustBeVector}
    fsIn (1,1) double {mustBePositive}
    fsOut (1,1) double {mustBePositive}
    method (1,1) string = "polyphase"
end

x = double(x(:));
if abs(fsIn - fsOut) < eps(max(fsIn,fsOut))
    y = x;
    return;
end

switch lower(method)
    case "polyphase"
        [p,q] = rat(fsOut/fsIn, 1e-12);
        y = resample(x,p,q);
    case "nearest"
        tIn = (0:numel(x)-1)'/fsIn;
        nOut = max(1, round((numel(x)-1)*fsOut/fsIn)+1);
        tOut = (0:nOut-1)'/fsOut;
        y = interp1(tIn,x,tOut,'nearest','extrap');
    otherwise
        error('Unknown resampling method: %s', method);
end
end
