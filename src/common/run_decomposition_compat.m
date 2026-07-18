function motorUnit = run_decomposition_compat(signal, fs, options)
%RUN_DECOMPOSITION_COMPAT Call hdEMG-Decomposition with compatibility fallback.

arguments
    signal {mustBeNumeric, mustBeVector}
    fs (1,1) double {mustBePositive}
    options.extensionParameter (1,1) double {mustBePositive} = 16
    options.maxSources (1,1) double {mustBePositive} = 300
    options.whitenFlag (1,1) double {mustBeMember(options.whitenFlag,[0 1])} = 1
    options.snr (1,1) double = Inf
    options.silhouetteThreshold (1,1) double = 0.6
end

if exist('run_decomposition', 'file') ~= 2
    error('run_decomposition_compat:MissingDependency', ...
        'run_decomposition was not found. Install hdEMG-Decomposition and add it to the MATLAB path.');
end

signal = double(signal(:));
try
    motorUnit = run_decomposition( ...
        'data', signal(:).', ...
        'data_mode', 'monopolar', ...
        'frq', fs, ...
        'R', options.extensionParameter, ...
        'M', options.maxSources, ...
        'whiten_flag', options.whitenFlag, ...
        'SNR', options.snr, ...
        'SIL_thresh', options.silhouetteThreshold, ...
        'output_file', tempname, ...
        'save_flag', 0, ...
        'plot_spikeTrain', 0);
catch primaryError
    % Compatibility with the positional signature used in the submitted archive.
    tempFile = [tempname, '.mat'];
    M = signal; %#ok<NASGU>
    save(tempFile, 'M');
    cleanup = onCleanup(@() delete_if_exists(tempFile));
    try
        motorUnit = run_decomposition(tempFile, 'monopolar', fs, ...
            options.extensionParameter, options.maxSources, ...
            options.whitenFlag, options.snr, options.silhouetteThreshold, pwd, 0);
    catch legacyError
        error('run_decomposition_compat:BothInterfacesFailed', ...
            ['The documented and legacy run_decomposition calls both failed.\n', ...
             'Documented interface error: %s\nLegacy interface error: %s'], ...
            primaryError.message, legacyError.message);
    end
end

if ~isstruct(motorUnit) || ~isfield(motorUnit, 'source') || isempty(motorUnit.source)
    error('run_decomposition_compat:NoSources', ...
        'The decomposition returned no motor-unit source matrix.');
end
end

function delete_if_exists(fileName)
if isfile(fileName)
    delete(fileName);
end
end
