

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

### DEFINE BEAMLINE ###

%% Tracking variables
population = 1e6; % particles
nParticles = population/50;

%% Fixed variables
mass = RF_Track.electronmass;
charge = 1;

%% Varying variables
Pref = 2000*mass;
emitt_geo_x_0 = 21; % [mm.mrad] = geometric emittance
beta_x_0 = 15; %[m]
alpha_x_0 = 15; %[]
freq_rf = 3e9; % [Hz]

%% Useful derived quantities
Eref = sqrt(Pref^2+mass^2);
gammaref = Eref./mass;
betaref =sqrt(1-1/gammaref^2);

% Specify multipole magnet length (strengths to come later)
LM = 0.05; % [m]

RF_File = '0_5_Steps.dat';

RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260226_TM_410_Pill/';
RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260226_TM_4610_9/';
##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260310_TM_4610_2/';
LPipe = 50/1000;
a = 50/1000; % [m] pipe radius

##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260310_TM_410_LP/';
##LPipe = 100/1000;
##a = 50/1000; % [m] pipe radius

##RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260310_TM_410_SBP/';
##LPipe = 100/1000;
##a = 25/1000; % [m] pipe radius

RF_Folder ='/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260310_TM_610_Pill/';
LPipe = 50/1000;
a = 50/1000; % [m] pipe radius

RF_Struct = load(fullfile(RF_Folder,RF_File));
RF_Struct.LPipe = LPipe;
RF_Struct_Orig = RF_Struct;


Multipoles = 1; % set number of multipoles you want to look at

%% Bool Selection %%
PlotBetaBool = true;
PlotInitialDistBool = true;
PlotInitialFinalBool = true;

%% Plotting Parameters %%
FigNo = 1;
no_bins = 101;
EndBeamDist = 200; % Set the xlim for plots
sigma_max_bin = 6; % number of sigmas to plot


###### BEGIN AUTO SCRIPTING ###

%% Create particle distribution %%
emitt_x_0 = emitt_geo_x_0*betaref*gammaref; % RF_Track uses normalised emittance
T = Bunch6d_twiss();
T.emitt_x = emitt_x_0; % [mm.mrad], normalised horizontal emittance x.px
T.beta_x = beta_x_0; % [m], horizontal beta function
T.alpha_x = alpha_x_0;
T.emitt_y = 0; % mm.mrad, normalised vertical emittance y.py
T.beta_y = 0; % m, vertical beta function
T.alpha_y = 0;

B0 = Bunch6d_QR (mass, population, charge, Pref, T, nParticles, sigmaCut=0);

%% Extract initial particle distribution %%
B0_phase = B0.get_phase_space();
X_ii = B0_phase(:,1);

%% Plot initial distribution %%
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

%% Calculate initial particle density distributions %%
I = B0.get_info();
sigma_0 = I.sigma_x; % [mm] extract beam size for Gaussian beam
x_0_arr = linspace(-sigma_max_bin*sigma_0,sigma_max_bin*sigma_0,10*no_bins+1); % [mm], create binning array
rho_0_arr = population/(sqrt(2*pi)*sigma_0)*exp(-x_0_arr.^2./2/sigma_0.^2); % [N], create density plot

%% Bin the initial distribution %%
bin_start_0 = -sigma_max_bin*sigma_0;
bin_end_0 = sigma_max_bin*sigma_0;
bins_0 = linspace(bin_start_0,bin_end_0,no_bins); % create array of bins
h_0 = hist(X_ii,bins_0,population); % get the histogram values and normalise to number of particles

%% Normalise the predicted distribution %%
% NOTE, an issue we have is that the value of the binning affects the peak.
% To overcome, plot distribution at the same central value. Adjust the prediction
rho_0_arr_plot = rho_0_arr/rho_0_arr((end-1)/2+1)*h_0((end-1)/2+1);

### SPECIFY GENERAL BEAMLINE ###
% Specify quadrupole in lattice
Q1_s0 = 0.2; % [m], 0.22 to agree with data more
kQ1 = -4.25*charge; % [1/m], 4.25 gives accurate phase advance, 5 gives accurate beta
LQ1 = 0.3; % [m]

