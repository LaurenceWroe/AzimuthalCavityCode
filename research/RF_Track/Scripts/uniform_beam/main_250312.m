

####### main.m
% Tracking code to insert an RF Cavity that uniformises a beam

###### PREAMBLE
%% Initialise RF-track
%clear all; %close all;
RF_Track;
c = RF_Track.clight;

%% Load packages, paths and other variables
pkg load statistics
addpath(genpath('/Users/wroe/cernbox2/Code/RF_Track/Components/'))
addpath(genpath('/Users/wroe/cernbox2/Code/RF_Track/Functions/'))
load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
DispSpec = '%0.1f';

%% Particle definition
mass = RF_Track.electronmass;
charge = 1; RF_Bool = 0;

###### USER-DEFINING PARAMETERS

%% RF Parameters
%% L-BAND
##freq_rf = 1.3e9;
##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260310_LBand_TM_410/';

%% S-BAND
freq_rf = 3e9; % [Hz]

##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260310_TM_410_LP/';

##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260310_TM_410_SBP/';

##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260310_TM_4610_5/';

##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250317_TM4610_6.7_50/';

% Load the checked ones
##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250608_TM4610_5.7/';
##SF_Load = 16.528; SF_Load_Bool = 1;

##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250608_TM4610_7.5/';
##SF_Load = -23.8249; SF_Load_Bool = 1;

RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250608_TM4610_6.7/';
SF_Load = -21.3656; SF_Load_Bool = 1;

RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250608_TM4610_6.3/';
SF_Load = 18.4388; SF_Load_Bool = 1;

RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250608_TM46810/';
SF_Load = 18.4388; SF_Load_Bool = 0;

a = 50/1000; % [m] pipe radius

##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250317_TM24610_-11_7_50/';
##a = 50/1000; % [m] pipe radius


%% Option to add another cavity
##RF_Bool = 1;
##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250226_TM_410_Pill/';
##a = 50/1000; % [m] pipe radius
##RF_Folder_2 ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250310_TM_610_Pill/';
##RF_Folder_3 ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250606_TM_810_Pill/';
##SF_Load_Bool = 1;
##SF_Load = -2.76; SF_Load_2 = -26.13;% TWO
##SF_Load = -2.71; SF_Load_2 = -35.04; SF_Load_3 = 371.9;

%% Define the number of multipoles we are optimising for
Multipoles = 2;

%% Multipole element length
LM = 0.05; % [m]. NOTE, just make this the main cavity length (not including the beam pipe)

%% Define reference momentum
Pref = 20*mass;

%% Define some plotting booleans
PlotBetaBool = true;
PlotInitialDistBool = 0;
PlotInitialFinalBool = true;

###### SPECIFY GENERAL BEAMLINE

% Specify quadrupole in lattice
Q1_s0 = 0.2; % [m], 0.22 to agree with data more
kQ1 = -4.25*charge; % [1/m], 4.25 gives accurate phase advance, 5 gives accurate beta
LQ1 = 0.3; % [m]

% Specify beamline
LBeamline = 1.7;

####### BEGIN AUTO-SCRIPTING

####### DERIVING USEFUL QUANTITIES


%% Tracking variables
population = 1e6; % particles
nParticles = population/50;

%% Beamline parameters
emitt_geo_x_0 = 21; % [mm.mrad] = geometric emittance
beta_x_0 = 15; %[m]
alpha_x_0 = 15; %[]

%% Useful derived quantities
Eref = sqrt(Pref^2+mass^2);
gammaref = Eref./mass;
betaref =sqrt(1-1/gammaref^2);
k_rf = 2*pi*freq_rf/c;

%% Load the RF File
RF_File = '0_5_Steps.dat';
RF_Struct = load(fullfile(RF_Folder,RF_File));
RF_Struct_Orig = RF_Struct;

%% Load second RF field if wanted
if RF_Bool == true
    RF_Struct_2 = load(fullfile(RF_Folder_2,RF_File));
    RF_Struct_3 = load(fullfile(RF_Folder_3,RF_File));
end

%% Plotting Parameters
FigNo = 1;
no_bins = 101;
EndBeamDist = 200; % Set the xlim for plots
sigma_max_bin = 6; % number of sigmas to plot

###### CREATE INITIAL BUNCH

%% Create particle distribution
emitt_x_0 = emitt_geo_x_0*betaref*gammaref; % RF_Track uses normalised emittance
T = Bunch6d_twiss();
T.emitt_x = emitt_x_0; % [mm.mrad], normalised horizontal emittance x.px
T.beta_x = beta_x_0; % [m], horizontal beta function
T.alpha_x = alpha_x_0;
T.emitt_y = 0; % mm.mrad, normalised vertical emittance y.py
T.beta_y = 0; % m, vertical beta function
T.alpha_y = 0;

%% Create a quasi random bunch
B0 = Bunch6d_QR (mass, population, charge, Pref, T, nParticles, sigmaCut=0);

%% Extract initial particle distribution
B0_phase = B0.get_phase_space();
X_ii = B0_phase(:,1);

%% Plot initial distribution
if PlotInitialDistBool == true
    figure(FigNo);
    Y_ii = B0_phase(:,3); t_ii = B0_phase(:,5); Px_ii = B0_phase(:,2); Py_ii = B0_phase(:,4); P_ii = B0_phase(:,6);Pz_ii = sqrt(P_ii.^2-Px_ii.^2-Py_ii.^2);
    subplot(2,2,1);
    plot(X_ii,Y_ii,'x','MarkerSize',2); xlabel('x [mm]'); ylabel('y [mm]'); axis equal;
    subplot(2,2,2);
    plot(Px_ii./Pz_ii/1000,Py_ii./Pz_ii/1000,'x','MarkerSize',2); xlabel('x'' [mrad]'); ylabel('y'' [mrad]'); axis equal;
    subplot(2,2,3);
    plot(Px_ii, Py_ii,'x','MarkerSize',2); xlabel('p_x [MeV]'); ylabel('p_y [MeV]'); axis equal;
    subplot(2,2,4);
    plot(t_ii,P_ii,'x','MarkerSize',2); xlabel('t [mm/c]'); ylabel('P [MeV]'); axis equal;
end

%% Calculate initial particle density distributions
I = B0.get_info();
sigma_0 = I.sigma_x; % [mm] extract beam size for Gaussian beam
x_0_arr = linspace(-sigma_max_bin*sigma_0,sigma_max_bin*sigma_0,10*no_bins+1); % [mm], create binning array
rho_0_arr = population/(sqrt(2*pi)*sigma_0)*exp(-x_0_arr.^2./2/sigma_0.^2); % [N], create density plot

%% Bin the initial distribution
bin_start_0 = -sigma_max_bin*sigma_0;
bin_end_0 = sigma_max_bin*sigma_0;
bins_0 = linspace(bin_start_0,bin_end_0,no_bins); % create array of bins
h_0 = hist(X_ii,bins_0,population); % get the histogram values and normalise to number of particles

%% Normalise the predicted distribution %%
% NOTE, an issue we have is that the value of the binning affects the peak.
% To overcome, plot distribution at the same central value. Adjust the prediction
rho_0_arr_plot = rho_0_arr/rho_0_arr((end-1)/2+1)*h_0((end-1)/2+1);

###### TRACK THROUGH TESTLINE
try
%% First things first, we loop through sans multipole magnet to determine Twiss parameters.
%% Easier to do this outside of the loop for now...

% Create drift space instead of multipole magnet
D0 = Drift(LM);
D0.set_tt_nsteps(LM*100); % tt every 10 mm

% Create first drift
D1L = Q1_s0-LM;
D1 = Drift(Q1_s0-LM);
D1.set_tt_nsteps(round(D1L*100)); % tt every 10 mm

% Create quadrupole
Q1 = Quadrupole(LQ1, kQ1*Pref/charge);
Q1.set_nsteps(LQ1*1000/0.1); % steps every 0.1 mm
Q1.set_tt_nsteps(LQ1*1000); % tt every 1 mm

% Create second drift
D2L = LBeamline-Q1_s0-LQ1;
D2 = Drift(D2L);
D2.set_tt_nsteps(D2L*100); % tt every 10 mm

% Create lattice
L = Lattice();
L.append(D0);
L.append(D1);
L.append(Q1);
L.append(D2);

% Lattice tracking
B1 = L.track(B0);

% Extract lattice parameters
T_lattice = L.get_transport_table('%S %beta_x %beta_y');
S_tt_def = T_lattice(:,1); beta_x_tt_def = T_lattice(:,2); beta_y_tt_def = T_lattice(:,3);
beta_x_f_def = beta_x_tt_def(end);
phase_adv_def = trapz(S_tt_def,1./beta_x_tt_def)

% Plot beta function
if PlotBetaBool == true
    figure(); hold all
    plot(S_tt_def*1000, beta_x_tt_def,'displayname',['No multipole magnet']);
    xlim([0 1.7*1000]);
    xlabel('x [mm]'); ylabel('\beta [m]');
    grid; box on;
    set(gca,'Fontsize',TS)
end
disp(['\beta_t  = '  num2str(beta_x_f_def) ', \phi_t = ' num2str(phase_adv_def)])

% Extract phase space parameters
Bf_phase = B1.get_phase_space();
X_ff_def = Bf_phase(:,1);

% Finesse parameters and prepare later plots
I_f = B1.get_info(); sigma_f = I_f.sigma_x;
x_f_arr_def = x_0_arr*sqrt(beta_x_f_def/beta_x_0)*cos(phase_adv_def); % [mm], create binning array by transforming!
rho_f_arr_def = population/(sqrt(2*pi)*sigma_0).*exp(-x_0_arr.^2./2/sigma_0.^2)./...
(sqrt(beta_x_f_def/beta_x_0)*cos(phase_adv_def)); % calculate a simple Gaussian

