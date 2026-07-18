function startup()
%STARTUP Add repository source, tests, and optional dependency paths.

repoRoot = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(repoRoot, 'src')));
addpath(fullfile(repoRoot, 'config'));
addpath(fullfile(repoRoot, 'tests'));

localPathFile = fullfile(repoRoot, 'config', 'local_paths.m');
if isfile(localPathFile)
    paths = local_paths();
    fields = fieldnames(paths);
    for k = 1:numel(fields)
        p = string(paths.(fields{k}));
        if strlength(p) > 0 && isfolder(p)
            addpath(genpath(p));
        end
    end
else
    fprintf(['Optional dependency paths are not configured. Copy\n', ...
        '  config/local_paths.example.txt\n', ...
        'to\n', ...
        '  config/local_paths.m\n', ...
        'and edit the paths before running decomposition or feature extraction.\n']);
end
end
