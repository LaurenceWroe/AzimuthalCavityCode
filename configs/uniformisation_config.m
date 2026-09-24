function cfg = uniformisation_config(variant)
% Named cases from section V. No successive overwriting of configuration.
if nargin < 1, variant = 'tm4610'; end
cfg = study_config('uniformisation'); cfg.variant = variant;
switch variant
    case 'tm410'
        cfg.map_files = {fullfile('uniformisation','tm410.dat')};
        cfg.normalise_orders = 4; cfg.target_g_MV_per_m = 108;
        cfg.expected_g6_over_g4 = 0;
    case 'superposed'
        cfg.map_files = {fullfile('uniformisation','tm410.dat'), fullfile('uniformisation','tm610.dat')};
        cfg.normalise_orders = [4 6]; cfg.target_g_MV_per_m = [151 -1006];
        cfg.expected_g6_over_g4 = -1006/151;
        cfg.uniform_region_mm = 70;
    case 'tm4610'
        % defaults: measured hybrid mode, g4=135 MV/m
    otherwise
        error('Azimuthal:UnknownVariant', 'Choose tm410, superposed, or tm4610.');
end
end