% Specify beamline
LBeamline = 1.7;

### BEAM TRACKING IN TESTLINE NO ADDITIONAL###
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

##rho_f_arr_Gauss_def = population/(sqrt(2*pi)*sigma_f).*exp(-x_f_arr.^2./2/sigma_f.^2)./...
##(sqrt(beta_x_f_def/beta_x_0)*cos(phase_adv_def)); % calculate based on density evolution
##rho_f_arr_Gauss_def_plot = rho_f_arr_Gauss_def/rho_f_arr_Gauss_def((end-1)/2+1)*h_f_def((end-1)/2+1);

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



### GUESS MULTIPOLES ###
function output = MultipoleFunction(M,x)
    output = (-1)^(x+1)*(M+2*(x+1))/(factorial(x+1)*factorial(M+x+1));
end

k_rf = 2*pi*freq_rf/c; Leff = LM; % Note this is the integral of the transit time factor. May need modifying

%% Calculate multipoles by fitting as best as possible
Sigmas2Plot = 3;
x_0 = -Sigmas2Plot*sigma_0; Xa_L = 501; r_0 = Sigmas2Plot*sigma_0;
Xa = linspace(-a*1000, a*1000, Xa_L); % m
M_i = 4; % always going from octupole

IdealLoops = 50; colours = viridis(IdealLoops);
g_m_ideal = []; cav_phase = pi/2;
for ii = 1:IdealLoops % Loop through multipoles
    if ii == 1
      B_ideal = zeros(1,length(Xa));
      delta_p_B_1 = zeros(1,length(Xa));
      delta_p_B_2 = zeros(1,length(Xa));
      delta_p_g = zeros(1,length(Xa));
    endif
    % Remember to convert emittance to [m.rad]
    m = (2*ii+2);
    if ii == 1 % if octupole, no recursivity.
        kNL = 2/(2*emitt_geo_x_0*1e-6*beta_x_0)/beta_x_0/tan(phase_adv_def); % calculate magnetic multipole
        MultArray = [0 kNL]; % This is the array for magnetic multipoles
        RF_Oct = [kNL*(2^M_i)/k_rf^(M_i-1)*Pref*1e6/charge/Leff]; % The octupole guess is good
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
    delta_p_B_1 = delta_p_B_1+1e-6*charge*c*B_ideal_loop*LM; %[MeV/c]
##    delta_p_B_2 = delta_p_B_2+B_ideal_loop*LM/RF_Track.C/5.344e-23;
##    delta_p_B_2 = delta_p_B_2+Pref*kNL*(Xa/1000).^(m-1)/factorial(m-1)*1e6;
##    delta_p_g = delta_p_g+charge/(2*pi*freq_rf)*LM/a*sin(k_rf*LM/2)/(k_rf*LM/2)*g_m_ideal_loop*besselj(m,k_rf*a)*(Xa/1000).^(m-1)*m;
    delta_p_g = delta_p_g+charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_ideal_loop)*besselj(m,k_rf*a)*(Xa/1000/a).^(m-1)*c;
    plot_bool = true;
    if plot_bool == true
      if ii == 1
        figure(); hold all;
        plot(Xa,delta_p_g,'linewidth',LW,'displayname','$m~=~4$','color',colours(ii,:));
      else
        plot(Xa,delta_p_g,'linewidth',LW,'displayname',['$m~\le~' num2str(m) '$'],'color',colours(ii,:));
    endif
    end
end
plot(Xa,delta_p_B_1,'k--','linewidth',LW,'displayname','$m~=~\infty$');
xlabel('$x$ [mm]', 'interpreter','latex')
ylabel('$\Delta p_\perp$ [MeV/c]', 'interpreter','latex');
legend('location','Northoutside','orientation','horizontal','interpreter','latex')
xlim([-a*1000,a*1000])
grid; box on;
set(gca,'FontSize',26)
drawnow

