function y = apply_chin_emg_filter(x, fs, cfg)
%APPLY_CHIN_EMG_FILTER Apply the manuscript-described notch and band-pass filters.

arguments
    x {mustBeNumeric, mustBeVector}
    fs (1,1) double {mustBePositive}
    cfg struct
end

x = double(x(:));
y = x;

notchHz = cfg.preprocessing.notchHz;
halfWidth = cfg.preprocessing.notchHalfWidthHz;
if notchHz + halfWidth < fs/2
    [bStop,aStop] = butter(2, ...
        [(notchHz-halfWidth) (notchHz+halfWidth)]/(fs/2), 'stop');
    y = filtfilt(bStop,aStop,y);
end

passband = cfg.preprocessing.bandpassHz;
if passband(2) >= fs/2
    error('apply_chin_emg_filter:InvalidBand', ...
        'Upper passband %.3g Hz must be below the %.3g Hz Nyquist frequency.', ...
        passband(2), fs/2);
end
[bBand,aBand] = butter(2, passband/(fs/2), 'bandpass');
y = filtfilt(bBand,aBand,y);
end
