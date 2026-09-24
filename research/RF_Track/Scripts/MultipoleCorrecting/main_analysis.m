

% main.m
% Tracking code to optimise the field for a uniform beam

%% Init RF-track
clear all; close all;
RF_Track;
pkg load statistics;
c = RF_Track.clight;

%% Load packages, paths and other variables
addpath(genpath('/Users/wroe/cernbox2/Code/RF_Track/Components/'))
addpath(genpath('/Users/wroe/cernbox2/Code/RF_Track/Functions/'))
load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
DispSpec = '%0.1f';

### DEFINE BEAMLINE ###

%% Tracking variables
population = 1e6; % particles
nParticles = population/1000;

%% Fixed variables
mass = RF_Track.electronmass;
charge = -1;

%% Varying variables
Pref = 10*mass;
std_r = 1; B_time = 0;
freq_rf = 3;
B_time = 0; % Makes the bunch one rf period long
r_beam = 2; % [mm]
rings = 11; p_per_ring = 30; % Macro_part = product+1

%% Useful derived quantities
Eref = sqrt(Pref^2+mass^2);
gammaref = Eref./mass;
betaref =sqrt(1-1/gammaref^2);


%% Plotting Parameters %%
FigNo = 1;

%% Define RF Cavity %%
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/CouplerUncorrected/';
%RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/NoCoupler/';
RF_File = '0_3_Steps.dat';

RF_Struct = load(fullfile(RF_Folder,RF_File));

# scale on-axis to 10 MV/m
SizeMat = size(RF_Struct.a1);
MaxEz_OnAxis = max(real(RF_Struct.E3_Mat((SizeMat(1)+1)/2,(SizeMat(1)+1)/2,:)));
SF = 10e6/MaxEz_OnAxis;

RF_Cav = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*SF, real(RF_Struct.E2_Mat)*SF, real(RF_Struct.E3_Mat)*SF, ...
                 1i*imag(RF_Struct.B1_Mat)*SF, 1i*imag(RF_Struct.B2_Mat)*SF,  1i*imag(RF_Struct.B3_Mat)*SF, ...
                 RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                 RF_Struct.d1*1e-3, ... % dx, m
                 RF_Struct.d2*1e-3, ... % dy, m
                 RF_Struct.d3*1e-3, ... % dz, m
                 -1, ... % take the default size
                 freq_rf*1e9,... freq in Hz
                 +1);% standing wave

%RF_Cav.set_phid(90);
%RF_Cav.set_odeint_algorithm('rk2');
%RF_Cav.set_t0(0.0);
##PlotBool = 0;
##if PlotBool == true
##    figure(); hold all;
##    Xa = linspace(0,11,21)
##    Za = linspace(RF_Cav.get_z0*1000, RF_Cav.get_z1*1000, 5001);
##    for ii = 1:length(Xa)
##        X = Xa(ii)*ones(1,length(Za));
##        %[E,B] = RF_Cav.get_field(X, 0, Za, 0); % x,y,z,t (mm, mm/c)
##        [E,B] = RF_Cav.get_field(X, X, Za, Za); % x,y,z,t (mm, mm/c)
##        Ez = E(:,3);
##        plot(Za,Ez,'Displayname',[num2str(X(1)) ' mm, ' num2str(trapz(Za,Ez)/1e6,4) ' MeV'])
##    endfor
##    legend('show')
##end
%RF_Cav.unset_t0();

%%%%% Build distribution %%%%%

B = Load_ConcentricBeam(rings,p_per_ring,r_beam,gammaref,B_time);

B = Load_Multipole_Beam(population,B_time,gammaref,std_r);
B0 = Bunch6d(mass, nParticles, charge, B);

%% Build beamline %%

# Set initial drift space
D0L = 0; # 1 m long
D0 = Drift(D0L);
D0.set_tt_nsteps(round(D0L*100)); # tt every 10 mm

RF_Cav.set_tt_nsteps(round(RF_Cav.get_length*1000)); # tt every 1 mm

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

L{2}.get_t0

theta_arr = [0 pi/2 pi 3*pi/4]; PlotEBool = 0;
%theta_arr = 0; PlotEBool = 1;
colours = jet(length(theta_arr));
PlotBool = 1;  count = 0;
if PlotBool == true
    L{2}.set_phid(0)

    for theta = theta_arr
        count = count+1;
        Xa = linspace(0,11,12);
        V = zeros(1,12);
        V_t = zeros(1,12);
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

return

for phid = -20:5:20
  L{2}.set_phid(phid)
  %L(2).get_t0()
  L.track(P_i).get_phase_space('%P')
end



% Lattice tracking
B1 = L.track(B0);

% Extract lattice parameters
%T_lattice = L.get_transport_table('%S %beta_x %beta_y'); % [beta = m]
TT = L.get_transport_table('%S %sigma_x %sigma_y %mean_E %mean_x %mean_y %sigma_t'); %[sigma = mm]


figure(3);
subplot(2,2,1); hold all; plot(TT(:,1),TT(:,2),'Displayname','x'); plot(TT(:,1),TT(:,3),'Displayname','y'); xlabel('z [mm]'); ylabel('\sigma [mm]');
subplot(2,2,2); hold all; plot(TT(:,1),TT(:,5),'Displayname','x'); plot(TT(:,1),TT(:,6),'Displayname','y'); xlabel('z [mm]'); ylabel('\Delta [mm]');


M0 = B0.get_phase_space("%S %E %x %Px %y %Py %Pc %t %Pz");
figure(1); clf;
subplot(2,2,1); plot(M0(:,3),M0(:,5),'x'); xlabel('x [mm]'); ylabel('y [mm]');
subplot(2,2,2); plot(M0(:,4),M0(:,6),'x'); xlabel('Px [MeV/c]'); ylabel('Py [MeV/c]');
subplot(2,2,3); plot(M0(:,8),M0(:,7),'x'); xlabel('t [mm/c]'); ylabel('P [MeV/c]');
subplot(2,2,4); plot(M0(:,1),M0(:,9),'x'); xlabel('z [mm]'); ylabel('Pz [MeV/c]');

M1 = B1.get_phase_space("%S %E %x %Px %y %Py %Pc %t %Pz");
figure(2);
subplot(2,2,1); plot(M1(:,3),M1(:,5),'x'); xlabel('x [mm]'); ylabel('y [mm]');
subplot(2,2,2); plot(M1(:,4),M1(:,6),'x'); xlabel('Px [MeV/c]'); ylabel('Py [MeV/c]');
subplot(2,2,3); plot(M1(:,8),M1(:,7),'x'); xlabel('t [mm/c]'); ylabel('P [MeV/c]');
subplot(2,2,4); plot(M1(:,1),M1(:,9),'x'); xlabel('z [mm]'); ylabel('Pz [MeV/c]');