%% Bin the final distribution %%
bin_start_f = -sigma_max_bin*sigma_f;
bin_end_f = sigma_max_bin*sigma_f;
bins_f = linspace(bin_start_f,bin_end_f,no_bins); % create array of bins
h_f_def = hist(X_ff_def,bins_f,population); % get the histogram values and normalise to number of particles

%% Normalise the predicted distribution %%
rho_f_arr_def_plot = rho_f_arr_def/rho_f_arr_def((end-1)/2+1)*h_f_def((end-1)/2+1);

%% Plot both histograms if desired %%
if PlotInitialFinalBool == true
    figure(FigNo+1);
    subplot(1,2,1); hold all
    hist(X_ii,bins_0,population) % plot histogram
    plot(x_0_arr,rho_0_arr_plot,'r','linewidth',0.75) % plot particle distribution
    xlabel('x [mm]'); ylabel('Intensity');
    subplot(1,2,2); hold all
    hist(X_ff_def,bins_f,population) % plot histogram
    plot(x_f_arr_def,rho_f_arr_def_plot,'r','linewidth',0.75) % note both plotted against
##    plot(x_f_arr_def,rho_f_arr_Gauss_def_plot,'b--','linewidth',0.75) % plot particle distribution
    xlabel('x [mm]'); ylabel('Intensity');
end

figure(FigNo+5); hold all;
plot(bins_f,h_f_def,'linewidth',2,'Displayname', ['No Multipoles'])
end



###### DETERMINE IDEAL MAGNET PROPERTIES

%% Calculate multipoles by fitting as best as possible
Sigmas2Plot = 3;
x_0 = -Sigmas2Plot*sigma_0; Xa_L = 501; r_0 = Sigmas2Plot*sigma_0;
Xa = linspace(-a*1000, a*1000, Xa_L); % m
M_i = 4; % always going from octupole

% Set up loop and preinitiailse array
IdealLoops = 50;
g_m_ideal = []; cav_phase = pi/2;
B_ideal = zeros(1,length(Xa));
delta_p_B = zeros(1,length(Xa));
delta_p_g = zeros(1,length(Xa));

%% Begin loop to calculate ideal parameters.
% For a sanity check, we show that the change in momentum for RF cavity and multipole magnet is the same
plot_ideal_bool = true; LW = 1.5;
for ii = 1:IdealLoops
    m = (2*ii+2); % only look at even multipoles from 3 onwards
    if ii == 1 % if octupole, no recursivity.
        kNL = 2/(2*emitt_geo_x_0*1e-6*beta_x_0)/beta_x_0/tan(phase_adv_def); % calculate magnetic multipole
        MultArray = [0 kNL]; % This is the array for magnetic multipoles

        g_m_ideal_loop = Pref/charge/c*2*pi*freq_rf/LM*(k_rf*LM/2)/sin(k_rf*LM/2)*1/sin(cav_phase)*a^m/(besselj(m,k_rf*a)*factorial(m))*kNL; % [MV/m]
        g_m_ideal = [g_m_ideal g_m_ideal_loop];
    else
        kNL = -(2*ii-1)./(emitt_geo_x_0*1e-6*beta_x_0)*kNL;
        MultArray = [MultArray 0 kNL]; % further complete magnetic array

        g_m_ideal_loop = Pref/charge/c*2*pi*freq_rf/LM*k_rf*LM/2/sin(k_rf*LM/2)*1/sin(cav_phase)*a^m/(besselj(m,k_rf*a)*factorial(m))*kNL; % [MV/m]
        g_m_ideal = [g_m_ideal g_m_ideal_loop];
    end

    B_ideal_loop = Pref*1e6/charge*kNL*(Xa/1000).^(m-1)/factorial(m-1)/LM/c;
    B_ideal = B_ideal+B_ideal_loop;
    delta_p_B = delta_p_B+1e-6*charge*c*B_ideal_loop*LM; %[MeV/c]
    delta_p_g = delta_p_g+charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_ideal_loop)*besselj(m,k_rf*a)*(Xa/1000/a).^(m-1)*c;

    if plot_ideal_bool == true
      if ii == 1
        figure();  hold all;
        plot(Xa,delta_p_g,'linewidth',LW,'displayname','$m~=~4$')%,'color',colours(ii,:));
      elseif ii < 6
        plot(Xa,delta_p_g,'linewidth',LW,'displayname',['$m~\le~' num2str(m) '$'])%,'color',colours(ii,:));
    endif
    end
end

%% Add the final ideal multipole and set up plot
if plot_ideal_bool == true
    plot(Xa,delta_p_B,'k--','linewidth',LW,'displayname','$m~=~\infty$');
    plot(Xa,exp(-0.5*(Xa/sigma_0).^2),'k:','linewidth',LW,'color',[.7 .7 .7],'handlevisibility','off')
    xlabel('$x$ [mm]', 'interpreter','latex')
    ylabel('$\Delta p_\perp$ [MeV/c]', 'interpreter','latex');
    legend('location','Northoutside','orientation','horizontal','interpreter','latex','numcolumns',3);
    xlim([-a*1000,a*1000])
##    xlim([ 35 50]); ylim([ 2.5 8])
    grid; box on;
    set(gca,'FontSize',24)
    pos = get(gca, 'Position');
    set(gca, 'Position', [pos(1)+0.05 pos(2)+0.02 pos(3) pos(4)-0.02]);
end

###### DETERMINE MULTIPOLE CONTENT OF FIELD

% Create the initial field map
T_Test = RF_FieldMap_CINT(real(RF_Struct.E1_Mat), real(RF_Struct.E2_Mat), real(RF_Struct.E3_Mat), ...
                 1i*imag(RF_Struct.B1_Mat), 1i*imag(RF_Struct.B2_Mat),  1i*imag(RF_Struct.B3_Mat), ...
                 RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                 RF_Struct.d1*1e-3, ... % dx, m
                 RF_Struct.d2*1e-3, ... % dy, m
                 RF_Struct.d3*1e-3, ... % dz, m
                 -1, ... % take the default size
                 freq_rf,%freq_rf*1e9,... freq in Hz
                 +1);% standing wave
T_Test.set_t0(0);

% Plot longitudinal E and transverse B fields - Check
plot_test_field_bool = false;
if plot_test_field_bool == true
    Za = linspace(0,T_Test.get_length(),501);
    Ez_a = []; By_a = [];
    for Z = Za
        [E,B] = T_Test.get_field(a*1000, 0, Z*1000,0); % x,y,z,t (mm, mm/c)
        Ez_a = [ Ez_a ; E(3) ];

        [E,B] = T_Test.get_field(a*1000, 0, Z*1000, RF_Track.s/T_Test.get_frequency/4); % x,y,z,t (mm, mm/c)
        By_a = [ By_a ; B(2) ];
    end
    figure(); subplot(1,2,1); plot(Za,Ez_a); subplot(1,2,2); plot(Za,By_a)
end

%% Calculate multipole content at pipe
Ez_circ_T = []; Ta = linspace(0,2*pi,721);
for Ti = Ta
    a_FFT = a;
   [E,B] = T_Test.get_field(a_FFT*1000*cos(Ti), a_FFT*1000*sin(Ti), T_Test.get_length()/2*1000, 0); % x,y,z,t (mm, mm/c)
##   [E,B] = T_Test.get_field(a*1000*cos(Ti), a*1000*sin(Ti), (0.05+0.05*7/8)*1000, 0); % x,y,z,t (mm, mm/c)
    Ez_circ_T = [ Ez_circ_T ; E(3) ];
end
FFT = 2*fft(Ez_circ_T); FFT(1) = FFT(1)/2;
FFT_f = FFT(1:length(FFT)/2)/(length(FFT));
G_m_arr = sqrt(real(FFT_f).^2+imag(FFT_f).^2).*sign(real(FFT_f));
G_m_arr(5)

% Plot Ez on the bore to check
plot_bore_E_bool = false;
if plot_bore_E_bool == true
    figure(); hold all; plot(Ta,Ez_circ_T,'b')
    Ez_FFT_T = zeros(1,length(Ta));
    for ii = 1:Multipoles
        n = ii*2+2;
##        n = ii;
        Ez_FFT_T =  Ez_FFT_T+G_m_arr(n+1)*cos(n*Ta);
    end
    plot(Ta,Ez_FFT_T,'r')
    Ez_FFT_T_2 = zeros(1,length(Ta));
    for n = [2 4 6 8]

##        n = ii;
        Ez_FFT_T_2 =  Ez_FFT_T_2+G_m_arr(n+1)*cos(n*Ta);
    end
    plot(Ta,Ez_FFT_T_2, 'm')
end

% Plot Ez at different radial position to check multipole fit
a_sample = a/3;
plot_circ_E_bool = 0;
if plot_circ_E_bool == true
    Za = linspace(0,T_Test.get_length(),501);
    Ez_a = []; By_a = [];

    Ta = linspace(0,2*pi,721);
    Ez_circ_sample = [];
    for Ti = Ta
       [E,B] = T_Test.get_field(a_sample*1000*cos(Ti), a_sample*1000*sin(Ti), T_Test.get_length()/2*1000, 0); % x,y,z,t (mm, mm/c)
        Ez_circ_sample = [ Ez_circ_sample ; E(3) ];
    end

    figure(); hold all; plot(Ta,Ez_circ_sample)
    Ez_FFT = zeros(1,length(Ta));
    for ii = 1:Multipoles
        n = ii*2+2;
        Ez_FFT =  Ez_FFT+G_m_arr(n+1)*cos(n*Ta)*besselj(n,k_rf*a_sample)/besselj(n,k_rf*a);
    end
    plot(Ta,Ez_FFT)

    Ez_FFT_T_2 = zeros(1,length(Ta));
    for n = [2 4 6]
        Ez_FFT_T_2 =  Ez_FFT_T_2+G_m_arr(n+1)*cos(n*Ta)*besselj(n,k_rf*a_sample)/besselj(n,k_rf*a);
    end
    plot(Ta,Ez_FFT_T_2,':')

    Ez_FFT_T_3 = zeros(1,length(Ta));
    for n = 0:10
        Ez_FFT_T_3 =  Ez_FFT_T_3+G_m_arr(n+1)*cos(n*Ta)*besselj(n,k_rf*a_sample)/besselj(n,k_rf*a);
    end
    plot(Ta,Ez_FFT_T_3,'--')
