function result = demo_saved_fields(make_plot)
% Replot the retained Mathematica output, without the absent CST overlay.
% Adapted from research/Mathematica/plot_E2.m, lines 18-73.
if nargin < 1, make_plot = true; end
root = fileparts(fileparts(mfilename('fullpath')));
folder = fullfile(root, 'research', 'Mathematica', 'Data', 'E_m_0_1_2');
s = load(fullfile(folder, 'Z_m_16_a_10.0.mat'));
z = s.Expression1(:);
radii = 0:2:10;
fields = zeros(numel(z), numel(radii));
for n = 1:numel(radii)
    s = load(fullfile(folder, sprintf('Ez_m_16_a_10.0_r_%.1f.mat', radii(n))));
    fields(:, n) = s.Expression1(:);
end
time_fields = bsxfun(@times, fields, cos(2*pi*3e9/299792458*z));
result.z_m = z;
result.radii_mm = radii;
result.static_field_V_per_m = fields;
result.time_field_V_per_m = time_fields;
result.integrated_voltage_V = trapz(z, time_fields);
fprintf('Loaded %d retained field profiles, %d z samples each.\n', numel(radii), numel(z));
if make_plot
    figure;
    subplot(2,1,1); plot(z*1000, fields, 'LineWidth', 1.2);
    xlabel('z [mm]'); ylabel('E_z [V/m]'); grid on; xlim([-100 100]);
    title('Retained Mathematica fields (no CST comparison)');
    legend(arrayfun(@(r) sprintf('r = %g mm', r), radii, 'UniformOutput', false), 'location', 'eastoutside');
    subplot(2,1,2); plot(z*1000, time_fields, 'LineWidth', 1.2);
    xlabel('z [mm]'); ylabel('E_z(z, t=z/c) [V/m]'); grid on; xlim([-100 100]);
end
end
