

% main.m
% Tracking code to optimise the field for a uniform beam

%% Init RF-track
clear all; close all;
RF_Track;
c = RF_Track.clight;

%% Load packages, paths and other variables
pkg load statistics
addpath(genpath('/Users/wroe/cernbox2/Code/RF_Track/Components/'))
addpath(genpath('/Users/wroe/cernbox2/Code/RF_Track/Functions/'))
load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
DispSpec = '%0.1f';

RF_Track;

RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps/TM210/';
RF_File = 'TM210.dat';
LPipe = 0.06; LM = 0.02;
##LPipe = 0.04; LM = 0.04;

load(fullfile(RF_Folder,RF_File));

a3_orig = a3;
##a3 = a3_orig*2;

##E1_Mat(PipeBool) = 0;
##E2_Mat(PipeBool) = 0;
##E3_Mat(PipeBool) = 0;
##B1_Mat(PipeBool) = 0;
##B2_Mat(PipeBool) = 0;
##B3_Mat(PipeBool) = 0;

SF = 1;

E1_Mat = E1_Mat*SF;
E2_Mat = E2_Mat*SF;
E3_Mat = E3_Mat*SF;
B1_Mat = B1_Mat*SF;
B2_Mat = B2_Mat*SF;
B3_Mat = B3_Mat*SF;

freq_rf = 3.08351e9;
##freq_rf = 3.04173e9;
freq_rf = 2.94383e9;

krf = 2*pi*freq_rf/RF_Track.clight;

##    M = RF_FieldMap_CINT(E1_Mat, E2_Mat, E3_Mat, ...
##                     B1_Mat, B2_Mat,  B3_Mat, ...
M = RF_FieldMap_CINT(E1_Mat, E2_Mat, E3_Mat, ...
                 B1_Mat, B2_Mat,  B3_Mat, ...
##    M = RF_FieldMap_CINT(imag(E1_Mat), imag(E2_Mat), imag(E3_Mat), ...
##                     imag(B1_Mat), imag(B2_Mat),  imag(B3_Mat), ...
                 loc_x*1e-3,  loc_y*1e-3, ... % this is bottom left corner of mesh, m
                 d1*1e-3, ... % dx, m
                 d2*1e-3, ... % dy, m
                 d3*1e-3, ... % dz, m
                 -1, ... % take the default size
                 freq_rf,%freq_rf*1e9,... freq in Hz
                 +1);% standing wave
M.set_odeint_algorithm('rk2');
##M.set_phi((90*(1-LM/(2*RF_Track.clight/freq_rf)))*pi/180); M.set_t0(0);


### ANALYSE WITH TIME OFFSET
M.set_phid(0);

X_offset1 = linspace(0,14.4687,11);
X_offset2 = linspace(14.4687,38.247,11);
X_offsets = [X_offset1 X_offset2];
X_offsets = 0*14.14687;
N = 2001;
T_Vary = linspace(0,2*a3(1,1,end),N);
T_Static = zeros(1,N);

Y = zeros(1,N);
Z = linspace(0,2*a3(1,1,end),N);

Pz_Vary = zeros(1,length(X_offsets));
Pz_Static = zeros(1,length(X_offsets));

figure(); hold all;
for ii = 1:length(X_offsets)


      X = ones(1,N)*X_offsets(ii);

      M.set_t0(0);
      [E_Static,B_Static] = M.get_field(X,Y,Z,T_Static);
      Ez_RF_Static = E_Static(:,3);
      Pz_Static(ii) = trapz(Z/1000,Ez_RF_Static);

      M.set_t0(-17.5);
      [E_Vary,B_Vary] = M.get_field(X,Y,Z,T_Vary);
      Ez_RF_Vary = E_Vary(:,3);
      Pz_Vary(ii) = trapz(Z/1000,Ez_RF_Vary);

      subplot(2,2,1); hold all;
      plot(Z,Ez_RF_Static/1e6,'-')

      subplot(2,2,2); hold all;
      plot(Z,Ez_RF_Vary/1e6,'-')

end

subplot(2,2,3); hold all
plot(X_offsets,Pz_Static/1e6)
##plot(linspace(0,14.4687,6),[2.807, 2.7804, 2.7085,2.5895,2.4269,2.223],'rx')
grid; box;
xlabel('x_{offset} [mm]'); ylabel('\Delta p_z [MeV/c]')


subplot(2,2,4); hold all
plot(X_offsets,Pz_Vary/1e6)
##plot(linspace(0,14.4687,6),[1.6025,1.6028,1.6034,1.6050,1.6085,1.6185],'rx')
xlabel('x_{offset} [mm]'); ylabel('\Delta p_z [MeV/c]')
grid; box;