end

% Plot Ez along the x direction to check multipole fit
plot_radial_E_bool = false;
if plot_radial_E_bool == true
    x_arr = linspace(-a,a,201);
    Ez_x_sample = [];
    for x = x_arr
       [E,B] = T_Test.get_field(x*1000, 0, T_Test.get_length()/2*1000, 0); % x,y,z,t (mm, mm/c)
        Ez_x_sample = [ Ez_x_sample ; E(3) ];
    end

    figure(); hold all; plot(x_arr,Ez_x_sample,'b')
##    p = polyfit (x_arr,Ez_x_sample, 12);
    ##    p_g_predict = polyfit (Xa,pw_track_theory, 6)

    Ez_FFT = zeros(1,length(x_arr));
    for ii = 1:Multipoles
        n = ii*2+2;
        Ez_FFT =  Ez_FFT+G_m_arr(n+1)*besselj(n,k_rf*x_arr)/besselj(n,k_rf*a);
    end
    plot(x_arr,Ez_FFT,'r')

    Ez_FFT_q = zeros(1,length(x_arr));
    for ii = 0:Multipoles
        n = ii*2+2;
        Ez_FFT_q =  Ez_FFT_q+G_m_arr(n+1)*besselj(n,k_rf*x_arr)/besselj(n,k_rf*a);
    end
    plot(x_arr,Ez_FFT_q,'c')

    Ez_FFT_Many = zeros(1,length(x_arr));
    for ii = 0:10
        n = ii;
        Ez_FFT_Many =  Ez_FFT_Many+G_m_arr(n+1)*besselj(n,k_rf*x_arr)/besselj(n,k_rf*a);
    end
    plot(x_arr,Ez_FFT_Many,'m')

    plot(x_arr,+G_m_arr(1)*besselj(0,k_rf*x_arr)/besselj(0,k_rf*a))
end


###### DETERMINE THE SCALE FACTOR NEEDED
for ii = 1:Multipoles
    n = 2*ii+2;
    g_m_arr(ii) = G_m_arr(n+1)/besselj(n,k_rf*a_FFT)*1e-6; % [MV/m]
end

for ii = 1:10
    g_m_arr_test(ii) = G_m_arr(ii)/besselj(ii-1,k_rf*a_FFT)*1e-6; % [MV/m]
end

% Create the scale factor
SF_default = g_m_ideal(1)/g_m_arr(1);

if SF_Load_Bool == false
    SF = SF_default;
else
    SF = SF_Load;
##    B0 = Bunch6d_QR (mass, population, charge, Pref, T, 200000, sigmaCut=0);
end

###### CREATE THE MULTIPOLE RF MAP
if RF_Bool == false % Simple creation of multipole field with single RF cavity

##     SF = 1.5*SF_default; % 1.25 works for TM4610_6.7_50
     M = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*SF, real(RF_Struct.E2_Mat)*SF, real(RF_Struct.E3_Mat)*SF, ...
                       1i*imag(RF_Struct.B1_Mat)*SF, 1i*imag(RF_Struct.B2_Mat)*SF,  1i*imag(RF_Struct.B3_Mat)*SF, ...
                       RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                       RF_Struct.d1*1e-3, ... % dx, m
                       RF_Struct.d2*1e-3, ... % dy, m
                       RF_Struct.d3*1e-3, ... % dz, m
                       -1, ... % take the default size
                       freq_rf,... freq in Hz
                       +1);% standing wave
      LM_RF = M.get_length();
      M.set_odeint_algorithm('rk2');
      M.set_nsteps(round(LM_RF*1000/0.1)); % [40 mm] with steps every 0.1 mm
      M.set_tt_nsteps(ceil(LM_RF*1000)); % tt every mm

else % do some processing to add the second RF field map

  T_Test_2 = RF_FieldMap_CINT(real(RF_Struct_2.E1_Mat), real(RF_Struct_2.E2_Mat), real(RF_Struct_2.E3_Mat), ...
                     1i*imag(RF_Struct_2.B1_Mat), 1i*imag(RF_Struct_2.B2_Mat),  1i*imag(RF_Struct_2.B3_Mat), ...
                 RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                 RF_Struct.d1*1e-3, ... % dx, m
                 RF_Struct.d2*1e-3, ... % dy, m
                 RF_Struct.d3*1e-3, ... % dz, m
                 -1, ... % take the default size
                 freq_rf,%freq_rf*1e9,... freq in Hz
                 +1);% standing wave
   T_Test_2.set_t0(0);

    Ez_circ_T_2 = [];
    Ta = linspace(0,2*pi,721);
    for Ti = Ta
       [E,B] = T_Test_2.get_field(a*1000*cos(Ti), a*1000*sin(Ti), T_Test_2.get_length()/2*1000, 0); % x,y,z,t (mm, mm/c)
        Ez_circ_T_2 = [ Ez_circ_T_2 ; E(3) ];
    end
    FFT = 2*fft(Ez_circ_T_2); FFT(1) = FFT(1)/2;
    FFT_f = FFT(1:length(FFT)/2)/(length(FFT));
    G_m_arr_2 = sqrt(real(FFT_f).^2+imag(FFT_f).^2).*sign(real(FFT_f));

    if plot_bore_E_bool == true
        figure(); hold all; plot(Ta,Ez_circ_T_2)
        Ez_FFT = zeros(1,length(Ta));
        for ii = 2
            n = ii*2+2;
    ##        n = ii;
            Ez_FFT =  Ez_FFT+G_m_arr_2(n+1)*cos(n*Ta);
        end
        plot(Ta,Ez_FFT)
    end

    for ii = 2
      n = 2*ii+2;
      g_m_arr_2(ii) = G_m_arr_2(n+1)/besselj(n,k_rf*a)*1e-6; % [MV/m]
    end

    % calculate the scale factor of the second field
    SF_default_2 = g_m_ideal(2)/g_m_arr_2(2);
    SF_2 = SF_default_2;

    Expected_E_Bore_Bool = true;
    if Expected_E_Bore_Bool
        Ez_FFT_Exp_1 =  G_m_arr(5)*cos(4*Ta)*SF;
        Ez_FFT_Exp_2 =  G_m_arr_2(7)*cos(6*Ta)*SF_2;
        Ez_FFT_Exp =  Ez_FFT_Exp_1+Ez_FFT_Exp_2;
        figure();hold all; plot(Ta,Ez_FFT_Exp); plot(Ta,Ez_FFT_Exp_1,'--'); plot(Ta,Ez_FFT_Exp_2,'--')
    endif

    RF_Bool_3 = true;
    if RF_Bool_3 == true
          T_Test_3 = RF_FieldMap_CINT(real(RF_Struct_3.E1_Mat), real(RF_Struct_3.E2_Mat), real(RF_Struct_3.E3_Mat), ...
                         1i*imag(RF_Struct_3.B1_Mat), 1i*imag(RF_Struct_3.B2_Mat),  1i*imag(RF_Struct_3.B3_Mat), ...
                     RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     RF_Struct.d1*1e-3, ... % dx, m
                     RF_Struct.d2*1e-3, ... % dy, m
                     RF_Struct.d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     freq_rf,%freq_rf*1e9,... freq in Hz
                     +1);% standing wave
       T_Test_3.set_t0(0);

        Ez_circ_T_3 = [];
        Ta = linspace(0,2*pi,721);
        for Ti = Ta
           [E,B] = T_Test_3.get_field(a*1000*cos(Ti), a*1000*sin(Ti), T_Test_3.get_length()/2*1000, 0); % x,y,z,t (mm, mm/c)
            Ez_circ_T_3 = [ Ez_circ_T_3 ; E(3) ];
        end
        FFT = 2*fft(Ez_circ_T_3); FFT(1) = FFT(1)/2;
        FFT_f = FFT(1:length(FFT)/2)/(length(FFT));
        G_m_arr_3 = sqrt(real(FFT_f).^2+imag(FFT_f).^2).*sign(real(FFT_f));

        if plot_bore_E_bool == true
            figure(); hold all; plot(Ta,Ez_circ_T_2)
            Ez_FFT = zeros(1,length(Ta));
            for ii = 3
                n = ii*2+2;
        ##        n = ii;
                Ez_FFT =  Ez_FFT+G_m_arr_2(n+1)*cos(n*Ta);
            end
            plot(Ta,Ez_FFT)
        end

        for ii = 3
          n = 2*ii+2;
          g_m_arr_3(ii) = G_m_arr_3(n+1)/besselj(n,k_rf*a)*1e-6; % [MV/m]
        end

        % calculate the scale factor of the second field
        SF_default_3 = g_m_ideal(3)/g_m_arr_3(3);
        SF_3 = SF_default_3;
    endif

