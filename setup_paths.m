function root = setup_paths()
% Add only the portable code, not historical scripts with duplicate names.
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'src'));
addpath(fullfile(root, 'examples'));
addpath(fullfile(root, 'tests'));
addpath(fullfile(root, 'configs'));
addpath(fullfile(root, 'workflows'));
if exist('OCTAVE_VERSION', 'builtin')
    pkg('load', 'signal');
end
end
