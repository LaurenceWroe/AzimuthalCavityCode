
function F_Make_RF_Track_Gif_Multi_Dec24(B0,V,gif_name,T_arr,mass,RF_Phase)

load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
RF_Track;

MarkSize = 2;
Za_L = 5001;
B_macro_particles = B0.size;

t0_arr = sort(B0.get_phase_space(['%t0']));
z0_arr = sort(B0.get_phase_space(['%z']));

F = glob('watchbeams/watch_beam.*.txt');
figure('visible','on');
CMap =  winter(256);

M_0 = B0.get_phase_space("%S %E %x %Px %y %Py %Pc %t %Pz");
X_0 = M_0(:,3); Px_0 =  M_0(:,4); Y_0 = M_0(:,5); Py_0 = M_0(:,6);
S_0 = M_0(:,1); Pz_0 = M_0(:,9); P_0 = sqrt(Px_0.^2+Py_0.^2+Pz_0.^2);
E_0 = M_0(:,2);
R_0 = sqrt(X_0.^2+Y_0.^2);
gamma_0 = E_0./mass;
beta_0 =sqrt(1-1/gamma_0.^2);
beta_z_0 = Pz_0./gamma_0/mass;

M_0_wp = load(F{1});
X_0_wp = M_0_wp(:,1); Px_0_wp = M_0_wp(:,2); Y_0_wp = M_0_wp(:,3); Py_0_wp = M_0_wp(:,4);
S_0_wp = M_0_wp(:,5); Pz_0_wp = M_0_wp(:,6); P_0_wp = sqrt(Px_0_wp.^2+Py_0_wp.^2+Pz_0_wp.^2);

% loop to calculate maximums
X_ii_mat = zeros(length(F),length(Px_0));
Y_ii_mat = zeros(length(F),length(Px_0));
Z_ii_mat = zeros(length(F),length(Px_0));
Px_ii_mat = zeros(length(F),length(Px_0));
Py_ii_mat = zeros(length(F),length(Px_0));
Pz_ii_mat = zeros(length(F),length(Px_0));
beta_ii_mat = zeros(length(F),length(Px_0));
beta_z_ii_mat = zeros(length(F),length(Px_0));
t_ii_mat = ones(length(F),length(Px_0));
for ii=1:length(F)
    M = load(F{ii});
    X_ii_mat(ii,:) = M(:,1); Y_ii_mat(ii,:) = M(:,3); Z_ii_mat(ii,:) = M(:,5)-mean(M(:,5));
    Px_ii_mat(ii,:) =  M(:,2); Py_ii_mat(ii,:) = M(:,4); Pz_ii_mat(ii,:) = M(:,6);
    P_ii_mat(ii,:) = sqrt(Px_ii_mat(ii,:).^2+Py_ii_mat(ii,:).^2+Pz_ii_mat(ii,:).^2);
    E_ii = sqrt(P_ii_mat(ii,:) .^2+mass.^2);
    gamma_ii = E_ii/mass;
    beta_ii_mat(ii,:) = P_ii_mat(ii,:)./gamma_ii/mass;%sqrt(1-1./gamma_ii.^2);
    beta_z_ii_mat(ii,:) = Pz_ii_mat(ii,:)./gamma_ii/mass;

    fid = fopen(F{ii});
    line = fgetl(fid);
    fclose(F{ii});
    Temp1 = strfind(line,'=');
    Temp2 = strfind(line,'mm');
    t_ii_mat(ii,:) = t_ii_mat(ii,:)*str2num(line(Temp1+1:Temp2-1));
end
R_max =  max(max(sqrt(X_ii_mat.^2+Y_ii_mat.^2)))-mean(R_0); R_min =  min(min(sqrt(X_ii_mat.^2+Y_ii_mat.^2)))-mean(R_0);
Z_max = max(max(Z_ii_mat)); Z_min = min(min(Z_ii_mat));
Px_max = max(max(Px_ii_mat))-mean(Px_0); Px_min = min(min(Px_ii_mat))-mean(Px_0);
Py_max = max(max(Py_ii_mat))-mean(Py_0); Py_min = min(min(Py_ii_mat))-mean(Py_0);
Pz_max = max(max(Pz_ii_mat))-mean(Pz_0); Pz_min = min(min(Pz_ii_mat))-mean(Pz_0);
beta_max = max(max(beta_ii_mat))-mean(beta_0); beta_min = min(min(beta_ii_mat))-mean(beta_0);
beta_z_max = max(max(beta_z_ii_mat))-mean(beta_z_0); beta_z_min = min(min(beta_z_ii_mat))-mean(beta_z_0);

% Attempt to calculate the integrated fields
##for ii = 1:length(X_0)
##    [E, B]  = V{1}.get_field(X_ii_mat(:,ii),Y_ii_mat(:,ii),Z_ii_mat(:,ii),t_ii_mat(:,ii));
##    phi_ii = atan(Y_ii_mat(:,ii)/X_ii_mat(:,ii))
##    Temp_ii_E_r = E(1).*cos(phi_ii)+E(2).sin(phi_ii);
##    F_ii_E_r = abs(Temp_ii_E_r)*sign(Temp_ii_E_r);
##    F_ii_E_r2 = sqrt(E(1).^2+E(2).^2);
##end