##figure(); hold all; plot(Xa,delta_p_B_1); plot(Xa,delta_p_g,'--','linewidth',2.5);
##title('Check equations for RF cavity and ideal magnet'); xlabel('x [mm]'); ylabel('\Delta p [MeV/c]')
##figure(); hold all; plot(Xa,B_ideal);

##figure(); hold all;
##SigBool = abs(Xa)<5*sigma_0; GaussBeam = exp(-Xa.^2/2/sigma_0^2);
##yLim = 0.1;
##plot(Xa(SigBool), yLim*GaussBeam(SigBool),'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
##plot(Xa(SigBool),B_ideal(SigBool) ,'--', 'linewidth',LW,'Displayname','Ideal B_y')
##plot(xlim,[ 0 0],'-k','handlevisibility','off')
##plot([ 0 0], ylim,'-k','handlevisibility','off')
##xlabel('x [mm]')
##ylabel('B [T]');
##legend('Location','EastOutside')
##set(gca,'FontSize',FS)
##ylim([-yLim yLim])
##grid on; box on;

T_E = RF_FieldMap_CINT(real(RF_Struct.E1_Mat), real(RF_Struct.E2_Mat), real(RF_Struct.E3_Mat), ...
                 1i*imag(RF_Struct.B1_Mat), 1i*imag(RF_Struct.B2_Mat),  1i*imag(RF_Struct.B3_Mat), ...
                 RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                 RF_Struct.d1*1e-3, ... % dx, m
                 RF_Struct.d2*1e-3, ... % dy, m
                 RF_Struct.d3*1e-3, ... % dz, m
                 -1, ... % take the default size
                 0,%freq_rf*1e9,... freq in Hz
                 +1);% standing wave

T_B = RF_FieldMap_CINT(1i*(RF_Struct.E1_Mat), 1i*real(RF_Struct.E2_Mat), 1i*real(RF_Struct.E3_Mat), ...
                 imag(RF_Struct.B1_Mat), imag(RF_Struct.B2_Mat),  imag(RF_Struct.B3_Mat), ...
                 RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                 RF_Struct.d1*1e-3, ... % dx, m
                 RF_Struct.d2*1e-3, ... % dy, m
                 RF_Struct.d3*1e-3, ... % dz, m
                 -1, ... % take the default size
                 0,%freq_rf*1e9,... freq in Hz
                 +1);% standing wave

% FIGURE OUT AND CHECK THE RATIOS
Ez_circ = [];
Ta = linspace(0,2*pi,721);
for Ti = Ta
   [E,B] = T_E.get_field(a*1000*cos(Ti), a*1000*sin(Ti), T_E.get_length()/2*1000, 0); % x,y,z,t (mm, mm/c)
    Ez_circ = [ Ez_circ ; E(3) ];
end
FFT = 2*fft(Ez_circ); FFT(1) = FFT(1)/2;
FFT_f = FFT(1:length(FFT)/2)/(length(FFT));

G_m_arr = sqrt(real(FFT_f).^2+imag(FFT_f).^2).*sign(real(FFT_f));

% SANITY CHECK THE FIELD
plot_bool = false;
if plot_bool == true
    Za = linspace(0,T_E.get_length(),501);
    Ez_a = []; By_a = [];
    for Z = Za
        [E,B] = T_E.get_field(a*1000, 0, Z*1000, Z); % x,y,z,t (mm, mm/c)
        Ez_a = [ Ez_a ; E(3) ];

        [E,B] = T_B.get_field(a*1000, 0, Z*1000, 0); % x,y,z,t (mm, mm/c)
        By_a = [ By_a ; B(2) ];
    end
    figure(); subplot(1,2,1); plot(Za,Ez_a); subplot(1,2,2); plot(Za,By_a)

    figure(); hold all; plot(Ta,Ez_circ)
    Ez_FFT = zeros(1,length(Ta));
    for ii = 1:Multipoles
        n = ii*2+2;
##        n = ii;
        Ez_FFT =  Ez_FFT+G_m_arr(n+1)*cos(n*Ta);
    end
    plot(Ta,Ez_FFT)
