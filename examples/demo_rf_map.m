function result=demo_rf_map()
% End-to-end map validation, native RF element construction and tracking.
root=fileparts(fileparts(mfilename('fullpath')));
cfg=study_config('benchmark');
cfg.map_files={fullfile(root,'examples','data','tm010_demo.mat')};
cfg.initial_momentum_MeV_c=10000; cfg.radii_mm=[0 4 8];
cfg.theta_samples=24; cfg.orders=0; cfg.bore_ratios=1;
cfg.interpolation='linear'; % Exact on-axis nodes for this coarse software fixture.
cfg.pipe_length_m=0; cfg.cell_length_m=0.05;
result=run_study('benchmark','track',cfg);
map=load_field_map(cfg.map_files{1});
k=2*pi*cfg.frequency_Hz/299792458; L=map.length_m;
result.expected_on_axis_gain_MeV=map.metadata.amplitude_V_per_m*L*sin(k*L/2)/(k*L/2)/1e6;
result.measured_on_axis_gain_MeV=mean(result.runs(1,1).delta.pz(1,:));
result.description='Ideal TM010 software demo; not the mixed-mode beam-pipe benchmark from the paper.';
fprintf('Demo map: predicted axial gain %.8g, tracked %.8g MeV/c.\n', ...
        result.expected_on_axis_gain_MeV,result.measured_on_axis_gain_MeV);
end
