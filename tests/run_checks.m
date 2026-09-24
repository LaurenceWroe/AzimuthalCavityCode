function run_checks(include_rftrack)
% Map-free numerical and integration checks; errors stop with nonzero exit.
if nargin < 1, include_rftrack = true; end
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root); setup_paths();

r = demo_shapes(false);
expected = 2.404825557695773*299792458/(2*pi*3e9);
assert(max(abs(r(1).radius_m-expected)) < 1.1e-5, 'Pillbox radius disagrees with J0 first zero.');
for n = 1:numel(r)
    assert(numel(r(n).radius_m) == 361);
    assert(all(isfinite(r(n).radius_m)) && all(r(n).radius_m > 0));
    assert(r(n).boundary_residual < 0.002, 'Shape fails the field-zero boundary condition.');
    assert(abs(r(n).radius_m(1)-r(n).radius_m(end)) < 3e-5, 'Boundary is not closed.');
    assert(max(abs(diff(r(n).radius_m))) < 0.005, 'Unexpected root-branch jump.');
end
% Saved independent boundary export supplies a regression reference for the mixed mode.
xy = dlmread(fullfile(root,'research','MultipoleCorrecting','Shapes','QuadDip.txt'), ',');
saved_radius = sqrt(sum(xy.^2,2))/1000;
assert(numel(saved_radius) == numel(r(2).radius_m));
assert(max(abs(saved_radius-r(2).radius_m(:))) < 5e-5, 'Mixed-mode shape differs from saved research export.');
fprintf('PASS: shape solver, analytic pillbox radius, boundary residuals and saved mixed-mode shape.\n');

f = demo_saved_fields(false);
assert(all(isfinite(f.static_field_V_per_m(:))));
assert(all(diff(f.z_m) > 0));
assert(all(isfinite(f.integrated_voltage_V)));
assert(any(abs(f.integrated_voltage_V) > 0));
d = demo_saved_distributions(false);
for n = 1:numel(d)
    assert(numel(d(n).x_mm) == numel(d(n).counts));
    assert(all(isfinite(d(n).relative_density)));
    assert(all(d(n).counts >= 0) && sum(d(n).counts) > 0);
end
fprintf('PASS: retained Mathematica field profiles and saved beam distributions load.\n');

test_converter();
fprintf('PASS: asymmetric Cartesian CST conversion, complex fields, file roundtrip and grid rejection.\n');

if include_rftrack
    b = demo_rftrack_drift();
    assert(isequal(size(b.initial), [144 6]));
    assert(isequal(size(b.final), size(b.initial)));
    assert(all(isfinite(b.final(:))));
    assert(max(max(abs(b.final(:,[1 2 3 4 6])-b.initial(:,[1 2 3 4 6])))) < 1e-9);
    assert(max(abs(b.final(:,5)-b.initial(:,5)-b.expected_time_mm_c)) < 1e-8);
    fprintf('PASS: original concentric-beam helper and RF-Track drift conserve momenta/positions; flight time agrees.\n');
else
    fprintf('SKIP: RF-Track runtime check was explicitly disabled.\n');
end
fprintf('Map-free checks complete. Full cavity tracking and CST/Mathematica execution are NOT validated here.\n');
end

function test_converter()
folder = tempname(); mkdir(folder);
cleanup = onCleanup(@() rmdir(folder, 's'));
[x,y,z] = ndgrid([-2 0 2], [-6 -3 0 3 6], [0 4]);
coords = [x(:) y(:) z(:)];
n = numel(x); values = (1:n)';
e = [coords values -values 2*values -2*values 3*values -3*values];
h = [coords 4*values -4*values 5*values -5*values 6*values -6*values];
efile = fullfile(folder,'e.txt'); hfile = fullfile(folder,'h.txt');
outfile = fullfile(folder,'field.dat');
write_export(efile,e(end:-1:1,:));
write_export(hfile,h([2:end 1],:));
map = convert_cst_fields(efile,hfile,outfile);
assert(isequal(size(map.a1),[3 5 2]));
assert(map.loc_x == -2 && map.loc_y == -6);
assert(isequal([map.d1 map.d2 map.d3],[2 3 4]));
assert(isequal(map.E3_Mat(:),complex(3*values,-3*values)));
assert(max(abs(map.B2_Mat(:)-4*pi*1e-7*complex(5*values,-5*values))) < 1e-15);
roundtrip = load(outfile);
assert(isequal(map,roundtrip));
expect_error(@() convert_cst_fields(efile,hfile,outfile), 'Azimuthal:OutputExists');
wall_e=e; wall_e(1,4)=NaN; write_export(efile,wall_e);
wall_map=convert_cst_fields(efile,hfile);
assert(isnan(wall_map.E1_Mat(1)), 'Conductor NaN was not preserved.');
write_export(efile,e);
h(1,1) = -1;
write_export(hfile,h);
expect_error(@() convert_cst_fields(efile,hfile), 'Azimuthal:GridMismatch');
write_export(efile,e(2:end,:)); write_export(hfile,e(2:end,:));
expect_error(@() convert_cst_fields(efile,hfile), 'Azimuthal:IncompleteGrid');
end

function write_export(path, data)
fid = fopen(path,'w');
fprintf(fid,'x y z ReX ImX ReY ImY ReZ ImZ\n--------------------------------\n');
fprintf(fid,'%.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g\n',data');
fclose(fid);
end

function expect_error(callback, identifier)
try
    callback();
catch err
    assert(strcmp(err.identifier, identifier), ['Unexpected error: ' err.message]);
    return;
end
error('Expected error was not raised: %s', identifier);
end
