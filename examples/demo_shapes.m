function results = demo_shapes(make_plot)
% Run the collected root-tracking algorithm with explicit 3 GHz cases.
if nargin < 1, make_plot = true; end
c = 299792458; f = 3e9; k = 2*pi*f/c;
names = {'pillbox', 'mixed_012', 'correction_iteration_5'};
orders = {0, [0 1 2], [0 1 2 3 4]};
amplitudes = {1, [1 1 1], [1 0.0304 0.0363 -0.0802 -0.257]};
phases = {0, [0 0 0], [0 pi/2 0 pi/2 0]};
% Correction coefficients copied from FastShapeSolver.m, iteration 5.
% These are unscaled boundary solutions, not frequency-tuned CST models.
for n = 1:numel(names)
    [r, theta] = F_AziShapeCalc_Fast(f, 1, 32/k, orders{n}, ...
                                   amplitudes{n}, phases{n}, 1);
    residual = zeros(size(r));
    for j = 1:numel(orders{n})
        residual = residual + amplitudes{n}(j)*besselj(orders{n}(j), k*r).* ...
                   cos(orders{n}(j)*theta+phases{n}(j));
    end
    results(n).name = names{n};
    results(n).radius_m = r;
    results(n).theta_rad = theta;
    results(n).boundary_residual = max(abs(residual));
    fprintf('%s: radius %.4f..%.4f mm; boundary residual %.3g\n', ...
            names{n}, min(r)*1000, max(r)*1000, results(n).boundary_residual);
end
if make_plot
    figure; hold on;
    for n = 1:numel(results)
        plot(results(n).radius_m.*cos(results(n).theta_rad)*1000, ...
             results(n).radius_m.*sin(results(n).theta_rad)*1000, ...
             'DisplayName', results(n).name, 'LineWidth', 1.5);
    end
    axis equal; grid on; xlabel('x [mm]'); ylabel('y [mm]');
    key = legend('show'); set(key, 'interpreter', 'none');
    title('Unscaled cavity boundaries at 3 GHz');
end
end