##    SF = -250.45;
##    SF_2 = -1816;
##    SF = -2.76; SF_2 = -26.13;
    SF = SF_Load; SF_2 = SF_Load_2;

    if RF_Bool_3 == true
          SF_3 = SF_Load_3;
          M = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*SF+real(RF_Struct_2.E1_Mat)*SF_2+real(RF_Struct_3.E1_Mat)*SF_3,...
                      real(RF_Struct.E2_Mat)*SF+real(RF_Struct_2.E2_Mat)*SF_2+real(RF_Struct_3.E2_Mat)*SF_3,...
                      real(RF_Struct.E3_Mat)*SF+real(RF_Struct_2.E3_Mat)*SF_2+real(RF_Struct_3.E3_Mat)*SF_3, ...
                     1i*(imag(RF_Struct.B1_Mat)*SF+imag(RF_Struct_2.B1_Mat)*SF_2+imag(RF_Struct_3.B1_Mat)*SF_3), ...
                     1i*(imag(RF_Struct.B2_Mat)*SF+imag(RF_Struct_2.B2_Mat)*SF_2+imag(RF_Struct_3.B2_Mat)*SF_3),  ...
                     1i*(imag(RF_Struct.B3_Mat)*SF+imag(RF_Struct_2.B3_Mat)*SF_2+imag(RF_Struct_3.B3_Mat)*SF_3), ...
                     RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     RF_Struct.d1*1e-3, ... % dx, m
                     RF_Struct.d2*1e-3, ... % dy, m
                     RF_Struct.d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     freq_rf,... freq in Hz
                     +1);% standing wave
    else
                     M = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*SF+real(RF_Struct_2.E1_Mat)*SF_2,...
                      real(RF_Struct.E2_Mat)*SF+real(RF_Struct_2.E2_Mat)*SF_2,...
                      real(RF_Struct.E3_Mat)*SF+real(RF_Struct_2.E3_Mat)*SF_2, ...
                     1i*(imag(RF_Struct.B1_Mat)*SF+imag(RF_Struct_2.B1_Mat)*SF_2), ...
                     1i*(imag(RF_Struct.B2_Mat)*SF+imag(RF_Struct_2.B2_Mat)*SF_2),  ...
                     1i*(imag(RF_Struct.B3_Mat)*SF+imag(RF_Struct_2.B3_Mat)*SF_2), ...
                     RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     RF_Struct.d1*1e-3, ... % dx, m
                     RF_Struct.d2*1e-3, ... % dy, m
                     RF_Struct.d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     freq_rf,... freq in Hz
                     +1);% standing wave

    end
    LM_RF = M.get_length();
    M.set_odeint_algorithm('rk2');
    M.set_nsteps(LM_RF*1000/0.1); % [40 mm] with steps every 0.1 mm
    M.set_tt_nsteps(ceil(LM_RF*1000)); % tt every mm
    M.set_t0(0)

    % Add capability to sanity check all of the field

    % Plot longitudinal E and transverse B fields - Check
    plot_test_field_bool = false;
    if plot_test_field_bool == true
        Za = linspace(0,M.get_length(),501);
        Ez_a = []; By_a = [];
        for Z = Za
            [E,B] = M.get_field(a*1000, 0, Z*1000,0); % x,y,z,t (mm, mm/c)
            Ez_a = [ Ez_a ; E(3) ];

            [E,B] = M.get_field(a*1000, 0, Z*1000, RF_Track.s/M.get_frequency/4); % x,y,z,t (mm, mm/c)
            By_a = [ By_a ; B(2) ];
        end
        figure(); subplot(1,2,1); plot(Za,Ez_a); subplot(1,2,2); plot(Za,By_a)
    end

    %% Calculate multipole content at pipe
    Ez_circ_M = []; Ta = linspace(0,2*pi,721);
    for Ti = Ta
       [E,B] = M.get_field(a*1000*cos(Ti), a*1000*sin(Ti), M.get_length()/2*1000, 0); % x,y,z,t (mm, mm/c)
        Ez_circ_M = [ Ez_circ_M ; E(3) ];
    end
    FFT = 2*fft(Ez_circ_M); FFT(1) = FFT(1)/2;
    FFT_f = FFT(1:length(FFT)/2)/(length(FFT));
    G_m_arr_combined = sqrt(real(FFT_f).^2+imag(FFT_f).^2).*sign(real(FFT_f));

    % Plot Ez on the bore to check
    plot_bore_E_bool = false;
    if plot_bore_E_bool == true
        figure(); hold all; plot(Ta,Ez_circ_M)
        Ez_FFT = zeros(1,length(Ta));
        for ii = 1:Multipoles+1
            n = ii*2+2;
    ##        n = ii;
            Ez_FFT =  Ez_FFT+G_m_arr_combined(n+1)*cos(n*Ta);
        end
        plot(Ta,Ez_FFT)
    end


    % Plot Ez along the x direction to check multipole fit
    plot_radial_E_bool = false;
    if plot_radial_E_bool == true
        x_arr = linspace(0,a,201);
        Ez_x_sample = [];
        for x = x_arr
           [E,B] = M.get_field(x*1000, 0, M.get_length()/2*1000, 0); % x,y,z,t (mm, mm/c)
            Ez_x_sample = [ Ez_x_sample ; E(3) ];
        end

        figure(); hold all; plot(x_arr,Ez_x_sample)
        Ez_FFT = zeros(1,length(x_arr));
        for ii = 1:3
            n = ii*2+2;
            Ez_FFT =  Ez_FFT+G_m_arr_combined(n+1)*besselj(n,k_rf*x_arr)/besselj(n,k_rf*a);
        end
        plot(x_arr,Ez_FFT)
    end

    for ii = 1:3
        n = 2*ii+2;
        g_m_arr_combined(ii) = G_m_arr_combined(n+1)/besselj(n,k_rf*a)*1e-6; % [MV/m]
    end

    M.unset_t0();


end

L = Lattice();
zOffset = LM_RF-Q1_s0;
L.append(M, 0, 0, 0, reference = "entrance")
##L.append(M, 0, 0, -zOffset, reference = "entrance")
% Create first drift
D0L = Q1_s0-LM_RF;
##D0L = -zOffset+LM_RF-Q1_s0;
D0 = Drift(D0L);
D0.set_tt_nsteps(round(D0L*100)); % tt every 10 mm
L.append(D0);
L.append(Q1);
L.append(D2);

% Autophase to calculate the phase of the cavity
P_i = Bunch6d (mass, 1, charge, [a*1000 0 0 0 0 Pref]);
P_f = L.autophase(P_i);
t0 = L{1}.get_t0;
L{1}.set_phid(270)
L{1}.set_aperture(a, a);

% plot some fields
plot_bool = false;
if plot_bool == true
    Za = linspace(0,T_Test.get_length(),501);
    Ez_temp = []; By_temp = [];
    for Z = Za
    ##   [E,B] = L.get_field(a*1000, 0, Z*1000, L{1}.get_t0); % x,y,z,t (mm, mm/c)
       [E,B] = L.get_field(a*1000, 0, Z*1000, Z*1000); % x,y,z,t (mm, mm/c)
        Ez_temp = [ Ez_temp ; E(3) ];
        [E,B] = L.get_field(a*1000, 0, Z*1000, Z*1000); % x,y,z,t (mm, mm/c)
        By_temp = [ By_temp ; B(2) ];
    end
    figure(); plot(Za,Ez_temp)
    figure(); plot(Za,By_temp)

    By_x = [];
    Xa2 = linspace(-a*1000,a*1000,501);
    for X = Xa2
        [E,B] = L.get_field(X, 0, M.get_length()/2*1000,  L{1}.get_t0); % x,y,z,t (mm, mm/c)
        By_x = [ By_x ; B(2)];
    end
    figure(); hold all; plot(Xa2,By_x); plot(Xa2,B_ideal); xlim([-40 40])

    Za = linspace(0,T_Test.get_length(),501);
    Ez_temp = [];
    for Z = Za
       [E,B] = L.get_field(a*1000, 0, Z*1000, L{1}.get_t0); % x,y,z,t (mm, mm/c)
       [E,B] = L.get_field(a*1000, 0, Z*1000, Z*1000+L{1}.get_t0); % x,y,z,t (mm, mm/c)
        Ez_temp = [ Ez_temp ; E(3) ];
    end
    figure(); plot(Za,Ez_temp)
end


B1 = L.track(B0);

% Extract phase space parameters
Bf_phase = B1.get_phase_space();
X_ff = Bf_phase(:,1);

r_t_mm = sqrt(pi/2)*sqrt(emitt_geo_x_0*1e-6*beta_x_f_def)*cos(phase_adv_def)*1000;
bins_optim = linspace(-2*r_t_mm,2*r_t_mm,no_bins);

h = hist(X_ff,bins_optim,population);
h = h(2:end-1); bins_optim = bins_optim(2:end-1);

A = h(((length(bins_optim))-1)/2+1);

BoxFitAll = A*(abs(bins_optim)<=r_t_mm);
PipeFactor = 0.8;
BoxBool = abs(bins_optim)<=r_t_mm*PipeFactor;
BoxData = h(BoxBool);
BoxFit = A*ones(1,length(BoxData));
SSE = sqrt(sum((BoxData-BoxFit).^2))/population*1000;
FoM = SSE;
DispSpec = '%0.2f';
disp(['SSE = ' num2str(SSE,DispSpec) '; SF = ' num2str(SF)] );
uni_bin_i = 30; uni_bin_f = 69;
uni_bin_i = 33; uni_bin_f = 68;
uniform_particles = length(X_ff)*sum(h(uni_bin_i:uni_bin_f))/sum(h)/nParticles
survived_particles = ['Survived = ' num2str(B1.get_ngood/nParticles*100) '%']
%figure(); plot(b1(uni_bin_i:uni_bin_f),h1(uni_bin_i:uni_bin_f),'k')
%plot(bins_optim(uni_bin_i:uni_bin_f),h(uni_bin_i:uni_bin_f),'k')

