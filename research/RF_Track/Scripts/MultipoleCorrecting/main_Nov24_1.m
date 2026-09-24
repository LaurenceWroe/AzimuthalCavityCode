

% main.m
% Tracking code to optimise the field for a uniform beam

%% Init RF-track
clear all;
close all;
RF_Track;
pkg load statistics;
c = RF_Track.clight;


%% Load packages, paths and other variables
addpath(genpath('/Users/wroe/cernbox2/Code/RF_Track/Components/'))
addpath(genpath('/Users/wroe/cernbox2/Code/RF_Track/Functions/'))
load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
DispSpec = '%0.1f';

### DEFINE BEAMLINE ###

%% Fixed variables
mass = RF_Track.electronmass;
charge = -1;

%% Varying variables
Pref = 10*mass;
freq_rf = 3;
B_time = 0; % Makes the bunch one rf period long
r_beam = 9; % [mm]
rings = 10; p_per_ring = 180; % Macro_part = product+1

FigNo = 10;
RF_Phase = [0 90]; % KEEP THIS ZERO FOR NOW does two tests - X and X + 90
FieldBool = 0; % Make 0 to turn off B field and 1 to turn off E field

colour_RFT = autumn(rings); colour_TLL = winter(rings); colour_PW = bone(rings);

%% Useful derived quantities
Eref = sqrt(Pref^2+mass^2);
gammaref = Eref./mass;
betaref =sqrt(1-1/gammaref^2);


%% Define RF Cavity %%
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/CouplerCorrected/';
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/CouplerUncorrected/';
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/NoCoupler/';
RF_File = '0_3_Steps.dat';

RF_Struct = load(fullfile(RF_Folder,RF_File));

# scale on-axis to 10 MV/m
SizeMat = size(RF_Struct.a1);
MaxEz_OnAxis = max(abs(real(RF_Struct.E3_Mat((SizeMat(1)+1)/2,(SizeMat(1)+1)/2,:))));
SF = 10e6/MaxEz_OnAxis;

if FieldBool == 0
    RF_Cav = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*SF, real(RF_Struct.E2_Mat)*SF, real(RF_Struct.E3_Mat)*SF, ...
                 0*imag(RF_Struct.B1_Mat)*SF, 0*imag(RF_Struct.B2_Mat)*SF,  0*imag(RF_Struct.B3_Mat)*SF, ...
                 RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                 RF_Struct.d1*1e-3, ... % dx, m
                 RF_Struct.d2*1e-3, ... % dy, m
                 RF_Struct.d3*1e-3, ... % dz, m
                 -1, ... % take the default size
                 freq_rf*1e9,... freq in Hz
                 +1);% standing wave
elseif FieldBool == 1
    RF_Cav = RF_FieldMap_CINT(1e-6*real(RF_Struct.E1_Mat)*SF, 1e-6*real(RF_Struct.E2_Mat)*SF, 1e-6*real(RF_Struct.E3_Mat)*SF, ...
                 1i*imag(RF_Struct.B1_Mat)*SF, 1i*imag(RF_Struct.B2_Mat)*SF,  1i*imag(RF_Struct.B3_Mat)*SF, ...
                 RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                 RF_Struct.d1*1e-3, ... % dx, m
                 RF_Struct.d2*1e-3, ... % dy, m
                 RF_Struct.d3*1e-3, ... % dz, m
                 -1, ... % take the default size
                 freq_rf*1e9,... freq in Hz
                 +1);% standing wave
else
    RF_Cav = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*SF, real(RF_Struct.E2_Mat)*SF, real(RF_Struct.E3_Mat)*SF, ...
                     1i*imag(RF_Struct.B1_Mat)*SF, 1i*imag(RF_Struct.B2_Mat)*SF,  1i*imag(RF_Struct.B3_Mat)*SF, ...
                     RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     RF_Struct.d1*1e-3, ... % dx, m
                     RF_Struct.d2*1e-3, ... % dy, m
                     RF_Struct.d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     freq_rf*1e9,... freq in Hz
                     +1);% standing wave
end

RF_Cav.set_odeint_algorithm('rk2');

