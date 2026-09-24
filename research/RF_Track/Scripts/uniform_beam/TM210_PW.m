

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

RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps/TM0210/';
RF_File = 'TM0210.dat';
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
##freq_rf = 2.94383e9;
freq_rf = 3.14376e9;

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
M.set_phid(180);
##app = 23.4983; r_pill = 81.25;
app = 38.03; r_pill = 81.25;
X_offset1 = linspace(0,app,11);
##X_offset2 = linspace(app,r_pill,11);
##X_offsets = [X_offset1 X_offset2];
X_offsets = X_offset1;
##X_offsets = 0*23;
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
p = polyfit (X_offsets,Pz_Static/1e6, logical ([1, 0, 0]))
plot(X_offsets,p(1)*X_offsets.^2,'--')
on2 = [0., 0.000482983, 0.00192159, 0.00428499, 0.00752246, 0.0115643, \
0.0163232, 0.0216959, 0.0275651, 0.0338016, 0.0402669];
math_offsets = linspace(0,app,11);
plot(math_offsets,on2./max(on2).*max(Pz_Static/1e6),':','linewidth',2)
##plot(linspace(0,14.4687,6),[2.807, 2.7804, 2.7085,2.5895,2.4269,2.223],'rx')
grid; box;
xlabel('x_{offset} [mm]'); ylabel('\Delta p_z [MeV/c]')


subplot(2,2,4); hold all
plot(X_offsets,Pz_Vary/1e6)
p = polyfit (X_offsets,Pz_Vary/1e6, logical ([1, 0, 0]))
plot(X_offsets,p(1)*X_offsets.^2,'--')

plot(linspace(0,14.4687,6),[1.6025,1.6028,1.6034,1.6050,1.6085,1.6185],'rx')
xlabel('x_{offset} [mm]'); ylabel('\Delta p_z [MeV/c]')
grid; box;

mathematica = linspace(0,160,202);
on1 = [0., 0.000482983, 0.00192159, 0.00428499, 0.00752246, 0.0115643, \
0.0163232, 0.0216959, 0.0275651, 0.0338016, 0.0402669];
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


