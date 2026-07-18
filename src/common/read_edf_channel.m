function [signal, fs, matchedLabel] = read_edf_channel(edfFile, aliases)
%READ_EDF_CHANNEL Read one EDF signal using case-insensitive alias matching.

arguments
    edfFile (1,1) string
    aliases (1,:) string
end

if ~isfile(edfFile)
    error('read_edf_channel:MissingFile', 'EDF file not found: %s', edfFile);
end

info = edfinfo(edfFile);
labels = string(info.SignalLabels);
idx = [];
for a = aliases
    exact = find(strcmpi(labels, a), 1);
    if ~isempty(exact)
        idx = exact;
        break;
    end
end
if isempty(idx)
    for a = aliases
        partial = find(contains(lower(labels), lower(a)), 1);
        if ~isempty(partial)
            idx = partial;
            break;
        end
    end
end
if isempty(idx)
    error('read_edf_channel:ChannelNotFound', ...
        'None of the requested aliases was found in %s. Available labels: %s', ...
        edfFile, strjoin(labels, ', '));
end

matchedLabel = labels(idx);
tt = edfread(edfFile, 'SelectedSignals', labels(idx));
raw = tt{:,1};
if iscell(raw)
    raw = vertcat(raw{:});
end
signal = double(raw(:));

recordDuration = seconds(info.DataRecordDuration);
if ~isfinite(recordDuration) || recordDuration <= 0
    error('read_edf_channel:BadRecordDuration', 'Invalid EDF data-record duration.');
end
samplesPerRecord = double(info.NumSamples(idx));
fs = samplesPerRecord / recordDuration;
end