end

% Sanity check the field at a different points - circle
plot_bool = false;
if plot_bool == true
    Za = linspace(0,T_E.get_length(),501);
    Ez_a = []; By_a = [];
    a_sample = a/6;
    Ta = linspace(0,2*pi,721);
    Ez_circ_sample = [];
    for Ti = Ta
       [E,B] = T_E.get_field(a_sample*1000*cos(Ti), a_sample*1000*sin(Ti), T_E.get_length()/2*1000, 0); % x,y,z,t (mm, mm/c)
        Ez_circ_sample = [ Ez_circ_sample ; E(3) ];
    end

    figure(); hold all; plot(Ta,Ez_circ_sample,'b')
    Ez_FFT = zeros(1,length(Ta));
    for ii = 1:Multipoles
        n = ii*2+2;
        Ez_FFT =  Ez_FFT+G_m_arr(n+1)*cos(n*Ta)*besselj(n,k_rf*a_sample)/besselj(n,k_rf*a);
    end
    plot(Ta,Ez_FFT,'r')
end

% Sanity check the field at a different points - radial
plot_bool = false;
if plot_bool == true
    x_arr = linspace(0,a,201);
    Ez_x_sample = [];
    for x = x_arr
       [E,B] = T_E.get_field(x*1000, 0, T_E.get_length()/2*1000, 0); % x,y,z,t (mm, mm/c)
        Ez_x_sample = [ Ez_x_sample ; E(3) ];
    end

    figure(); hold all; plot(x_arr,Ez_x_sample)
    Ez_FFT = zeros(1,length(x_arr));
    for ii = 1:Multipoles
        n = ii*2+2;
        Ez_FFT =  Ez_FFT+G_m_arr(n+1)*besselj(n,k_rf*x_arr)/besselj(n,k_rf*a);
    end
    plot(x_arr,Ez_FFT)
end


% Calculate scaling
for ii = 1:Multipoles
    n = 2*ii+2;
    g_m_arr(ii) = G_m_arr(n+1)/besselj(n,k_rf*a)*1e-6; % [MV/m]
end
SF_default = g_m_ideal(1)/g_m_arr(1);

SF = SF_default;

##SF = 1.5*SF_default;
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
M.set_nsteps(LM_RF*1000/0.1); % [40 mm] with steps every 0.1 mm
M.set_tt_nsteps(ceil(LM_RF*1000)); % tt every mm

L = Lattice();
L.append(M, 0, 0, 0, reference = "entrance")
% Create first drift
D0L = Q1_s0-LM_RF;
D0 = Drift(D0L);
D0.set_tt_nsteps(round(D0L*100)); % tt every 10 mm
L.append(D0);
L.append(Q1);
L.append(D2);

% Autophase to calculate the phase of the cavity
P_i = Bunch6d (mass, 1, charge, [a*1000 0 0 0 0 Pref]);
P_f = L.autophase(P_i);
L{1}.get_t0;
L{1}.set_phid(270)
L{1}.set_aperture(a, a);
% Calculate with theory
##if plot_bool == true
##    L{1}.set_phid(0);
##    Za = linspace(0,M.get_length()*1000,501);
##    Xa = linspace(0,a*1000,51);
##    figure(); hold all;
##    pw = []; count = 1;
##    for X = Xa
##      Ez_pw = [];
##        for Z = Za
##            [E,B] = L.get_field(X, 0, Z, Z); % x,y,z,t (mm, mm/c)
##            Ez_pw = [ Ez_pw ; E(3) ];
##        end
##        plot(Za,Ez_pw)
##        pw(count) = trapz(Za/1000,Ez_pw);
##        count = count + 1;
##    end
##    figure(); plot(Xa,pw)
##end

% plot some fields
plot_bool = false;
if plot_bool == true
    Za = linspace(0,T_E.get_length(),501);
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

    Za = linspace(0,T_E.get_length(),501);
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