LW = 1.5;
colours = jet(4);
figure(12); hold on;
##'g', 'm','r','b','g', [.7 .7 .7]
plot(bins_optim,BoxFitAll/A,'k','Linewidth',LW/2,'handlevisibility','off')
##plot(b2,h1,'b','Linewidth',LW,'displayname','$\tilde{g}_2/\tilde{g}_4=-11e-2$')
plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW,'displayname','$\tilde{g}_2/\tilde{g}_4=-11e-2$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'color',[.7 .7 .7],'Linewidth',LW,'displayname','$0\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'g','Linewidth',LW,'displayname','$0.5\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'c','Linewidth',LW,'displayname','$0.75\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'b','Linewidth',LW,'displayname','$1\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'m','Linewidth',LW,'displayname','$1.25\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW,'displayname','$1.5\times\tilde{g}_4$')
xlabel('$x$ [mm]', 'interpreter','latex')
ylabel('Relative Intensity', 'interpreter','latex');
##title(['Survived = ' num2str(B1.get_ngood/nParticles*100) '%'])
pos = get(gca, 'Position');
##set(gca, 'Position', [pos(1)-0.05 pos(2)+0.02 pos(3) pos(4)-0.02]);
##set(gca, 'Position', [pos(1) pos(2)-0.05 pos(3) pos(4)-0.12]);
##set(gca, 'Position', [pos(1)+0.05 pos(2)+0.15 pos(3) pos(4)-0.12]);
ylim([0 2])
grid; box on;
set(gca,'FontSize',24)
drawnow
##legend('location','Northoutside','orientation','horizontal','interpreter','latex','numcolumns',3)

SaverPlot = 0;
if SaverPlot == true
      save('Dist/ThreePill.m','bins_optim','h');
      x = load('Dist/ThreePill.m','bins_optim','h');
      figure(); hold all; plot(x.bins_optim,x.h./mean(x.h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW,'displayname','$\tilde{g}_2/\tilde{g}_4=-11e-2$')
end


%% Plot Momentum Changes etc
plot_bool = false;

if plot_bool == true

  SF = SF_default;


  if RF_Bool == true
      SF_2 = SF_default_2;
      SF = -264;  SF_2 = -2216; % Solved for values for pillbox overlaid
      SF_arr = [SF SF_2];

      M_Loop = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*SF+real(RF_Struct_2.E1_Mat)*SF_2,...
                          real(RF_Struct.E2_Mat)*SF+real(RF_Struct_2.E2_Mat)*SF_2,...
                          real(RF_Struct.E3_Mat)*SF+real(RF_Struct_2.E3_Mat)*SF_2, ...
                         1i*(imag(RF_Struct.B1_Mat)*SF+imag(RF_Struct_2.B1_Mat)*SF_2), ...
                         1i*(imag(RF_Struct.B2_Mat)*SF+imag(RF_Struct_2.B2_Mat)*SF_2),  ...
                         1i*(imag(RF_Struct.B3_Mat)*SF+imag(RF_Struct_2.B3_Mat)*SF_2), ...
                         RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                         RF_Struct.d1*1e-3, ... % dx, m
                         RF_Struct.d2*1e-3, ... % dy, m
                         RF_Struct.d3*1e-3, ... % dz, m
                         -1, ... % take the default size
                         freq_rf,... freq in Hz
                         +1);% standing wave
    else
        M_Loop = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*SF,...
                          real(RF_Struct.E2_Mat)*SF,...
                          real(RF_Struct.E3_Mat)*SF, ...
                         1i*imag(RF_Struct.B1_Mat)*SF, ...
                         1i*imag(RF_Struct.B2_Mat)*SF,  ...
                         1i*imag(RF_Struct.B3_Mat)*SF, ...
                         RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                         RF_Struct.d1*1e-3, ... % dx, m
                         RF_Struct.d2*1e-3, ... % dy, m
                         RF_Struct.d3*1e-3, ... % dz, m
                         -1, ... % take the default size
                         freq_rf,... freq in Hz
                         +1);% standing wave
    end

    LM_RF = M_Loop.get_length();
    M_Loop.set_odeint_algorithm('rk2');
    M_Loop.set_nsteps(LM_RF*1000/0.1); % [40 mm] with steps every 0.1 mm
    M_Loop.set_tt_nsteps(ceil(LM_RF*1000)); % tt every mm

    % LATTICE
    L2 = Lattice();
    L2.append(M_Loop, 0, 0, 0, reference = "entrance")
    % Autophase to calculate the phase of the cavity
    P_i = Bunch6d (mass, 1, charge, [a/2*1000 0 0 0 0 Pref]);
    P_f = L2.autophase(P_i);
    t0 = L2{1}.get_t0;
    L2{1}.set_phid(270);
    L2{1}.set_aperture(a, a);

    B2 = L2.track(B0);
    B2_ps = B2.get_phase_space();
    B2_IDs = B2.get_phase_space('%id');
    Delta_Px = (B2_ps(:,2)-B0_phase(B2_IDs+1,2))*Pref/1000;
    X_ff = B2_ps(:,1);
    [sort_X, poses] = sort(X_ii(B2_IDs+1));
    sort_X_ave = sort_X-(sort_X-X_ff(poses))/2;


    figure(); hold all;
    plot(sort_X,-Delta_Px(poses),'k-','displayname','RF Track Particles, X_i');
    plot(sort_X_ave,-Delta_Px(poses),'k-','displayname','RF Track Particles, average X');

    Za = linspace(0,L2{1}.get_length()*1000,501);
    Xa3 = linspace(-a*1000,a*1000,501);
    pw_sim = [];
##    figure(); hold all;
    for X = Xa3
      By_a = [];
        for Z = Za
            [E,B] = L2{1}.get_field(X, 0, Z, Z); % x,y,z,t (mm, mm/c)
            By_a = [ By_a ; B(2) ];
        end
##        plot(Za,By_a)
        pw_sim = [pw_sim trapz(Za/1000,By_a*1e-6*charge*c)];
    end

    plot(Xa,delta_p_B,'r','Displayname','Ideal Magnet');
    plot(Xa,delta_p_g,'m--','Displayname','Ideal RF-Cavity','linewidth',1.1);
    plot(Xa3,pw_sim,'b','Displayname','RF-Track B_y Integral')

    pw_theory = zeros(1,length(Xa));
    pw_track_theory = zeros(1,length(Xa));


    LM = 0.05;
    if RF_Bool == true
      for ii = 1:2
           m = (2*ii+2);
          pw_theory = pw_theory+ charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_ideal(ii))*besselj(m,k_rf*a)*(Xa/1000/a).^(m-1)*c;
          if ii == 1
            pw_track_theory = pw_track_theory + charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_arr(ii)*SF)*besselj(m,k_rf*a)*(Xa/1000/a).^(m-1)*c;
          else
            pw_track_theory = pw_track_theory + charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_arr_2(ii)*SF_2)*besselj(m,k_rf*a)*(Xa/1000/a).^(m-1)*c;
          end
      endfor
      else
        for ii = 1:Multipoles
             m = (2*ii+2);
            pw_theory = pw_theory+ charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_ideal(ii))*besselj(m,k_rf*a)*(Xa/1000/a).^(m-1)*c;
            pw_track_theory = pw_track_theory + charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_arr(ii)*SF_default)*besselj(m,k_rf*a)*(Xa/1000/a).^(m-1)*c;
        endfor
    endif
    plot(Xa,pw_theory,'g--','Displayname',['Ideal RF with Multipoles Calculated = ' num2str(Multipoles)],'linewidth',1.1)
    plot(Xa,pw_track_theory,'c','Displayname','RF with SF Multipoles Calculated')

    pw_track_theory_quad = zeros(1,length(Xa));
    if RF_Bool == false
        for ii = 1:3
             m = (2*ii);
            pw_track_theory_quad = pw_track_theory_quad + charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_arr_test(m+1)*SF_default)*besselj(m,k_rf*a)*(Xa/1000/a).^(m-1)*c;
        endfor
    endif

    plot(Xa,-pw_track_theory_quad,'g','Displayname','RF with Quadrupoles')

    title(['Survived particles = ' num2str(B2.get_ngood/nParticles*100)])
    xlim([0 50]); ylim([-10 70])
    legend('location','eastoutside')



##    p = polyfit (sort_X,-Delta_Px(poses), [true false false true]');
##    p = polyfit (sort_X,-Delta_Px(poses), [false false true false true false true]);
    p = flip(polyfit (sort_X,-Delta_Px(poses), 8));
##    plot(sort_X,p(2)*(sort_X).^1+p(4)*(sort_X).^3+p(6)*(sort_X).^5,'y-','linewidth',2)
    arr = zeros(length(sort_X),1);
    for ii = [2 4 6]
      arr = arr+ p(ii)*sort_X.^(ii-1);
    endfor
    plot(sort_X,arr,'y--','linewidth',2)
##    p_g_predict = polyfit (Xa,pw_track_theory, 6)
##    plot(Xa,p_g_predict(4)*(Xa).^3,'y-','linewidth',2)
##    p_tracked = polyfit (sort_X,-Delta_Px(poses), 6)
##    plot(sort_X, p_tracked(4)*(sort_X).^3,'y-','linewidth',2)
##    p_g_predict(4)/p_tracked(4)

    % VOLUME
##    B0t = Bunch6dT(B0);
##    V = Volume();
##    V.add(M,0,0,0);
##    % Autophase to calculate the phase of the cavity
##    P_i = Bunch6dT (mass, 1, charge, [a*1000 0 0 0 0 Pref]);
##    P_f = V.autophase(P_i);
##    V{1}.get_t0;
##    V{1}.set_phid(270)
##    B2 = V.track(B0t);
##    B2_ps = B2.get_phase_space('%X %Px %Y %Py %Z %Pz');
##    B0t_ps = B0t.get_phase_space('%X %Px %Y %Py %Z %Pz');
##    Delta_Px = (B2_ps(:,2)-B0t_ps(:,2));
##    [sort_X, poses] = sort(B2_ps(:,1));
##    plot(sort_X,-Delta_Px(poses),'g','displayname','RF Tracked');


