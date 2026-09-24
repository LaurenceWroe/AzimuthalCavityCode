function cfg = study_config(name)
% Explicit starting configurations; see docs/PARAMETERS.md for provenance.
root = fileparts(fileparts(mfilename('fullpath')));
cfg.name = name;
cfg.frequency_Hz = 3e9;
cfg.cell_length_m = 299792458/(2*cfg.frequency_Hz);
cfg.pipe_length_m = 0.05;
cfg.bore_radius_m = 0.01;
cfg.charge_e = -1;
cfg.map_root = getenv('AZIMUTHAL_MAP_DIR');
if isempty(cfg.map_root), cfg.map_root = fullfile(root, 'maps'); end
cfg.output_dir = '';
cfg.make_plot = false;
cfg.phase_deg = [0 90];
cfg.initial_momentum_MeV_c = [10000 10 1];
cfg.radii_mm = linspace(0,8,6);
cfg.theta_samples = 180;
cfg.integration_samples = 1001;
cfg.step_m = 1e-4;
cfg.field_scale = 1;
cfg.interpolation = 'cubic';
cfg.source = 'Published paper, with explicitly documented working conventions';
switch name
    case 'benchmark'
        cfg.map_files = {fullfile('benchmark','mixed_012.dat')};
        cfg.orders = [0 1 2];
        cfg.shape_amplitudes = [1 1 1];
        cfg.bore_ratios = [1 0.354579 0.055528];
        cfg.analytic_voltage_MV = 1.24;
        cfg.scan_momentum_MeV_c = logspace(0,4,101);
    case 'coupler'
        cfg.labels = {'single_port','dual_port','quad_port','corrected'};
        cfg.map_files = cellfun(@(s) fullfile('coupler',[s '.dat']), cfg.labels, 'UniformOutput',false);
        cfg.orders = 0:4;
        cfg.shape_amplitudes = [1 0.0304 0.0363 -0.0802 -0.257];
        cfg.shape_phase_rad = [0 pi/2 0 pi/2 0];
        cfg.analytic_voltage_MV = 1;
        cfg.phase_deg = 0;
    case 'uniformisation'
        cfg.variant = 'tm4610';
        cfg.bore_radius_m = 0.05;
        cfg.cell_length_m = 0.05;
        cfg.initial_momentum_MeV_c = 10;
        cfg.particle_count = 200000;
        cfg.population = 1e6;
        cfg.emittance_m_rad = 21e-6;
        cfg.beta_m = 15;
        cfg.alpha = 15;
        cfg.target_m = 1.7;
        cfg.quadrupole_start_m = 0.2;
        cfg.quadrupole_length_m = 0.3;
        cfg.quadrupole_k2_per_m = 4.25;
        cfg.reference_phase_advance_rad = 0.0678;
        cfg.reference_target_beta_m = 223;
        cfg.phase_deg = 270; % after off-axis autophasing, as in surviving code
        cfg.charge_e = 1; % surviving code convention; see PARAMETERS.md
        cfg.map_files = {fullfile('uniformisation','tm4610.dat')};
        cfg.normalise_orders = 4;
        cfg.target_g_MV_per_m = 135;
        cfg.expected_g6_over_g4 = -7.10;
        cfg.bins = 101;
        cfg.uniform_region_mm = 60;
        cfg.k4_convention = 'paper_equation';
    otherwise
        error('Azimuthal:UnknownStudy', 'Choose benchmark, coupler, or uniformisation.');
end
end
