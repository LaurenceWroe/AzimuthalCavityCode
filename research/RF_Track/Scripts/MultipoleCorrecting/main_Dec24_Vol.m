

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
r_beam = 5; % [mm]
rings = 1; p_per_ring = 180; % Macro_part = product+1

FigNo = 10;
RF_Phase = 90; % KEEP THIS ZERO FOR NOW does two tests - X and X + 90
gif_name = [num2str(RF_Phase) '_phase'];

colour_RFT = autumn(rings); colour_TLL = winter(rings); colour_PW = bone(rings);

%% Useful derived quantities
Eref = sqrt(Pref^2+mass^2);
gammaref = Eref./mass;
betaref =sqrt(1-1/gammaref^2);


%% Define RF Cavity %%
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/CouplerCorrected/';
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/CouplerUncorrected/';
%RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/NoCoupler/';
RF_File = '0_3_Steps.dat';

RF_Struct = load(fullfile(RF_Folder,RF_File));

# scale on-axis to 10 MV/m
SizeMat = size(RF_Struct.a1);
MaxEz_OnAxis = max(abs(real(RF_Struct.E3_Mat((SizeMat(1)+1)/2,(SizeMat(1)+1)/2,:))));
SF = 100e6/MaxEz_OnAxis;

RF_Cav = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*SF, real(RF_Struct.E2_Mat)*SF, real(RF_Struct.E3_Mat)*SF, ...
                 1i*imag(RF_Struct.B1_Mat)*SF, 1i*imag(RF_Struct.B2_Mat)*SF,  1i*imag(RF_Struct.B3_Mat)*SF, ...
                 RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                 RF_Struct.d1*1e-3, ... % dx, m
                 RF_Struct.d2*1e-3, ... % dy, m
                 RF_Struct.d3*1e-3, ... % dz, m
                 -1, ... % take the default size
                 freq_rf*1e9,... freq in Hz
                 +1);% standing wave
RF_Cav.set_odeint_algorithm('rk2');

##RF_Cav = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*SF, real(RF_Struct.E2_Mat)*SF, real(RF_Struct.E3_Mat)*SF, ...
##                 0*imag(RF_Struct.B1_Mat)*SF, 0*imag(RF_Struct.B2_Mat)*SF,  0*imag(RF_Struct.B3_Mat)*SF, ...
##                 RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
##                 RF_Struct.d1*1e-3, ... % dx, m
##                 RF_Struct.d2*1e-3, ... % dy, m
##                 RF_Struct.d3*1e-3, ... % dz, m
##                 -1, ... % take the default size
##                 freq_rf*1e9,... freq in Hz
##                 +1);% standing wave
##RF_Cav.set_odeint_algorithm('rk2');

##RF_Cav = RF_FieldMap_CINT(1e-6*real(RF_Struct.E1_Mat)*SF, 1e-6*real(RF_Struct.E2_Mat)*SF, 1e-6*real(RF_Struct.E3_Mat)*SF, ...
##                 1i*imag(RF_Struct.B1_Mat)*SF, 1i*imag(RF_Struct.B2_Mat)*SF,  1i*imag(RF_Struct.B3_Mat)*SF, ...
##                 RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
##                 RF_Struct.d1*1e-3, ... % dx, m
##                 RF_Struct.d2*1e-3, ... % dy, m
##                 RF_Struct.d3*1e-3, ... % dz, m
##                 -1, ... % take the default size
##                 freq_rf*1e9,... freq in Hz
##                 +1);% standing wave
##RF_Cav.set_odeint_algorithm('rk2');


%%%%% Build distribution %%%%%
nParticles = rings*p_per_ring;
B = Load_ConcentricBeam_2(rings,p_per_ring,r_beam,gammaref,B_time);

B0 = Bunch6d(mass, nParticles, charge, B);



% Create lattice
V = Volume();
V.add(RF_Cav,0,0,0);

V{1}.set_phid(RF_Phase)
% Define tracking
V.odeint_algorithm = 'rk2'; % 'rkf45', 'leapfrog', ...
V.dt_mm = 0.1; % mm/c. Tracking step calc every dt_rat of a degree
V.wp_basename =  'watchbeams/watch_beam';;
V.wp_dt_mm =  1;

% Undertake an autophasing
P_i = Bunch6d (mass, 1, charge, [0,0,0,0,0,Pref]);
P_f = V.autophase(P_i);

% Make a time array
T_arr = linspace(0,2*pi,p_per_ring+1);
T_arr = T_arr(1:end-1);

% Lattice tracking
B1 = V.track(B0);



return
F_Make_RF_Track_Gif_Multi_Dec24(B0,V,gif_name,T_arr,mass,RF_Phase)
return