%%%%% Build distribution %%%%%
nParticles = rings*p_per_ring;
B = Load_ConcentricBeam_2(rings,p_per_ring,r_beam,gammaref,B_time);

B0 = Bunch6d(mass, nParticles, charge, B);

%% Build beamline %%

# Set initial drift space
D0L = 0; # 1 m long
D0 = Drift(D0L);
D0.set_tt_nsteps(round(D0L*100)); # tt every 10 mm

RF_Cav.set_tt_nsteps(round(RF_Cav.get_length*10000)); # tt every 0.1 mm

# Set final drift space
D1L = 0; # 1 m long
D1 = Drift(D1L);
D1.set_tt_nsteps(round(D1L*100)); # tt every 10 mm

% Create lattice
L = Lattice();
L.append(D0)
L.append(RF_Cav);
L.append(D1);

% Undertake an autophasing
P_i = Bunch6d (mass, 1, charge, B(1,:));
P_f = L.autophase(P_i);
beta_z = mean(B0.get_phase_space('%Vz'));

L{2}.get_t0;

for jj = 1:length(RF_Phase)

    L{2}.set_phid(RF_Phase(jj))

    % Prep points to calculate field
    R_arr = linspace(0,r_beam,rings);
    T_arr = linspace(0,2*pi,p_per_ring+1);
    T_arr = T_arr(1:end-1);
    R_mat = repmat(R_arr(:)',length(T_arr),1)';
    T_mat = repmat(T_arr(:)',length(R_arr),1);
    X_mat = R_mat.*cos(T_mat); Y_mat = R_mat.*sin(T_mat);

    Za = linspace(L{2}.get_z0*1000, L{2}.get_z1*1000, 5001);

    Ez_t_Mod = zeros([length(R_arr) length(T_arr) length(Za)]);

    %%%% Get fields %%%%
    for ii = 1:length(Za)
        [E_field_t,B_field_t] = L{2}.get_field(X_mat(:), Y_mat(:), Za(ii), Za(ii)); % x,y,z,t (mm, mm/c)
        Ex_t = reshape(E_field_t(:,1),size(X_mat)); Ex_t_Mod(:,:,ii) = reshape(Ex_t,length(R_arr),length(T_arr));
        Ey_t = reshape(E_field_t(:,2),size(X_mat)); Ey_t_Mod(:,:,ii) = reshape(Ey_t,length(R_arr),length(T_arr));
        Ez_t = reshape(E_field_t(:,3),size(X_mat)); Ez_t_Mod(:,:,ii) = reshape(Ez_t,length(R_arr),length(T_arr));
        Bx_t = reshape(B_field_t(:,1),size(X_mat)); Bx_t_Mod(:,:,ii) = reshape(Bx_t,length(R_arr),length(T_arr));
        By_t = reshape(B_field_t(:,2),size(X_mat)); By_t_Mod(:,:,ii) = reshape(By_t,length(R_arr),length(T_arr));
        Bz_t = reshape(B_field_t(:,3),size(X_mat)); Bz_t_Mod(:,:,ii) = reshape(Bz_t,length(R_arr),length(T_arr));
     end


     %%%% Lorentz Calculation %%%%
    Delta_p_x_Lor = charge*trapz(Za/1e3,Ex_t_Mod-By_t_Mod*beta_z*c,3)/1e3; % [keV/c]
    Delta_p_y_Lor = charge*trapz(Za/1e3,Ey_t_Mod+Bx_t_Mod*beta_z*c,3)/1e3; % [keV/c]

    %%%%% PW Calculation %%%%
     V_Mat = trapz(Za/1e3,Ez_t_Mod,3); % [V]
     Delta_p_z = charge*V_Mat/1e6; % [MeV/c]

    [dFr dFt] = gradient(V_Mat',R_arr,T_arr);
     dFt = dFt./(repmat(R_arr(:)',length(T_arr),1));
     dFr = dFr'; dFt = dFt';

    dFx = dFr .*cos(T_mat)-dFt.*sin(T_mat);
    dFy = dFr .*sin(T_mat)+dFt.*cos(T_mat);

    dFx=dFx.*~isinf(dFx); % [mm]
    dFy=dFy.*~isinf(dFy); % [mm]

    % Calculation of on-axis gradient (theta undefined here so above gives NaN)
    V_X = [V_Mat(2,p_per_ring/2+1) V_Mat(1,1) V_Mat(2,1)]; X = [X_mat(2,p_per_ring/2+1) X_mat(1,1) X_mat(2,1)];
    V_Y = [V_Mat(2,3*p_per_ring/4+1) V_Mat(1,1) V_Mat(2,p_per_ring/4+1)]; Y = [Y_mat(2,3*p_per_ring/4+1) Y_mat(1,1) Y_mat(2,p_per_ring/4+1)];
    grad_x = gradient(V_X,X); grad_y = gradient(V_Y,Y);
    dFx(1,:) = grad_x(2);    dFy(1,:) = grad_y(2);

    Delta_p_x = zeros(size(Delta_p_x_Lor)); Delta_p_y = Delta_p_x;
    for ii = 1:rings
        Delta_p_x(ii,:) = -charge*1/(2*pi*freq_rf*1e9)*dFx(ii,:)*c;
        Delta_p_y(ii,:) = -charge*1/(2*pi*freq_rf*1e9)*dFy(ii,:)*c;
     end

      % Lattice tracking
      B1 = L.track(B0);

      M0 = B0.get_phase_space("%S %E %x %Px %y %Py %Pc %t %Pz");
      M1 = B1.get_phase_space("%S %E %x %Px %y %Py %Pc %t %Pz");

      delta_Pz = M1(:,9)-M0(:,9); delta_Px = M1(:,4)-M0(:,4); delta_Py = M1(:,6)-M0(:,6);
    for ii = 1:rings
        delta_Pz_ring(ii,:) = delta_Pz((ii-1)*p_per_ring+1:ii*p_per_ring);
        delta_Px_ring(ii,:) = delta_Px((ii-1)*p_per_ring+1:ii*p_per_ring);
        delta_Py_ring(ii,:) = delta_Py((ii-1)*p_per_ring+1:ii*p_per_ring);
    endfor

    % Plots the final phase space
    figure(3*FigNo+jj);
    subplot(2,2,1); plot(M1(:,3),M1(:,5),'x'); xlabel('x [mm]'); ylabel('y [mm]');
    subplot(2,2,2); plot(M1(:,4),M1(:,6),'x'); xlabel('Px [MeV/c]'); ylabel('Py [MeV/c]');
    subplot(2,2,3); plot(M1(:,8),M1(:,7),'x'); xlabel('t [mm/c]'); ylabel('P [MeV/c]');
    subplot(2,2,4); plot(M1(:,1),M1(:,9),'x'); xlabel('z [mm]'); ylabel('Pz [MeV/c]');

     % Plots first phase parameters
     figure(FigNo+jj); hold all;
     subplot(4,2,1); hold all; plot(T_arr,Delta_p_z); xlabel('\theta [rad]'); ylabel(['\Delta P_z Int [MeV/c]' ; ' '; ' ']); grid on; box on;
     subplot(4,2,2); hold all; plot(T_arr,delta_Pz_ring,'-');xlabel('\theta [rad]'); ylabel(['\Delta P_z Track [MeV/c]' ; ' '; ' ']); grid on; box on;
     subplot(4,2,3); hold all; plot(T_arr,Delta_p_x_Lor); xlabel('\theta [rad]'); ylabel(['\Delta P_x Lorentz [keV/c]' ; ' '; ' ']); grid on; box on;
     subplot(4,2,4); hold all; plot(T_arr,Delta_p_y_Lor); xlabel('\theta [rad]'); ylabel(['\Delta P_y Lorentz [keV/c]' ; ' '; ' ']); grid on; box on;
    subplot(4,2,7); hold all; plot(T_arr,1000*delta_Px_ring,'-'); xlabel('\theta [rad]'); ylabel(['\Delta P_x Track [keV/c]'; ' ' ; ' ']);grid on; box on;
    subplot(4,2,8); hold all; plot(T_arr,1000*delta_Py_ring,'-'); xlabel('\theta [rad]'); ylabel(['\Delta P_y Track [keV/c]'; ' ' ; ' ']);grid on; box on;

     figure(FigNo+3-jj);
     subplot(4,2,5); hold all; plot(T_arr, Delta_p_x'); xlabel('\theta [rad]'); ylabel(['\Delta P_x PW [keV/c]'; ' ' ; ' ']); grid on; box on;
     subplot(4,2,6); hold all; plot(T_arr, Delta_p_y'); xlabel('\theta [rad]'); ylabel(['\Delta P_y PW [keV/c]'; ' ' ; ' ']); grid on; box on;

     figure(FigNo+4);
     subplot(3,2,jj);hold all;
     h = plot(T_arr,Delta_p_z); set(h, {'color'}, num2cell(colour_TLL,2))
     h = plot(T_arr,delta_Pz_ring); set(h, {'color'}, num2cell(colour_RFT,2)); xlabel('\theta [rad]'); ylabel(['\Delta P_z [MeV/c]' ; ' '; ' ']); grid on; box on;

     subplot(3,2,2+jj); hold all;
     h = plot(T_arr,Delta_p_x_Lor); set(h, {'color'}, num2cell(colour_TLL,2));
     h = plot(T_arr,1000*delta_Px_ring); set(h, {'color'}, num2cell(colour_RFT,2)); xlabel('\theta [rad]'); ylabel(['\Delta P_x [keV/c]'; ' ' ; ' ']);
     grid on; box on;

     subplot(3,2,5-jj); hold all;
     h = plot(T_arr, Delta_p_x'); set(h, {'color'}, num2cell(colour_PW,2))

     subplot(3,2,4+jj); hold all;
     h = plot(T_arr,Delta_p_y_Lor); set(h, {'color'}, num2cell(colour_TLL,2))
     h = plot(T_arr,1000*delta_Py_ring); set(h, {'color'}, num2cell(colour_RFT,2)); xlabel('\theta [rad]'); ylabel(['\Delta P_y [keV/c]'; ' ' ; ' ']);
     grid on; box on;

     subplot(3,2,7-jj); hold all;
     h = plot(T_arr, Delta_p_y'); set(h, {'color'}, num2cell(colour_PW,2))

     %%%% RF Focusing Calculation %%%%
     Delta_p_r_RF = pi*freq_rf*1e9.*R_mat/1e3/gammaref^2/beta_z.^2/c*cosd(RF_Phase(jj)).*V_Mat/1e3;
     Delta_p_x_RF = Delta_p_r_RF.*cos(T_mat);
     Delta_p_y_RF = Delta_p_r_RF.*sin(T_mat);
     figure(FigNo+5);
     subplot(2,2,jj); plot(T_arr,Delta_p_x_RF); xlabel('\theta [rad]'); ylabel(['\Delta P_x [keV/c]'; ' ' ; ' ']); grid on; box on;
     subplot(2,2,jj+2); plot(T_arr,Delta_p_y_RF); xlabel('\theta [rad]'); ylabel(['\Delta P_y [keV/c]'; ' ' ; ' ']); grid on; box on;

end

figure(FigNo+5);
subplot(2,2,1); title(['\phi = ' num2str(RF_Phase(1)) '^o'],'FontSize',20);
subplot(2,2,2); title(['\phi = ' num2str(RF_Phase(2)) '^o'],'FontSize',20);

figure(FigNo+4);
subplot(3,2,1); title(['\phi = ' num2str(RF_Phase(1)) '^o'],'FontSize',20)
subplot(3,2,2); title(['\phi = ' num2str(RF_Phase(2)) '^o'],'FontSize',20)

figure(FigNo+1); axes( 'visible', 'off', 'title', ['\phi = ' num2str(RF_Phase(1)) '^o'],'Fontsize',16);
figure(FigNo+2); axes( 'visible', 'off', 'title', ['\phi = ' num2str(RF_Phase(2)) '^o'],'Fontsize',16);



return

% Extract lattice parameters
    %T_lattice = L.get_transport_table('%S %beta_x %beta_y'); % [beta = m]
##    TT = L.get_transport_table('%S %sigma_x %sigma_y %mean_E %mean_x %mean_y %sigma_t'); %[sigma = mm]
##    figure();
##    subplot(2,2,1); hold all; plot(TT(:,1),TT(:,2),'Displayname','x'); plot(TT(:,1),TT(:,3),'Displayname','y'); xlabel('z [mm]'); ylabel('\sigma [mm]');
##    subplot(2,2,2); hold all; plot(TT(:,1),TT(:,5),'Displayname','x'); plot(TT(:,1),TT(:,6),'Displayname','y'); xlabel('z [mm]'); ylabel('\Delta [mm]');


% Plots the initial phase space
M0 = B0.get_phase_space("%S %E %x %Px %y %Py %Pc %t %Pz");
figure(); clf;
subplot(2,2,1); plot(M0(:,3),M0(:,5),'x'); xlabel('x [mm]'); ylabel('y [mm]');
subplot(2,2,2); plot(M0(:,4),M0(:,6),'x'); xlabel('Px [MeV/c]'); ylabel(['Py [MeV/c]';' ';' ']);
subplot(2,2,3); plot(M0(:,8),M0(:,7),'x'); xlabel('t [mm/c]'); ylabel(['P [MeV/c]';' ';' ']);
subplot(2,2,4); plot(M0(:,1),M0(:,9),'x'); xlabel('z [mm]'); ylabel(['Pz [MeV/c]';' ';' ']);

PlotBool = 0; % Plots the electric field
if PlotBool == true
    %L{2}.set_t0(0);
    theta_arr = [0 pi/2 pi 3*pi/4]; PlotEBool = 0;
    %theta_arr = pi/2; PlotEBool = 1;
    colours = jet(length(theta_arr));
    count = 0;

    for theta = theta_arr
        count = count+1;
        Xa = linspace(0,10,11);
        V = zeros(1,11);
        V_t = zeros(1,11);
        Za = linspace(L{2}.get_z0*1000, L{2}.get_z1*1000, 5001);
        for ii = 1:length(Xa)
            X = Xa(ii)*ones(1,length(Za));
            [E_field,B_field] = L{2}.get_field(X*cos(theta), X*sin(theta), Za, L{2}.get_t0); % x,y,z,t (mm, mm/c)
            [E_field_t,B_field_t] = L{2}.get_field(X*cos(theta), X*sin(theta), Za, Za); % x,y,z,t (mm, mm/c)
            %[E,B] = L{2}.get_field(X, X, Za, Za-L{2}.get_t0); % x,y,z,t (mm, mm/c)
            %[E,B] = L{2}.get_field(X, 0, Za,Za+L{2}.get_t0); % x,y,z,t (mm, mm/c)
            Ez = E_field(:,3);
            V(ii) = trapz(Za,Ez)/1e9;
            Ez_t = E_field_t(:,3);
            V_t(ii) = trapz(Za,Ez_t)/1e9;
            if PlotEBool == 1
                  figure(10);
                subplot(2,1,1); hold all; plot(Za,Ez/1e6,'Displayname',[num2str(X(1)) ' mm, ' num2str(V(ii),4) ' MV'])
                subplot(2,1,2); hold all; plot(Za,Ez_t/1e6,'Displayname',[num2str(X(1)) ' mm, ' num2str(V(ii),4) ' MV'])
            end
        endfor
        if PlotEBool == 1
            figure(10);
            legend('FontSize',12); xlabel('z [mm]'); ylabel('E_z [MV/m]'); subplot(2,1,1); legend('FontSize',12); xlabel('z [mm]'); ylabel('E_z [MV/m]')
        end
        figure(11);
        subplot(2,1,1); hold all; plot(Xa,V,'Color', colours(count,:),'Displayname',['\theta = ' num2str(theta)]);
        subplot(2,1,2); hold all; plot(Xa,V_t,'Color', colours(count,:),'handlevisibility','off'); xlabel('r [mm]'); ylabel('\Delta V [MV]')
    end
    subplot(2,1,1);legend('FontSize',12);
end