end

return
##SF = -20.694 SF_default = -16.555 JUST A NOTE OF PREVIOUS VALUE


Sigmas2Plot = 3;
x_0 = -Sigmas2Plot*sigma_0; Xa_L = 501; r_0 = Sigmas2Plot*sigma_0;
M_i = 4; % always going from octupole
##Xarr = sort_X';
Xarr = sort(X_ii)';
% Set up loop and preinitiailse array
IdealLoops = 50; colours = viridis(IdealLoops);
g_m_ideal = []; cav_phase = pi/2;
B_ideal = zeros(1,length(Xarr));
delta_p_B_sort = zeros(1,length(Xarr));
delta_p_g_sort = zeros(1,length(Xarr));

for ii = 1:IdealLoops
    m = (2*ii+2); % only look at even multipoles from 3 onwards
    if ii == 1 % if octupole, no recursivity.
        kNL = 2/(2*emitt_geo_x_0*1e-6*beta_x_0)/beta_x_0/tan(phase_adv_def); % calculate magnetic multipole

        g_m_ideal_loop = Pref/charge/c*2*pi*freq_rf/LM*(k_rf*LM/2)/sin(k_rf*LM/2)*1/sin(cav_phase)*a^m/(besselj(m,k_rf*a)*factorial(m))*kNL; % [MV/m]
        g_m_ideal = [g_m_ideal g_m_ideal_loop];
    else
        kNL = -(2*ii-1)./(emitt_geo_x_0*1e-6*beta_x_0)*kNL;
        MultArray = [MultArray 0 kNL]; % further complete magnetic array

        g_m_ideal_loop = Pref/charge/c*2*pi*freq_rf/LM*k_rf*LM/2/sin(k_rf*LM/2)*1/sin(cav_phase)*a^m/(besselj(m,k_rf*a)*factorial(m))*kNL; % [MV/m]
        g_m_ideal = [g_m_ideal g_m_ideal_loop];
    end

    B_ideal_loop = Pref*1e6/charge*kNL*(Xarr/1000).^(m-1)/factorial(m-1)/LM/c;
    B_ideal = B_ideal+B_ideal_loop;
    delta_p_B_sort = delta_p_B_sort+1e-6*charge*c*B_ideal_loop*LM; %[MeV/c]
    delta_p_g_sort = delta_p_g_sort+charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_ideal_loop)*besselj(m,k_rf*a)*(Xarr/1000/a).^(m-1)*c;

end

###### Create Best Fit to Ideal Mom Change ONE MULTIPOLE
function [FoM] = RF_SF_Fitter(X,Xarr,delta_p_g_sort,RF_Struct,freq_rf,mass,charge,a,Pref,B0,sigma_0,FracSearch,X_0,SF)
    Sigmas2Fit = 3;
    RF_Track;
    c = 299792458;
    X_Test = [SF];
    X =  X_Test .* 10.^(F_Constraint( X, -FracSearch, +FracSearch))


    M_Loop = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*X(1),...
                      real(RF_Struct.E2_Mat)*X(1),...
                      real(RF_Struct.E3_Mat)*X(1), ...
                     1i*(imag(RF_Struct.B1_Mat)*X(1)), ...
                     1i*(imag(RF_Struct.B2_Mat)*X(1)),  ...
                     1i*(imag(RF_Struct.B3_Mat)*X(1)), ...
                     RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     RF_Struct.d1*1e-3, ... % dx, m
                     RF_Struct.d2*1e-3, ... % dy, m
                     RF_Struct.d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     freq_rf,... freq in Hz
                     +1);% standing wave
    LM_RF = M_Loop.get_length();
    M_Loop.set_odeint_algorithm('rk2');
    M_Loop.set_nsteps(LM_RF*1000/0.1); % [40 mm] with steps every 0.1 mm
    M_Loop.set_tt_nsteps(ceil(LM_RF*1000)); % tt every mm

    % LATTICE
    L2 = Lattice();
    L2.append(M_Loop, 0, 0, 0, reference = "entrance")
    % Autophase to calculate the phase of the cavity
    P_i = Bunch6d (mass, 1, charge, [a/2*1000 0 0 0 0 Pref]);
    P_f = L2.autophase(P_i);
    t0 = L2{1}.get_t0;
    L2{1}.set_phid(270);
##    L2{1}.set_aperture(a, a);

    B2 = L2.track(B0);
    B2_ps = B2.get_phase_space();
    B2_IDs = B2.get_phase_space('%id');
    B0_phase = B0.get_phase_space();
    X_ii = B0_phase(:,1);
    Delta_Px = (B2_ps(:,2)-B0_phase(B2_IDs+1,2))*Pref/1000;
    [sort_X, poses] = sort(X_ii(B2_IDs+1));
    Delta_Px_Sort = -Delta_Px(poses);

    SSEBool = abs(Xarr)<Sigmas2Fit*sigma_0;
    Weight = exp(-Xarr.^2/2/sigma_0^2);
    diff_val = Xarr(2)-Xarr(1); WeightErf = zeros(1,length(Xarr));
    for jj = 1:length(Xarr)
        WeightErf(jj) = 0.5*(erf((Xarr(jj)+diff_val)/sigma_0)-erf((Xarr(jj)-diff_val)/sigma_0));
    end

