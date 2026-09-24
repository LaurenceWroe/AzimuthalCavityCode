
function F_Make_RF_Track_Gif_Azi(B0,V,gif_name,R_max)

load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
RF_Track;

MarkSize = 2;
Za_L = 5001;
B_macro_particles = B0.size;

t0_arr = sort(B0.get_phase_space(['%t0']));
z0_arr = sort(B0.get_phase_space(['%z']));

F = glob('watch_beam.*.txt');
figure('visible','on');
CMap =  winter(256);

M = load(F{end});
X_ff = M(:,1); Px_ff =  M(:,2); Y_ff = M(:,3); Py_ff = M(:,4);
S_ff = M(:,5); Pz_ff = M(:,6); P_ff = sqrt(Px_ff.^2+Py_ff.^2+Pz_ff.^2);
P_max = ceil(max(P_ff)); E_max = sqrt(P_max^2+RF_Track.electronmass^2);
GoodBool = S_ff>0;
Angle_max = 0.2;

% Define the number of bins for histograms
nbins = 40;
scatter_colormap = cool(B_macro_particles);

for ii=1:length(F)

    if ii < 150 % Stops making gifs that are too long
        % load the i-th file
        M = load(F{ii});

        if ii == 1
            [~, SortBool] = sort(M(:,1));
        endif

        M = M(SortBool,:);


        % make the plots and save it on disk
        clf ; hold on
        S_all = M(:,5); P_all = sqrt(M(:,2).^2+M(:,4).^2+M(:,6).^2);
        X_ii = M(:,1); Px_ii =  M(:,2);
        Y_ii = M(:,3); Py_ii = M(:,4);
        S_ii = M(:,5); Pz_ii = M(:,6);
        P_ii = sqrt(Px_ii.^2+Py_ii.^2+Pz_ii.^2);
        E_ii = sqrt(P_ii.^2+RF_Track.electronmass.^2);


        x_prime = Px_ii./P_ii;

        %%% PLOT E-FIELD %%%
        fid = fopen(F{ii});
        line = fgetl(fid);
        fclose(F{ii});
        Temp1 = strfind(line,'=');
        Temp2 = strfind(line,'mm');
        t_ii = str2num(line(Temp1+1:Temp2-1));

        %%% DETERMINE LOST PARTICLES %%%
        Created = sum(t0_arr<=t_ii);
        Lost = Created-length(S_all);
        TotalLost = ((Lost+sum(S_all<0))/B_macro_particles);
        TotalAlive = 1-TotalLost;

        Za = linspace(0, V.get_length()*1e3, Za_L); % mm
        Ez_i = [];
        for Z = Za
            [E,B] = V.get_field(0, 0, Z, t_ii); % x,y,z,t (mm, mm/c)
            Ez_i = [ Ez_i ; E(3) ];
        end

        subplot(3,2,[1 2]); hold all;
        plot(S_ii,zeros(size(S_ii)),'rx','MarkerSize',2*MS)
        plot(Za,zeros(size(Za)),'k-')
        if ~isempty(V.get_quadrupoles)
            Q = V.get_quadrupoles;
            for jj = max(size(Q))
                Q_s0 = 0.2;
                Q_L = Q{jj}.get_length;
                rectangle ('Position', [Q_s0*1000, -0.5, (Q_s0+Q_L)*1000, 1],"EdgeColor",[0 0 0], "FaceColor", [0 1 0]);
            endfor
        endif
        if ~isempty(V.get_rf_elements)
            rf = V.get_rf_elements;
            for jj = max(size(rf))
                rf_s0 = 0;
                rf_L = rf{jj}.get_length();
                rectangle ('Position', [rf_s0, -0.5, rf_L*1000, 1],"EdgeColor",[0 0 0], "FaceColor", [0 0 1], "Curvature", 1.0);
            endfor
        endif
        xlim([0 V.get_length()*1000])
        xlabel('z [mm]'); set(gca,'yticklabel',[])
        set(gca,'FontSize',FS)
        grid; box on;


        subplot(3,2,3);
        scatter(X_ii, x_prime,MS/2,scatter_colormap,'x')
        xlim([-R_max R_max]); ylim([-Angle_max Angle_max])
        xlabel('x [mm]'); ylabel('x'' [rad]');
         grid; box on;
        set(gca,'Fontsize',TS)


         % Compute the 2D histogram for prime space
        histogram2d_x = zeros(nbins, nbins);
        xedges_prime = linspace(-Angle_max, Angle_max, nbins+1);
        xedges = linspace(-R_max, R_max, nbins+1);
        for i = 1:nbins
            for j = 1:nbins
                histogram2d_x(i, j) = sum(X_ii >= xedges(i) & X_ii < xedges(i+1) & ...
                                       x_prime >= xedges_prime(j) & x_prime < xedges_prime(j+1));
            end
        end
        subplot(3,2,4);
        custom_colormap = [1 1 1; viridis(255)];
        imagesc(xedges, xedges_prime, log10(histogram2d_x' + 1));  % Adding 1 to avoid log(0)
        h_x = colorbar;
        caxis([0, log10(B_macro_particles)]);
        colormap(custom_colormap);
        colorbar; box on; grid;
        xlim([-R_max R_max]); ylim([-Angle_max Angle_max])
        set(gca,'YDir','normal')
        ytick = get (h_x, "ytick");
        set (h_x, "yticklabel", sprintf ("10^{%g}|", ytick),'Fontsize',TS);
        xlabel('x [mm]'); ylabel('x'' [rad]');
        set(gca,'Fontsize',TS)

        subplot(3,2,[5 6]); hold all;
        N  = 101;
        bin_factor = 1.5;
        bins_optim = linspace(-bin_factor*R_max,bin_factor*R_max,N);
        if ii == 1
              h_temp = hist(X_ii,bins_optim);
              h_norm = sum(h_temp)/h_temp((N-1)/2+1);
        endif
        h = hist(X_ii,bins_optim,h_norm);
        h = h(2:end-1); bins_optim = bins_optim(2:end-1);
        plot(bins_optim,h,'LineWidth',LW)
        xlabel('x [mm]')
        ylabel('Intensity [Arb.]');
        box on; grid;
        ylim([0 1.6]); xlim([-bin_factor*R_max bin_factor*R_max]);
        set(gca,'FontSize',TS)





##        % Compute the 2D histogram for prime space
##        histogram2d_prime = zeros(nbins, nbins);
##        xedges_prime = linspace(-Angle_max, Angle_max, nbins+1);
##        yedges_prime = linspace(-Angle_max, Angle_max, nbins+1);
##        x_prime = Px_ii./P_ii; y_prime = Py_ii./P_ii;
##        for i = 1:nbins
##            for j = 1:nbins
##                histogram2d_prime(i, j) = sum(x_prime >= xedges_prime(i) & x_prime < xedges_prime(i+1) & ...
##                                        y_prime >= yedges_prime(j) & y_prime < yedges_prime(j+1));
##            end
##        end
##        subplot(2,2,3);
##        custom_colormap = [1 1 1; viridis(255)];
##        imagesc(xedges_prime, yedges_prime, log10(histogram2d_prime' + 1));  % Adding 1 to avoid log(0)
##        h_prime = colorbar;
##        caxis([0, log10(B_macro_particles)]);
##        colormap(custom_colormap);
##        colorbar; box on;
##        ytick = get (h_prime, "ytick");
##        set (h_prime, "yticklabel", sprintf ("10^{%g}|", ytick),'Fontsize',TS);
##        xlabel('x'' [rad]'); ylabel('y'' [rad]');
##        set(gca,'Fontsize',TS)
##
        % Compute the 2D histogram for position space
##        histogram2d = zeros(nbins, nbins);
##        xedges = linspace(-R_max, R_max, nbins+1);
##        yedges = linspace(-R_max, R_max, nbins+1);
##        for i = 1:nbins
##            for j = 1:nbins
##                histogram2d(i, j) = sum(X_ii >= xedges(i) & X_ii < xedges(i+1) & ...
##                                        Y_ii >= yedges(j) & Y_ii < yedges(j+1));
##            end
##        end
##        subplot(2,2,1);
##        imagesc(xedges, yedges, log10(histogram2d' + 1));  % Adding 1 to avoid log(0)
##        h = colorbar;
##        caxis([0, log10(B_macro_particles)]);
##        colormap(custom_colormap);
##        colorbar; box on;
##        ytick = get (h, "ytick");
##        set (h, "yticklabel", sprintf ("10^{%g}|", ytick),'Fontsize',TS);
##        xlabel('x [mm]'); ylabel('y [mm]');
##        set(gca,'Fontsize',TS)


        Title = (['t = ' num2str(t_ii,'%0.1f') ' [mm/c], <P> = ' num2str(mean(P_all),'%0.1f') ' ± ' num2str(std(P_all),'%0.1f')  'MeV/c, Lost = ' num2str((TotalLost*100),'%0.1f') ' %']);
        axes( 'visible', 'off', 'title', Title,'Fontsize',FS);


        % save the plot on disk as a png file
        print ('-dpng', '-S800,600', '-F:14', sprintf('pngs/frame_%05d.png', ii));

    end
end

% create the gif
##system(["convert -delay 25 -loop 1 pngs/*.png gifs/" gif_name ".gif"]);
system(["convert -delay 10 -loop 1 pngs/*.png gifs/" gif_name ".gif"]);
% delete the watch_beam and png files
system('rm -f watch_beam.*.txt');
system('rm -f pngs/*.png');
end