LW = 1.5;
colours = jet(4);
figure(10); hold on;
##'g', 'm','r','b','g', [.7 .7 .7]
plot(bins_optim,BoxFitAll/A,':k','Linewidth',LW,'handlevisibility','off')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'color',[.7 .7 .7],'Linewidth',LW,'displayname','$0\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'m','Linewidth',LW,'displayname','$0.75\times\tilde{g}_4$')
plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW,'displayname','$1\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'b','Linewidth',LW,'displayname','$1.25\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'g','Linewidth',LW,'displayname','$1.5\times\tilde{g}_4$')
xlabel('$x$ [mm]', 'interpreter','latex')
ylabel('Relative Intensity', 'interpreter','latex');
title(['Survived = ' num2str(B1.get_ngood/nParticles*100) '%'])
ylim([0 2])
grid; box on;
set(gca,'FontSize',24)
drawnow
##legend('location','Northoutside','orientation','horizontal','interpreter','latex')

%% Plot Momentum Changes etc
plot_bool = true;
if plot_bool == true

  SF = SF_default;

  ##SF = 1.5*SF_default;
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
  M.set_nsteps(LM_RF*1000/0.1); % [40 mm] with steps every 0.1 mm
  M.set_tt_nsteps(ceil(LM_RF*1000)); % tt every mm

    Za = linspace(0,M.get_length()*1000,501);
    Xa3 = linspace(-a*1000,a*1000,501);
    pw_sim = [];
##    figure(); hold all;
    for X = Xa3
      By_a = [];
        for Z = Za
            [E,B] = L.get_field(X, 0, Z, Z); % x,y,z,t (mm, mm/c)
            By_a = [ By_a ; B(2) ];
        end
##        plot(Za,By_a)
        pw_sim = [pw_sim trapz(Za/1000,By_a*1e-6*charge*c)];
    end

    pw_theory = zeros(1,length(Xa));
    pw_track_theory = zeros(1,length(Xa));
    figure(); hold all;
    plot(Xa,delta_p_B_1,'r','Displayname','Ideal Magnet');
    plot(Xa,delta_p_g,'m--','Displayname','Ideal RF-Cavity','linewidth',1.1);
    plot(Xa3,pw_sim,'b','Displayname','RF-Track B_y Integral')
    for ii = 1:Multipoles
         m = (2*ii+2);
        pw_theory = pw_theory+ charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_ideal(ii))*besselj(m,k_rf*a)*(Xa/1000/a).^(m-1)*c;
        pw_track_theory = pw_track_theory + charge/(2*pi*freq_rf)*(LM/a)*sin(k_rf*LM/2)/(k_rf*LM/2)*(m*g_m_arr(ii)*SF_default)*besselj(m,k_rf*a)*(Xa/1000/a).^(m-1)*c;
    endfor
    plot(Xa,pw_theory,'g--','Displayname',['Ideal Multipoles = ' num2str(Multipoles) ' RF Prediction'],'linewidth',1.1)
    plot(Xa,pw_track_theory,'c','Displayname','RF Theory from Measured')


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

    % LATTICE
    L2 = Lattice();
    L2.append(M, 0, 0, 0, reference = "entrance")
    % Autophase to calculate the phase of the cavity
    P_i = Bunch6d (mass, 1, charge, [a/2*1000 0 0 0 0 Pref]);
    P_f = L2.autophase(P_i);
    L2{1}.get_t0;
    L2{1}.set_phid(270)
    B2 = L2.track(B0);
    B2_ps = B2.get_phase_space();
    B2_IDs = B2.get_phase_space('%id');
    Delta_Px = (B2_ps(:,2)-B0_phase(B2_IDs+1,2))*Pref/1000;
##    Delta_Px = (B2_ps(:,2)-B0_phase(:,2))*Pref/1000;
##    [sort_X, poses] = sort(X_ii);
    [sort_X, poses] = sort(X_ii(B2_IDs+1));
    plot(sort_X,-Delta_Px(poses),'k-','displayname','RF Tracked');
    title(['Survived particles = ' num2str(B2.get_ngood/nParticles*100)])

    xlim([0 50]); ylim([-10 70])
##    legend('location','eastoutside')

end


return