mathematica = linspace(0,160,202);
on1 = [0.0000151578, 0.000017123, 0.0000193421, 0.0000218491, 0.0000246819, \
0.0000278821, 0.0000314963, 0.0000355785, 0.0000401908, 0.0000454016, \
0.0000512875, 0.0000579356, 0.0000654456, 0.00007393, 0.0000835148, \
0.0000943414, 0.000106571, 0.000120386, 0.000135994, 0.000153625, \
0.000173541, 0.000196039, 0.000221455, 0.000250167, 0.000282602, \
0.000319242, 0.000360634, 0.000407395, 0.000460223, 0.000519903, \
0.000587325, 0.000663496, 0.000749555, 0.000846786, 0.000956643, \
0.00108077, 0.00122103, 0.00137952, 0.00155863, 0.00176105, \
0.00198985, 0.00224848, 0.00254088, 0.00287151, 0.00324542, \
0.0036684, 0.004147, 0.00468872, 0.00530211, 0.00599697, 0.00678458, \
0.00767789, 0.0086919, 0.00984402, 0.0111546, 0.0126473, 0.0143505, \
0.0162976, 0.0185289, 0.0210933, 0.0240509, 0.0274766, 0.0314649, \
0.0361377, 0.0416552, 0.0482324, 0.0561662, 0.0658784, 0.0779891, \
0.0934469, 0.113768, 0.141499, 0.181117, 0.240662, 0.333197, \
0.469012, 0.624299, 0.749537, 0.832384, 0.885889, 0.921914, 0.947417, \
0.96627, 0.980699, 0.992045, 1.00116, 1.00859, 1.01474, 1.01986, \
1.02416, 1.02778, 1.03084, 1.03341, 1.03557, 1.03737, 1.03884, \
1.04003, 1.04095, 1.04163, 1.04207, 1.04229, 1.04229, 1.04207, \
1.04163, 1.04095, 1.04003, 1.03884, 1.03737, 1.03557, 1.03341, \
1.03084, 1.02778, 1.02416, 1.01986, 1.01474, 1.00859, 1.00116, \
0.992045, 0.980699, 0.96627, 0.947417, 0.921914, 0.885889, 0.832384, \
0.749537, 0.624299, 0.469012, 0.333197, 0.240662, 0.181117, 0.141499, \
0.113768, 0.0934469, 0.0779891, 0.0658784, 0.0561662, 0.0482324, \
0.0416552, 0.0361377, 0.0314649, 0.0274766, 0.0240509, 0.0210933, \
0.0185289, 0.0162976, 0.0143505, 0.0126473, 0.0111546, 0.00984402, \
0.0086919, 0.00767789, 0.00678458, 0.00599697, 0.00530211, \
0.00468872, 0.004147, 0.0036684, 0.00324542, 0.00287151, 0.00254088, \
0.00224848, 0.00198985, 0.00176105, 0.00155863, 0.00137952, \
0.00122103, 0.00108077, 0.000956643, 0.000846786, 0.000749555, \
0.000663496, 0.000587325, 0.000519903, 0.000460223, 0.000407395, \
0.000360634, 0.000319242, 0.000282602, 0.000250167, 0.000221455, \
0.000196039, 0.000173541, 0.000153625, 0.000135994, 0.000120386, \
0.000106571, 0.0000943414, 0.0000835148, 0.00007393, 0.0000654456, \
0.0000579356, 0.0000512875, 0.0000454016, 0.0000401908, 0.0000355785, \
0.0000314963, 0.0000278821, 0.0000246819, 0.0000218491, 0.0000193421, \
0.000017123, 0.0000151578];
subplot(2,2,1); hold all;
plot(mathematica,on1/max(on1)*max(Ez_RF_Static)/1e6,'r')
xlim([0 Z(end)])
grid; box;
xlabel('z [mm]'); ylabel('E_z [MV/m]')

off_phase = 0.08/RF_Track.clight*freq_rf;
off_phase = 1/1.115;
timearray = cos(2*pi*freq_rf*(mathematica/1000)/RF_Track.clight+1/off_phase);
subplot(2,2,2); hold all;
plot(mathematica,on1/max(on1)*max(Ez_RF_Static)/1e6.*timearray)
xlim([0 Z(end)])
grid; box;
xlabel('z [mm]'); ylabel('E_z [MV/m]')



##      for jj = linspace(-200,200,41)
##      title(num2str(jj))
##
##  end


