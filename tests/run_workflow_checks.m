function run_workflow_checks(include_rftrack)
if nargin<1, include_rftrack=false; end
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_paths;
cfg=study_config('benchmark'); cfg.make_plot=false;
result=run_study('benchmark','analytic',cfg);
assert(numel(result.kicks)==2);
% Monopole has no transverse kick; dipole kick is independent of radius.
mono=cfg; mono.orders=0; mono.bore_ratios=1;
kicks=analytic_kicks([0 2 4],[0 pi/2],90,mono);
assert(all(kicks.px(:)==0) && all(kicks.py(:)==0));
dip=cfg; dip.orders=1; dip.bore_ratios=1;
kicks=analytic_kicks([0 2 4],[0 pi/2],90,dip);
assert(max(kicks.px(:))-min(kicks.px(:))<1e-12);
% PW derivative at crest independently checks the x/y polynomial convention.
dx=1e-3; x=3; y=2;
evalpz=@(xx,yy) analytic_kicks(hypot(xx,yy),atan2(yy,xx),0,cfg).pz;
gradx=(evalpz(x+dx,y)-evalpz(x-dx,y))/(2*dx/1000);
grady=(evalpz(x,y+dx)-evalpz(x,y-dx))/(2*dx/1000);
kicks=analytic_kicks(hypot(x,y),atan2(y,x),90,cfg);
assert(abs(kicks.px-gradx*299792458/(2*pi*cfg.frequency_Hz))<1e-9);
assert(abs(kicks.py-grady*299792458/(2*pi*cfg.frequency_Hz))<1e-9);
fprintf('PASS: analytical multipole limits and Panofsky-Wenzel derivative.\n');

u=uniformisation_config(); a=run_study('uniformisation','analytic',u);
assert(abs(a.target_radius_mm-85.570)<0.01);
u.k4_convention='legacy_script'; b=run_study('uniformisation','analytic',u);
assert(max(abs(b.g_MV_per_m./a.g_MV_per_m-2))<1e-12);
assert(abs(a.g_MV_per_m(1)-52.869)<0.01);
expect(@() uniformisation_config('bad'),'Azimuthal:UnknownVariant');
for name={'benchmark','coupler','uniformisation'}
    c=study_config(name{1}); c.map_root=tempname();
    mode='track'; if strcmp(name{1},'coupler'),mode='analyse';end
    expect(@() run_study(name{1},mode,c),'Azimuthal:MissingMap');
end
fprintf('PASS: named configurations, explicit formula conventions, actionable missing-map checks.\n');

file=fullfile(root,'examples','data','tm010_demo.mat'); map=load_field_map(file);
c=study_config('benchmark'); c.radii_mm=[0 8]; c.theta_samples=36;
v=map_voltage(map,c); L=map.length_m; k=2*pi*c.frequency_Hz/299792458;
expected=1e5*L*sin(k*L/2)/(k*L/2);
assert(max(abs(v.voltage_V(1,:)-expected))/expected<2e-6);
c=study_config('coupler'); c.labels={'demo'}; c.map_files={file};
c.radii_mm=[0 8]; c.theta_samples=36;
v=run_study('coupler','analyse',c);
assert(abs(v.cavities.on_axis_voltage_V-expected)/expected<2e-6);
assert(abs(v.cavities.cos_coeff(1,1)-1)<1e-12);
assert(max(abs(v.cavities.cos_coeff(1,2:end)))<1e-12);
fprintf('PASS: map loading, on-axis transit-time voltage and Fourier decomposition.\n');

folder=tempname(); mkdir(folder); cleaner=onCleanup(@() rmdir(folder,'s'));
p4=fullfile(folder,'m4.mat'); p6=fullfile(folder,'m6.mat');
generate_example_map(p4,4); generate_example_map(p6,6);
c=uniformisation_config('superposed');
[combined,scales,measured]=normalise_uniform_maps({load_field_map(p4),load_field_map(p6)},c);
assert(all(isfinite(scales)) && all(abs(measured)>0));
assert(all(isfinite(combined.E3_Mat(:))));
if include_rftrack
    d=demo_rf_map();
    assert(abs(d.measured_on_axis_gain_MeV/d.expected_on_axis_gain_MeV-1)<2e-4);
    % Exercise the fresh uniformisation path with small generated ideal maps.
    % This is NOT a precision/physics validation of the paper's CST cavities.
    c.map_files={p4,p6}; c.particle_count=256;
    c.target_g_MV_per_m=[0.1 -0.1]; c.step_m=1e-3;
    t=run_study('uniformisation','track',c);
    assert(t.survival_fraction>0 && all(isfinite(t.relative_density)));
    % Exercise scan dispatch separately from the fixed-momentum benchmark.
    c=study_config('benchmark'); c.map_files={file}; c.theta_samples=8;
    c.radii_mm=[0 4]; c.scan_momentum_MeV_c=[1000 10000];
    s=run_study('benchmark','scan',c);
    assert(isequal(size(s.runs),[2 2]));
    fprintf('PASS: real RF-map tracking and analytic axial gain; uniformisation and scan integration paths.\n');
else
    fprintf('SKIP: RF-Track integration checks (explicitly disabled).\n');
end
end

function expect(callback,identifier)
try, callback(); catch err, assert(strcmp(err.identifier,identifier),err.message); return; end
error('Expected %s',identifier);
end