for ii=1:length(F)

    if ii < 151 % Stops making gifs that are too long
        % load the i-th file
        M = load(F{ii});


        % make the plots and save it on disk
        clf ; hold on
        S_all = M(:,5); P_all = sqrt(M(:,2).^2+M(:,4).^2+M(:,6).^2);
        X_ii = M(:,1); Px_ii =  M(:,2);
        Y_ii = M(:,3); Py_ii = M(:,4);
        S_ii = M(:,5); Pz_ii = M(:,6);
        R_ii = sqrt(X_ii.^2+Y_ii.^2);
        P_ii = sqrt(Px_ii.^2+Py_ii.^2+Pz_ii.^2);
        E_ii = sqrt(P_ii.^2+mass.^2);
        gamma_ii = E_ii/mass;
        beta_ii =sqrt(1-1/gamma_ii.^2);
        beta_z_ii = Pz_ii./gamma_ii/mass;


        %%% PLOT E-FIELD %%%
        fid = fopen(F{ii});
        line = fgetl(fid);
        fclose(F{ii});
        Temp1 = strfind(line,'=');
        Temp2 = strfind(line,'mm');
        t_ii = str2num(line(Temp1+1:Temp2-1));


        Za = linspace(0, V.get_length()*1e3, Za_L); % mm
        Ez_i = [];
        for Z = Za
            [E,B] = V.get_field(0, 0, Z, t_ii); % x,y,z,t (mm, mm/c)
            Ez_i = [ Ez_i ; E(3) ];
        end

        subplot(3,2,[1 2]); hold all;
        plot(S_ii,zeros(size(S_ii)),'rx','MarkerSize',2*MS)
        plot(Za,zeros(size(Za)),'k-')
        plot(Za,Ez_i/1e6,'b-')
        ylim([-10 10])
        plot([50 50], ylim,'k-')
        plot([100 100], ylim,'k-')
        xlim([0 V.get_length()*1000])
        xlabel('z [mm]'); ylabel('Ez(0,0,z) [MV/m]')
        set(gca,'FontSize',FS)
        grid; box on;

        subplot(3,2,3); hold all;
        hax = plotyy(T_arr,Pz_ii-Pz_0,T_arr,(S_ii-mean(S_ii)));
        xlabel('\theta [rad]');
        ylabel(hax(1),['\Delta Pz [MeV/c]'; ' ' ; ' ']); ylabel(hax(2),[' ' ; ' ';'z - <z> [mm]'])
        xlim([T_arr(1) T_arr(end)])
        ylim(hax(1),[Pz_min Pz_max])
        ylim(hax(2),[Z_min Z_max])
         grid; box on;

##        plot();
##        xlabel('\theta [rad]'); ylabel(['\Delta Pz [MeV/c]'; ' ' ; ' '])
##        xlim([T_arr(1) T_arr(end)])
##        ylim([Pz_min Pz_max])
##         grid; box on;

        subplot(3,2,4); hold all;
        hax = plotyy(T_arr,beta_z_ii-beta_z_0,T_arr,(R_ii-R_0));
        xlabel('\theta [rad]');
        ylabel(hax(1),['\Delta \beta_z'; ' ' ; ' ']); ylabel(hax(2),[' ' ; ' ';'\Delta r [mm]'])
        xlim([T_arr(1) T_arr(end)])
        ylim(hax(1),[beta_z_min beta_z_max])
        ylim(hax(2),[R_min R_max])
         grid; box on;

##        plot(T_arr,beta_z_ii-beta_z_0);
##        xlabel('\theta [rad]'); ylabel(['\Delta \beta_z'; ' ' ; ' '])
##        xlim([T_arr(1) T_arr(end)])
##        ylim([beta_z_min beta_z_max])
##         grid; box on;

        subplot(3,2,[5 6]); hold all;
        hax = plotyy(T_arr,(Px_ii-Px_0)*1000,T_arr,(Py_ii-Py_0)*1000);
        xlabel('\theta [rad]');
        ylabel(hax(1),['\Delta Px [keV/c]'; ' ' ; ' ']); ylabel(hax(2),[' ' ; ' ';'\Delta Py [keV/c]'])
        xlim([T_arr(1) T_arr(end)])
        ylim(hax(1),[Px_min Px_max]*1000)
        ylim(hax(2),[Py_min Py_max]*1000)
         grid; box on;

##        subplot(3,2,6); hold all;
##        plot(T_arr,(R_ii-R_0));
##        xlabel('\theta [rad]'); ylabel(['\Delta r [mm]'; ' ' ; ' '])
##        xlim([T_arr(1) T_arr(end)])
##        ylim([R_min R_max])
##         grid; box on;

        axes( 'visible', 'off', 'title', ['\phi = ' num2str(RF_Phase) '^o'],'Fontsize',16);

        % save the plot on disk as a png file
        print ('-dpng', '-S800,600', '-F:14', sprintf('pngs/frame_%05d.png', ii));

    end
end

% create the gif
##system(["convert -delay 25 -loop 1 pngs/*.png gifs/" gif_name ".gif"]);
system(["convert -delay 10 -loop 1 pngs/*.png gifs/" gif_name ".gif"]);
% delete the watch_beam and png files
system('rm -f watchbeams/watch_beam.*.txt');
system('rm -f pngs/*.png');
end
