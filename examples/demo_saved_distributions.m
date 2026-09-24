function results = demo_saved_distributions(make_plot)
% Display saved research distributions; this does not rerun tracking.
if nargin < 1, make_plot = true; end
root = fileparts(fileparts(mfilename('fullpath')));
folder = fullfile(root, 'research', 'RF_Track', 'Scripts', 'uniform_beam', 'Dist');
names = {'TwoPill', 'TM4610_6_7'};
if make_plot, figure; hold on; end
for n = 1:numel(names)
    s = load(fullfile(folder, [names{n} '.m']));
    results(n).name = names{n};
    results(n).x_mm = s.bins_optim;
    results(n).counts = s.h;
    mid = (numel(s.h)+1)/2;
    results(n).relative_density = s.h/mean(s.h(mid-3:mid+1));
    if make_plot
        plot(s.bins_optim, results(n).relative_density, 'LineWidth', 1.5, ...
             'DisplayName', names{n});
    end
end
if make_plot
    xlabel('x [mm]'); ylabel('Relative intensity'); grid on;
    key = legend('show'); set(key, 'interpreter', 'none');
    title('Saved research distributions');
end
end