##    figure(); plot((Delta_Px_Sort(SSEBool)-delta_p_g_sort'(SSEBool)))

    SSE = sqrt(sum((Delta_Px_Sort(SSEBool)-delta_p_g_sort'(SSEBool)).^2));
    SSE_Weighted = sqrt(sum(WeightErf(SSEBool).*(Delta_Px_Sort'(SSEBool)-delta_p_g_sort(SSEBool)).^2));

##    FoM = SSE
    FoM = SSE_Weighted;
    figure(20); clf; hold all; plot(Xarr,Delta_Px_Sort);plot(Xarr,delta_p_g_sort')
    drawnow

    DispSpec = '%0.1f';
   disp(['FoM = ' num2str(FoM,DispSpec) '; X = ' num2str(X)]);
end
%RF_Struct_2 = 0; SF_2 = 0;
O = optimset('TolX', 0.01, 'TolFun', 0.01, 'MaxFunEvals', 1e5, 'MaxIter', 1e5); % Define optimset
FracSearch = 1;
anon_func_RF = @(X)RF_SF_Fitter(X,Xarr,delta_p_g_sort,RF_Struct,freq_rf,mass,charge,a,Pref,B0,sigma_0,FracSearch,X_0,SF)
X_0 = [0];
[XOptim,SSE] = fminsearch(anon_func_RF, X_0, O);
SSE
MultArray_RF_0 = XOptim

###### Create Best Fit to Ideal Mom Change TWO MULTIPOLES
function [FoM] = RF_SF_Fitter(X,Xarr,delta_p_g_sort,RF_Struct,RF_Struct_2,freq_rf,mass,charge,a,Pref,B0,sigma_0,FracSearch,X_0,SF,SF_2)
    Sigmas2Fit = 3;
    RF_Track;
    c = 299792458;
    X_Test = [SF SF_2];
    X =  X_Test .* 10.^(F_Constraint( X, -FracSearch, +FracSearch))


    M_Loop = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*X(1)+real(RF_Struct_2.E1_Mat)*X(2),...
                      real(RF_Struct.E2_Mat)*X(1)+real(RF_Struct_2.E2_Mat)*X(2),...
                      real(RF_Struct.E3_Mat)*X(1)+real(RF_Struct_2.E3_Mat)*X(2), ...
                     1i*(imag(RF_Struct.B1_Mat)*X(1)+imag(RF_Struct_2.B1_Mat)*X(2)), ...
                     1i*(imag(RF_Struct.B2_Mat)*X(1)+imag(RF_Struct_2.B2_Mat)*X(2)),  ...
                     1i*(imag(RF_Struct.B3_Mat)*X(1)+imag(RF_Struct_2.B3_Mat)*X(2)), ...
                     RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     RF_Struct.d1*1e-3, ... % dx, m
                     RF_Struct.d2*1e-3, ... % dy, m
                     RF_Struct.d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     freq_rf,... freq in Hz
                     +1);% standing wave
    LM_RF = M_Loop.get_length();
    M_Loop.set_odeint_algorithm('rk2');
    M_Loop.set_nsteps(LM_RF*1000/0.1); % [40 mm] with steps every 0.1 mm
    M_Loop.set_tt_nsteps(ceil(LM_RF*1000)); % tt every mm

    % LATTICE
    L2 = Lattice();
    L2.append(M_Loop, 0, 0, 0, reference = "entrance")
    % Autophase to calculate the phase of the cavity
    P_i = Bunch6d (mass, 1, charge, [a/2*1000 0 0 0 0 Pref]);
    P_f = L2.autophase(P_i);
    t0 = L2{1}.get_t0;
    L2{1}.set_phid(270);
##    L2{1}.set_aperture(a, a);

    B2 = L2.track(B0);
    B2_ps = B2.get_phase_space();
    B2_IDs = B2.get_phase_space('%id');
    B0_phase = B0.get_phase_space();
    X_ii = B0_phase(:,1);
    Delta_Px = (B2_ps(:,2)-B0_phase(B2_IDs+1,2))*Pref/1000;
    [sort_X, poses] = sort(X_ii(B2_IDs+1));
    Delta_Px_Sort = -Delta_Px(poses);

    SSEBool = abs(Xarr)<Sigmas2Fit*sigma_0;
    Weight = exp(-Xarr.^2/2/sigma_0^2);
    diff_val = Xarr(2)-Xarr(1); WeightErf = zeros(1,length(Xarr));
    for jj = 1:length(Xarr)
        WeightErf(jj) = 0.5*(erf((Xarr(jj)+diff_val)/sigma_0)-erf((Xarr(jj)-diff_val)/sigma_0));
    end

##    figure(); plot((Delta_Px_Sort(SSEBool)-delta_p_g_sort'(SSEBool)))

    SSE = sqrt(sum((Delta_Px_Sort(SSEBool)-delta_p_g_sort'(SSEBool)).^2));
    SSE_Weighted = sqrt(sum(WeightErf(SSEBool).*(Delta_Px_Sort'(SSEBool)-delta_p_g_sort(SSEBool)).^2));

##    FoM = SSE
    FoM = SSE_Weighted;
    figure(20); clf; hold all; plot(Xarr,Delta_Px_Sort);plot(Xarr,delta_p_g_sort')
    drawnow

    DispSpec = '%0.1f';
   disp(['FoM = ' num2str(FoM,DispSpec) '; X = ' num2str(X)]);
end
%RF_Struct_2 = 0; SF_2 = 0;
O = optimset('TolX', 0.01, 'TolFun', 0.01, 'MaxFunEvals', 1e5, 'MaxIter', 1e5); % Define optimset
FracSearch = 1;
anon_func_RF = @(X)RF_SF_Fitter(X,Xarr,delta_p_g_sort,RF_Struct,RF_Struct_2,freq_rf,mass,charge,a,Pref,B0,sigma_0,FracSearch,X_0,SF,SF_2)
X_0 = [0, 0];
[XOptim,SSE] = fminsearch(anon_func_RF, X_0, O);
SSE
MultArray_RF_0 = XOptim





####### Create Best Fit to Box

Sigmas2Plot = 3;
x_0 = -Sigmas2Plot*sigma_0; Xa_L = 501; r_0 = Sigmas2Plot*sigma_0;
M_i = 4; % always going from octupole
##Xarr = sort_X';
Xarr = sort(X_ii)';
% Set up loop and preinitiailse array
IdealLoops = 50; colours = viridis(IdealLoops);
g_m_ideal = []; cav_phase = pi/2;
B_ideal = zeros(1,length(Xarr));
delta_p_B_sort = zeros(1,length(Xarr));
delta_p_g_sort = zeros(1,length(Xarr));

for ii = 1:IdealLoops
    m = (2*ii+2); % only look at even multipoles from 3 onwards
    if ii == 1 % if octupole, no recursivity.
        kNL = 2/(2*emitt_geo_x_0*1e-6*beta_x_0)/beta_x_0/tan(phase_adv_def); % calculate magnetic multipole

        g_m_ideal_loop = Pref/charge/c*2*pi*freq_rf/LM*(k_rf*LM/2)/sin(k_rf*LM/2)*1/sin(cav_phase)*a^m/(besselj(m,k_rf*a)*factorial(m))*kNL; % [MV/m]
        g_m_ideal = [g_m_ideal g_m_ideal_loop];
    else
        kNL = -(2*ii-1)./(emitt_geo_x_0*1e-6*beta_x_0)*kNL;
        MultArray = [MultArray 0 kNL]; % further complete magnetic array

        g_m_ideal_loop = Pref/charge/c*2*pi*freq_rf/LM*k_rf*LM/2/sin(k_rf*LM/2)*1/sin(cav_phase)*a^m/(besselj(m,k_rf*a)*factorial(m))*kNL; % [MV/m]
        g_m_ideal = [g_m_ideal g_m_ideal_loop];
    end

    B_ideal_loop = Pref*1e6/charge*kNL*(Xarr/1000).^(m-1)/factorial(m-1)/LM/c;
    B_ideal = B_ideal+B_ideal_loop;
    delta_p_B_sort = delta_p_B_sort+1e-6*charge*c*B_ideal_loop*LM; %[MeV/c]
    delta_p_g_sort = delta_p_g_sort+charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_ideal_loop)*besselj(m,k_rf*a)*(Xarr/1000/a).^(m-1)*c;

end



Xarr = sort(X_ii)';
% ONE MULTIPOLES
function [FoM] = RF_Box_Fitter_1(X,Xarr,RF_Struct,freq_rf,mass,charge,D0,Q1,D2,a,B0,emitt_geo_x_0,beta_x_f_def,phase_adv_def,no_bins,SF,FracSearch,Pref,population,nParticles)
    Sigmas2Fit = 3;
    RF_Track;
    c = 299792458;
    X_Test = [SF];
    X =  X_Test .* 10.^(F_Constraint( X, -FracSearch, +FracSearch));


    M_Loop = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*X(1),...
                      real(RF_Struct.E2_Mat)*X(1),...
                      real(RF_Struct.E3_Mat)*X(1), ...
                     1i*(imag(RF_Struct.B1_Mat)*X(1)), ...
                     1i*(imag(RF_Struct.B2_Mat)*X(1)),  ...
                     1i*(imag(RF_Struct.B3_Mat)*X(1)), ...
                     RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     RF_Struct.d1*1e-3, ... % dx, m
                     RF_Struct.d2*1e-3, ... % dy, m
                     RF_Struct.d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     freq_rf,... freq in Hz
                     +1);% standing wave
    LM_RF = M_Loop.get_length();
    M_Loop.set_odeint_algorithm('rk2');
    M_Loop.set_nsteps(LM_RF*1000/0.1); % [40 mm] with steps every 0.1 mm
    M_Loop.set_tt_nsteps(ceil(LM_RF*1000)); % tt every mm

    L = Lattice();
    L.append(M_Loop, 0, 0, 0, reference = "entrance")
    L.append(D0);
    L.append(Q1);
    L.append(D2);

    % Autophase to calculate the phase of the cavity
    P_i = Bunch6d (mass, 1, charge, [a*1000 0 0 0 0 Pref]);
    P_f = L.autophase(P_i);
    t0 = L{1}.get_t0;
    L{1}.set_phid(270)
    L{1}.set_aperture(a, a);

    B1 = L.track(B0);

    % Extract phase space parameters
    Bf_phase = B1.get_phase_space();
    X_ff = Bf_phase(:,1);

    r_t_mm = sqrt(pi/2)*sqrt(emitt_geo_x_0*1e-6*beta_x_f_def)*cos(phase_adv_def)*1000;
    bins_optim = linspace(-2*r_t_mm,2*r_t_mm,no_bins);

    h = hist(X_ff,bins_optim,population);
    h = h(2:end-1); bins_optim = bins_optim(2:end-1);

    A = h(((length(bins_optim))-1)/2+1);


    BoxFitAll = A*(abs(bins_optim)<=r_t_mm);
    PipeFactor = 0.8;
    BoxBool = abs(bins_optim)<=r_t_mm*PipeFactor;
    BoxData = h(BoxBool);
    BoxFit = A*ones(1,length(BoxData));
    SSE = sqrt(sum((BoxData-BoxFit).^2))/population*1000;
    FoM = SSE;
    DispSpec = '%0.2f';

    BoxFunc = [zeros(1,sum(bins_optim<-r_t_mm)) A*ones(1,sum(abs(bins_optim)<=r_t_mm)) zeros(1,sum(bins_optim>r_t_mm)) ];
    Weight = exp(-bins_optim.^2/2/r_t_mm^2);
    SSE_Weighted = sqrt(sum(Weight.*(BoxFunc-h).^2))/population*1000;


    LW = 1.5;
    colours = jet(4);
   figure(22); clf; hold all;
    plot(bins_optim,BoxFitAll/A,':k','Linewidth',LW,'handlevisibility','off')
    plot(bins_optim(BoxBool),BoxFitAll(BoxBool)/A,':g','Linewidth',LW,'handlevisibility','off')
    plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW,'displayname','$1\times\tilde{g}_4$')
    xlabel('$x$ [mm]', 'interpreter','latex')
    ylabel('Relative Intensity', 'interpreter','latex');
    title(['Survived = ' num2str(B1.get_ngood/nParticles*100) '%'])
    ylim([0 2])
    grid; box on;
    set(gca,'FontSize',24)
    drawnow

   disp(['SF = ' num2str(X) '; SSE = ' num2str(FoM,DispSpec) '; SSE Weighted = ' num2str(SSE_Weighted)]);
end
Xarr = sort(X_ii)';
SF = SF_default;
SF = 10;
O = optimset('TolX', 0.01, 'TolFun', 0.01, 'MaxFunEvals', 1e5, 'MaxIter', 1e5); % Define optimset
FracSearch = 1;
box_func_RF_1 = @(X)RF_Box_Fitter_1(X,Xarr,RF_Struct,freq_rf,mass,charge,D0,Q1,D2,a,B0,emitt_geo_x_0,beta_x_f_def,phase_adv_def,no_bins,SF,FracSearch,Pref,population,nParticles)
X_0 = [0];
[XOptim,SSE] = fminsearch(box_func_RF_1, X_0, O);
SF_best = 15.794;


Xarr = sort(X_ii)';
% TWO MULTIPOLES
function [FoM] = RF_Box_Fitter(X,Xarr,RF_Struct,RF_Struct_2,freq_rf,mass,charge,D0,Q1,D2,a,B0,emitt_geo_x_0,beta_x_f_def,phase_adv_def,no_bins,SF,SF_2,FracSearch,Pref,population,nParticles)
    Sigmas2Fit = 3;
    RF_Track;
    c = 299792458;
    X_Test = [SF SF_2];
    X =  X_Test .* 10.^(F_Constraint( X, -FracSearch, +FracSearch))


    M_Loop = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*X(1)+real(RF_Struct_2.E1_Mat)*X(2),...
                      real(RF_Struct.E2_Mat)*X(1)+real(RF_Struct_2.E2_Mat)*X(2),...
                      real(RF_Struct.E3_Mat)*X(1)+real(RF_Struct_2.E3_Mat)*X(2), ...
                     1i*(imag(RF_Struct.B1_Mat)*X(1)+imag(RF_Struct_2.B1_Mat)*X(2)), ...
                     1i*(imag(RF_Struct.B2_Mat)*X(1)+imag(RF_Struct_2.B2_Mat)*X(2)),  ...
                     1i*(imag(RF_Struct.B3_Mat)*X(1)+imag(RF_Struct_2.B3_Mat)*X(2)), ...
                     RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     RF_Struct.d1*1e-3, ... % dx, m
                     RF_Struct.d2*1e-3, ... % dy, m
                     RF_Struct.d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     freq_rf,... freq in Hz
                     +1);% standing wave
    LM_RF = M_Loop.get_length();
    M_Loop.set_odeint_algorithm('rk2');
    M_Loop.set_nsteps(LM_RF*1000/0.1); % [40 mm] with steps every 0.1 mm
    M_Loop.set_tt_nsteps(ceil(LM_RF*1000)); % tt every mm

    L = Lattice();
    L.append(M_Loop, 0, 0, 0, reference = "entrance")
    L.append(D0);
    L.append(Q1);
    L.append(D2);

    % Autophase to calculate the phase of the cavity
    P_i = Bunch6d (mass, 1, charge, [a*1000 0 0 0 0 Pref]);
    P_f = L.autophase(P_i);
    t0 = L{1}.get_t0;
    L{1}.set_phid(270)
    L{1}.set_aperture(a, a);

    B1 = L.track(B0);

    % Extract phase space parameters
    Bf_phase = B1.get_phase_space();
    X_ff = Bf_phase(:,1);

    r_t_mm = sqrt(pi/2)*sqrt(emitt_geo_x_0*1e-6*beta_x_f_def)*cos(phase_adv_def)*1000;
    bins_optim = linspace(-2*r_t_mm,2*r_t_mm,no_bins);

    h = hist(X_ff,bins_optim,population);
    h = h(2:end-1); bins_optim = bins_optim(2:end-1);

    A = h(((length(bins_optim))-1)/2+1);

    BoxFitAll = A*(abs(bins_optim)<=r_t_mm);
    PipeFactor = 0.85;
    BoxBool = abs(bins_optim)<=r_t_mm*PipeFactor;
    BoxData = h(BoxBool);
    BoxFit = A*ones(1,length(BoxData));
    SSE = sqrt(sum((BoxData-BoxFit).^2))/population*1000;
    FoM = SSE;
    DispSpec = '%0.2f';

    LW = 1.5;
    colours = jet(4);
   figure(21); clf; hold all;
    plot(bins_optim,BoxFitAll/A,':k','Linewidth',LW,'handlevisibility','off')
    plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW,'displayname','$1\times\tilde{g}_4$')
    xlabel('$x$ [mm]', 'interpreter','latex')
    ylabel('Relative Intensity', 'interpreter','latex');
    title(['Survived = ' num2str(B1.get_ngood/nParticles*100) '%'])
    ylim([0 2])
    grid; box on;
    set(gca,'FontSize',24)
    drawnow

   disp(['FoM = ' num2str(FoM,DispSpec) '; X = ' num2str(X)]);
end
Xarr = sort(X_ii)';
SF = SF_default;  SF_2 = SF_2_default;
O = optimset('TolX', 0.01, 'TolFun', 0.01, 'MaxFunEvals', 1e5, 'MaxIter', 1e5); % Define optimset
FracSearch = 0.5;
box_func_RF = @(X)RF_Box_Fitter(X,Xarr,RF_Struct,RF_Struct_2,freq_rf,mass,charge,D0,Q1,D2,a,B0,emitt_geo_x_0,beta_x_f_def,phase_adv_def,no_bins,SF,SF_2,FracSearch,Pref,population,nParticles)
X_0 = [0, 0];
[XOptim,SSE] = fminsearch(box_func_RF, X_0, O);
##SF = -264; SF_2 = -2216; % Solved for values for Pref = 2000 me



% THREE MULTIPOLES
function [FoM] = RF_Box_Fitter_3(X,Xarr,RF_Struct,RF_Struct_2,RF_Struct_3,freq_rf,mass,charge,D0,Q1,D2,a,B0,emitt_geo_x_0,beta_x_f_def,phase_adv_def,no_bins,SF,SF_2,SF_3,FracSearch,Pref,population,nParticles)
    Sigmas2Fit = 3;
    RF_Track;
    c = 299792458;
    X_Test = [SF SF_2 SF_3];
    X =  X_Test .* 10.^(F_Constraint( X, -FracSearch, +FracSearch))


    M_Loop = RF_FieldMap_CINT(real(RF_Struct.E1_Mat)*X(1)+real(RF_Struct_2.E1_Mat)*X(2)+real(RF_Struct_3.E1_Mat)*X(3),...
                      real(RF_Struct.E2_Mat)*X(1)+real(RF_Struct_2.E2_Mat)*X(2)+real(RF_Struct_3.E2_Mat)*X(3),...
                      real(RF_Struct.E3_Mat)*X(1)+real(RF_Struct_2.E3_Mat)*X(2)+real(RF_Struct_3.E3_Mat)*X(3), ...
                     1i*(imag(RF_Struct.B1_Mat)*X(1)+imag(RF_Struct_2.B1_Mat)*X(2)+imag(RF_Struct_3.B1_Mat)*X(3)), ...
                     1i*(imag(RF_Struct.B2_Mat)*X(1)+imag(RF_Struct_2.B2_Mat)*X(2)+imag(RF_Struct_3.B2_Mat)*X(3)),  ...
                     1i*(imag(RF_Struct.B3_Mat)*X(1)+imag(RF_Struct_2.B3_Mat)*X(2)+imag(RF_Struct_3.B3_Mat)*X(3)), ...
                     RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     RF_Struct.d1*1e-3, ... % dx, m
                     RF_Struct.d2*1e-3, ... % dy, m
                     RF_Struct.d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     freq_rf,... freq in Hz
                     +1);% standing wave
    LM_RF = M_Loop.get_length();
    M_Loop.set_odeint_algorithm('rk2');
    M_Loop.set_nsteps(LM_RF*1000/0.1); % [40 mm] with steps every 0.1 mm
    M_Loop.set_tt_nsteps(ceil(LM_RF*1000)); % tt every mm

    L = Lattice();
    L.append(M_Loop, 0, 0, 0, reference = "entrance")
    L.append(D0);
    L.append(Q1);
    L.append(D2);

    % Autophase to calculate the phase of the cavity
    P_i = Bunch6d (mass, 1, charge, [a*1000 0 0 0 0 Pref]);
    P_f = L.autophase(P_i);
    t0 = L{1}.get_t0;
    L{1}.set_phid(270)
    L{1}.set_aperture(a, a);

    B1 = L.track(B0);

    % Extract phase space parameters
    Bf_phase = B1.get_phase_space();
    X_ff = Bf_phase(:,1);

    r_t_mm = sqrt(pi/2)*sqrt(emitt_geo_x_0*1e-6*beta_x_f_def)*cos(phase_adv_def)*1000;
    bins_optim = linspace(-2*r_t_mm,2*r_t_mm,no_bins);

    h = hist(X_ff,bins_optim,population);
    h = h(2:end-1); bins_optim = bins_optim(2:end-1);

    A = h(((length(bins_optim))-1)/2+1);

    BoxFitAll = A*(abs(bins_optim)<=r_t_mm);
    PipeFactor = 0.95;
    BoxBool = abs(bins_optim)<=r_t_mm*PipeFactor;
    BoxData = h(BoxBool);
    BoxFit = A*ones(1,length(BoxData));
    SSE = sqrt(sum((BoxData-BoxFit).^2))/population*1000;
    FoM = SSE;
    DispSpec = '%0.2f';

    LW = 1.5;
    colours = jet(4);
   figure(21); clf; hold all;
    plot(bins_optim,BoxFitAll/A,':k','Linewidth',LW,'handlevisibility','off')
    plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW,'displayname','$1\times\tilde{g}_4$')
    xlabel('$x$ [mm]', 'interpreter','latex')
    ylabel('Relative Intensity', 'interpreter','latex');
    title(['Survived = ' num2str(B1.get_ngood/nParticles*100) '%'])
    ylim([0 2])
    grid; box on;
    set(gca,'FontSize',24)
    drawnow

    BoxFunc = [zeros(1,sum(bins_optim<-r_t_mm)) A*ones(1,sum(abs(bins_optim)<=r_t_mm)) zeros(1,sum(bins_optim>r_t_mm)) ];
    Weight = exp(-bins_optim.^2/2/r_t_mm^2);
    SSE_Weighted = sqrt(sum(Weight.*(BoxFunc-h).^2))/population*1000;

   disp(['SF = ' num2str(X) '; SSE = ' num2str(FoM,DispSpec) '; SSE Weighted = ' num2str(SSE_Weighted)]);

##   disp(['FoM = ' num2str(FoM,DispSpec) '; X = ' num2str(X)]);
end
Xarr = sort(X_ii)';
# SF = 18.439; SF_2 = -21.10; SF_3 = 300.31;
SF = SF_default;  SF_2 = SF_2_default; SF_3 = SF_3_default;
O = optimset('TolX', 0.01, 'TolFun', 0.01, 'MaxFunEvals', 1e5, 'MaxIter', 1e5); % Define optimset
FracSearch = 0.5;
box_func_RF = @(X)RF_Box_Fitter_3(X,Xarr,RF_Struct,RF_Struct_2,RF_Struct_3,freq_rf,mass,charge,D0,Q1,D2,a,B0,emitt_geo_x_0,beta_x_f_def,phase_adv_def,no_bins,SF,SF_2,SF_3,FracSearch,Pref,population,nParticles)
X_0 = [0, 0, 0];
[XOptim,SSE] = fminsearch(box_func_R_F, X_0, O);
##SF = -264; SF_2 = -2216; % Solved for values for Pref = 2000 me



