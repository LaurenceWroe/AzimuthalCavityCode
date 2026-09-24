

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
Pref = 20*mass;
emitt_geo_x_0 = 21; % [mm.mrad] = geometric emittance
beta_x_0 = 15; %[m]
alpha_x_0 = 15; %[]
freq_rf = 3e9; % [Hz]


%% Useful derived quantities
Eref = sqrt(Pref^2+mass^2);
gammaref = Eref./mass;
betaref =sqrt(1-1/gammaref^2);

RFCavityBool = 1; # Make true to do it with RF cavity
if RFCavityBool == 5
##    RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/Azimuthally/Maps/Pipe/';
##    RF_File = 'Pipe.dat';
##    LPipe = 96/1000;

    RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/Azimuthally/Maps/NoPipe/';
    RF_File = 'NoPipe.dat';
    LPipe = 0;

    RF_Struct = load(fullfile(RF_Folder,RF_File));
    RF_Struct.LPipe = LPipe;
    RF_Struct_Orig = RF_Struct;
end

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
% Specify multipole magnet length (strengths to come later)
LM = 0.04; % [m]
##LM = 0.16; % [m]

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
Sigmas2Plot = 15;
x_0 = -Sigmas2Plot*sigma_0; Xa_L = 5001; r_0 = Sigmas2Plot*sigma_0;
Xa = linspace(x_0, r_0, Xa_L); % m
M = 4; % always going from octupole

IdealLoops = 50;
for ii = 1:IdealLoops % Loop through multipoles
    if ii == 1
      B_ideal = zeros(1,length(Xa));
    endif
    % Remember to convert emittance to [m.rad]
    m = (2*ii+2);
    if ii == 1 % if octupole, no recursivity.
        kNL = 2/(2*emitt_geo_x_0*1e-6*beta_x_0)/beta_x_0/tan(phase_adv_def); % calculate magnetic multipole
        MultArray = [0 kNL]; % This is the array for magnetic multipoles
        RF_Oct = [kNL*(2^M)/k_rf^(M-1)*Pref*1e6/charge/Leff]; % The octupole guess is good
    else
        kNL = -(2*ii-1)./(emitt_geo_x_0*1e-6*beta_x_0)*kNL;
        MultArray = [MultArray 0 kNL]; % further complete magnetic array
    end
    B_ideal = B_ideal+Pref*1e6/charge*kNL*(Xa/1000).^(m-1)/factorial(m-1)/LM/c;
end
return
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


function [FoM] = RF_Multipole_Calculator(X,B_ideal,freq_rf,Xa,sigma_0,Sigmas2Fit)

    MultArrayTemp =  X;
    MultArrayOptim = [];
    for ii = 1:length(MultArrayTemp)
        MultArrayOptim = [MultArrayOptim 0 MultArrayTemp(ii)];
    end
    MultArrayOptim = [0 0 0 MultArrayOptim]; % Must include the monopole!

    c = 299792458;
    B_test = zeros(1,length(Xa)); g_M = MultArrayOptim;  kappa_p = 2*pi*freq_rf/c; omega = 2*pi*freq_rf;
    M_index   = linspace(0,length(g_M)-1,length(g_M));
    for ii = 1:length(g_M)
        if g_M(ii) ~= 0 % Remove unnecessary calculation
            B_test  = B_test +real(1/omega.*kappa_p*g_M(ii).*(0.5*(besselj(M_index(ii)-1,kappa_p*Xa/1000)-besselj(M_index(ii)+1,kappa_p*Xa/1000))));
        end
    end

    SSEBool = abs(Xa)<Sigmas2Fit*sigma_0;
    Weight = exp(-Xa.^2/2/sigma_0^2);
    diff_val = Xa(2)-Xa(1); WeightErf = zeros(1,length(Xa));
    for jj = 1:length(Xa)
        WeightErf(jj) = 0.5*(erf((Xa(jj)+diff_val)/sigma_0)-erf((Xa(jj)-diff_val)/sigma_0));
    end

    SSE = sqrt(sum((B_test(SSEBool)-B_ideal(SSEBool)).^2));
    SSE_Weighted = sqrt(sum(WeightErf(SSEBool).*(B_test(SSEBool)-B_ideal(SSEBool)).^2));

##    FoM = SSE;
    FoM = SSE_Weighted*1e6;

    DispSpec = '%0.1f';
##    disp(['SSE = ' num2str(SSE,DispSpec) '; MultArray = ' num2str(MultArrayOptim)]);
end
Sigmas2Fit = 5;
O = optimset('TolX', 0.01, 'TolFun', 0.01, 'MaxFunEvals', 1e5, 'MaxIter', 1e5); % Define optimset
anon_func_RF = @(X)RF_Multipole_Calculator(X,B_ideal,freq_rf,Xa,sigma_0,Sigmas2Fit)
X_0 = zeros(1,Multipoles); X_0(1) = RF_Oct;
[XOptim,SSE] = fminsearch(anon_func_RF, X_0, O);
SSE
MultArray_RF_0 = XOptim

if RFCavityBool == 4

    function [FoM] = RF_Multipole_Calculator_TE(X,B_ideal,freq_rf,Xa,sigma_0,Sigmas2Fit,v,LM)

        MultArrayTemp =  X;
    ##    MultArrayTemp = 3e7;
        MultArrayOptim = [];
        for ii = 1:length(MultArrayTemp)
            MultArrayOptim = [MultArrayOptim 0 MultArrayTemp(ii)];
        end
        MultArrayOptim = [0 0 0 MultArrayOptim]; % Must include the monopole!

        T_ideal = -B_ideal * v;
        c = 299792458;
        E_test = zeros(1,length(Xa)); g_M = MultArrayOptim;  p = 1; k_p = (2*pi/LM); k_l = 2*pi*freq_rf/c; kappa_p = sqrt(k_l^2-k_p^2); omega = 2*pi*freq_rf;
        M_index   = linspace(0,length(g_M)-1,length(g_M));
        for ii = 1:length(g_M)
            if g_M(ii) ~= 0 % Remove unnecessary calculation
                E_test  = E_test - real(k_p./(kappa_p^2 .*Xa/1000).*M_index(ii).*g_M(ii).*besselj(M_index(ii),kappa_p*Xa/1000));
            end
        end
        E_test(isnan(E_test))=0;

        SSEBool = abs(Xa)<Sigmas2Fit*sigma_0;
        Weight = exp(-Xa.^2/2/sigma_0^2);
        diff_val = Xa(2)-Xa(1); WeightErf = zeros(1,length(Xa));
        for jj = 1:length(Xa)
            WeightErf(jj) = 0.5*(erf((Xa(jj)+diff_val)/sigma_0)-erf((Xa(jj)-diff_val)/sigma_0));
        end

        SSE = sqrt(sum((E_test(SSEBool)-T_ideal(SSEBool)).^2));
        SSE_Weighted = sqrt(sum(WeightErf(SSEBool).*(E_test(SSEBool)-T_ideal(SSEBool)).^2));

        if isnan(SSE)
          return
        endif
    ##    figure(201); clf; hold on;  plot(Xa(SSEBool),E_test(SSEBool),'b');plot(Xa(SSEBool),T_ideal(SSEBool),'r'); drawnow;

    ##    FoM = SSE;
        FoM = SSE_Weighted*1e6;

        DispSpec = '%0.1f';
    ##    disp(['SSE = ' num2str(SSE,DispSpec) '; MultArray = ' num2str(MultArrayOptim)]);
    end
    anon_func_RF_TE = @(X)RF_Multipole_Calculator_TE(X,B_ideal,freq_rf,Xa,sigma_0,Sigmas2Fit,c,LM)
    X_0 = zeros(1,Multipoles); X_0(1) = 3e7;
    [XOptim,SSE] = fminsearch(anon_func_RF_TE, X_0, O);
    SSE
    MultArray_RF_TE_0 = XOptim
end


if RFCavityBool == 5 % Aim of this is to normalise the field to be similar to desired, it works fair for initial guess
    T = RF_FieldMap_CINT(imag(RF_Struct.E1_Mat), imag(RF_Struct.E2_Mat), imag(RF_Struct.E3_Mat), ...
                     imag(RF_Struct.B1_Mat), imag(RF_Struct.B2_Mat),  imag(RF_Struct.B3_Mat), ...
                     RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     RF_Struct.d1*1e-3, ... % dx, m
                     RF_Struct.d2*1e-3, ... % dy, m
                     RF_Struct.d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     0,%freq_rf*1e9,... freq in Hz
                     +1);% standing wave
    ZPos = T.get_length()/2*1000;
    By_x = [];
    for X = Xa
        [E,B] = T.get_field(X, 0, ZPos, 0); % x,y,z,t (mm, mm/c)
        By_x = [ By_x ; B(2) ];
    end

    [~,Pos] = min(abs(Xa-2*sigma_0));
    CompPoints = 300;
    SF = B_ideal(Pos)/By_x(Pos);
##    figure(); hold all; plot(Xa((end+1)/2:Pos),By_x((end+1)/2:Pos)*SF); plot(Xa((end+1)/2:Pos),B_ideal((end+1)/2:Pos))
    RF_Struct.E1_Mat = RF_Struct.E1_Mat*SF; RF_Struct.B1_Mat = RF_Struct.B1_Mat*SF;
    RF_Struct.E2_Mat = RF_Struct.E2_Mat*SF; RF_Struct.B2_Mat = RF_Struct.B2_Mat*SF;
    RF_Struct.E3_Mat = RF_Struct.E3_Mat*SF; RF_Struct.B3_Mat = RF_Struct.B3_Mat*SF;
##    figure(); hold all; plot(Xa((end+1)/2:Pos+CompPoints),By_x((end+1)/2:Pos+CompPoints)*SF); plot(Xa((end+1)/2:Pos+CompPoints),B_ideal((end+1)/2:Pos+CompPoints))
end

%% Predict radius of uniform beam
r_t_mm = sqrt(pi/2)*sqrt(emitt_geo_x_0*1e-6*beta_x_f_def)*cos(phase_adv_def)*1000;
bins_optim = linspace(-2*r_t_mm,2*r_t_mm,no_bins);
if sum(bins_optim==r_t_mm) == 0
    error('Ensure the bins_optim includes the box edges')
end
FracSearch = 2; % Set some factor of 10 to search for multipole strengths in

function [FoM] = BoxFitterCavity(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_0,FracSearch,freq_rf,sigma_0,MakeGifBool,PlotBoxBool)

    load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
    RF_Track;
##    X = zeros(1,Multipoles); % UNCOMMENT TO RUN

    MultArrayTemp =  MultArray_RF_0 .* 10.^(F_Constraint( X, -FracSearch, +FracSearch))
    MultArrayOptim = [];

    for ii = 1:length(MultArrayTemp)
        MultArrayOptim = [MultArrayOptim 0 MultArrayTemp(ii)];
    end
    MultArrayOptim = [0 0 0 MultArrayOptim]; % Must include the monopole!

    % Create multipole cavity
    r_rf_interest = 5*sigma_0;
    [M, MaxEz] = F_MultipoleCav(MultArrayOptim,freq_rf,LM,r_rf_interest,PlotBool=false);
    M.set_odeint_algorithm('rk2');
    M.set_nsteps(LM*1000/0.1); % [40 mm] with steps every 0.1 mm
    M.set_tt_nsteps(LM*1000); % tt every mm

    MaxEz

    %% Lattice creation
    if MakeGifBool == false
        L = Lattice();
        L.append(M);
        L.append(D1);
        L.append(Q1);
        L.append(D2);
    else
        V = Volume();
        V.add(M,0,0,0);
        V.add(D1,0,0,LM)
        V.add(Q1,0,0,LM+D1.get_length())
        V.add(D2,0,0,LM+D1.get_length()+Q1.get_length())
    end

    %% Plot field on axis (if desired)
    PlotFieldBool = 0;
    if PlotFieldBool == true

        x_0 = -5*sigma_0; Xa_L = 5001; r_0 = 5*sigma_0;
        Xa = linspace(x_0, r_0, Xa_L); % m

        E_test = zeros(1,length(Xa));
        B_test = zeros(1,length(Xa)); g_M = MultArrayOptim;  kappa_p = 2*pi*freq_rf/c; omega = 2*pi*freq_rf;
        M_index   = linspace(0,length(g_M)-1,length(g_M));
        for ii = 1:length(g_M)
            if g_M(ii) ~= 0 % Remove unnecessary calculation
                B_test  = B_test +real(1/omega.*kappa_p*g_M(ii).*(0.5*(besselj(M_index(ii)-1,kappa_p*Xa/1000)-besselj(M_index(ii)+1,kappa_p*Xa/1000))));
                E_test  = E_test +real(g_M(ii).*(besselj(M_index(ii),kappa_p*Xa/1000)));
            end
        end

        for ii = 1:50 % Loop through multipoles
            if ii == 1
              B_ideal = zeros(1,length(Xa));
            endif
            % Remember to convert emittance to [m.rad]
            m = (2*ii+2);
            if ii == 1 % if octupole, no recursivity.
                kNL = 2/(2*emitt_geo_x_0*1e-6*beta_x_0)/beta_x_0/tan(phase_adv_def); % calculate magnetic multipole
            else
                kNL = -(2*ii-1)./(emitt_geo_x_0*1e-6*beta_x_0)*kNL;
            end
            B_ideal = B_ideal+Pref*1e6/charge*kNL*(Xa/1000).^(m-1)/factorial(m-1)/LM/c;
        end

        x_0 = -5*sigma_0; Xa_L = 5001; r_0 = 5*sigma_0;
        Xa = linspace(x_0, r_0, Xa_L); % m
        Bx_x = []; By_x = []; Bz_x = [];
        Ex_x = []; Ey_x = []; Ez_x = [];
        for X = Xa
            [E,B] = M.get_field(X, 0, 0, 0); % x,y,z,t (mm, mm/c)
            Bx_x = [ Bx_x ; B(1) ];
            By_x = [ By_x ; B(2) ];
            Bz_x = [ Bz_x ; B(3) ];
            Ex_x = [ Ex_x ; E(1) ];
            Ey_x = [ Ey_x ; E(2) ];
            Ez_x = [ Ez_x ; E(3) ];
        end
        Ya = linspace(x_0, r_0, Xa_L); % m
        Bx_y = []; By_y = []; Bz_y = [];
        Ex_y = []; Ey_y = []; Ez_y = [];
        for Y = Ya
            [E,B] = M.get_field(0, Y, 0, 0); % x,y,z,t (mm, mm/c)
            Bx_y = [ Bx_y ; B(1) ];
            By_y = [ By_y ; B(2) ];
            Bz_y = [ Bz_y ; B(3) ];
            Ex_y = [ Ex_y ; E(1) ];
            Ey_y = [ Ey_y ; E(2) ];
            Ez_y = [ Ez_y ; E(3) ];
        end

        figure(); clf; subplot(2,1,1); hold on;
        yLim = 1;
        plot(Xa, Bx_x, 'linewidth',LW,'Displayname','B_x along x')
        plot(Xa, By_x, 'linewidth',LW,'Displayname','B_y along x')
        plot(Xa, Bz_x, 'linewidth',LW,'Displayname','B_z along x')
        plot(Xa, B_test, '--', 'linewidth',LW,'Displayname','Predicted B_y')
##            plot(Xa,B_ideal,'--', 'linewidth',LW,'Displayname','Ideal B_y')
        plot(Xa, E_test/max(E_test)*max(B_test), '--', 'linewidth',LW,'Displayname','Predicted E_z')
        GaussBeam = exp(-Xa.^2/2/sigma_0^2);
        plot(Xa, yLim*GaussBeam,'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        xlabel('x [mm]')
        ylabel('B [T]');
        xlim([x_0 r_0]);
        title(['Field in entire component (MaxEz = ' num2str(MaxEz/1e6,DispSpec) ' MV/m)'])
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
        ylim([-yLim yLim])

        subplot(2,1,2); hold on;
        SigBool = abs(Xa)<5*sigma_0;
        yLim = 0.1;
        plot(Xa(SigBool), Bx_x(SigBool), 'linewidth',LW,'Displayname','B_x along x')
        plot(Xa(SigBool), By_x(SigBool), '--', 'linewidth',LW,'Displayname','B_y along x')
        plot(Xa(SigBool), yLim*GaussBeam(SigBool),'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        plot(Xa(SigBool),B_ideal(SigBool) ,'--', 'linewidth',LW,'Displayname','Ideal B_y')
        xlabel('x [mm]')
        ylabel('B [T]');
        title('Field across beam size')
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
        ylim([-yLim yLim])
  end

    %% Lattice tracking
    if MakeGifBool == false
        B1 = L.track(B0);

    else
        V.wp_dt_mm =  20;
        V.tt_dt_mm = 1;
        B1 = V.track(B0);
        R_max = r_t_mm*1.5;
        gif_name = 'test';
        F_Make_RF_Track_Gif_Azi(B0,V,gif_name,R_max)
    end

    % Extract phase space parameters
    Bf_phase = B1.get_phase_space();
    X_ff = Bf_phase(:,1);

    h = hist(X_ff,bins_optim,population);
    h = h(2:end-1); bins_optim = bins_optim(2:end-1);

    A = h(((length(bins_optim))-1)/2+1);

    BoxFitAll = A*(abs(bins_optim)<=r_t_mm);
##        SSE = sum((h-BoxFitAll).^2);

    BoxBool = abs(bins_optim)<=r_t_mm;
    BoxData = h(BoxBool);
    BoxFit = A*ones(1,length(BoxData));
    SSE = sqrt(sum((BoxData-BoxFit).^2))/population*1000;
    FoM = SSE;
    DispSpec = '%0.2f';
    disp(['SSE = ' num2str(SSE,DispSpec) '; MultArray = ' num2str(MultArrayOptim)]);


    if PlotBoxBool == true
        figure(101); clf; hold on;
        plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW)
        plot(bins_optim,BoxFitAll/A,'b','Linewidth',LW)
        xlabel('x [mm]')
        ylabel('Relative Intensity');
        ylim([0 2])
        grid; box on;
        set(gca,'FontSize',16)
        drawnow
    end

endfunction

function [FoM] = BoxFitterCavityLoad(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,FracSearch,freq_rf,sigma_0,MakeGifBool,PlotBoxBool,RF_Struct,Q1_s0)

    load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
    RF_Track;
##   X = 0;

    % Create multipole cavity
    r_rf_interest = 5*sigma_0;

    SF =  10.^(F_Constraint( X, -FracSearch, +FracSearch));

    E1_Mat = RF_Struct.E1_Mat*SF;
    E2_Mat = RF_Struct.E2_Mat*SF;
    E3_Mat = RF_Struct.E3_Mat*SF;
    B1_Mat = RF_Struct.B1_Mat*SF;
    B2_Mat = RF_Struct.B2_Mat*SF;
    B3_Mat = RF_Struct.B3_Mat*SF;

##    M = RF_FieldMap_CINT(E1_Mat, E2_Mat, E3_Mat, ...
##                     B1_Mat, B2_Mat,  B3_Mat, ...
    M = RF_FieldMap_CINT(0*E1_Mat, 0*E2_Mat, 0*E3_Mat, ...
                     B1_Mat, B2_Mat,  B3_Mat, ...
##    M = RF_FieldMap_CINT(imag(E1_Mat), imag(E2_Mat), imag(E3_Mat), ...
##                     imag(B1_Mat), imag(B2_Mat),  imag(B3_Mat), ...
                     RF_Struct.loc_x*1e-3,  RF_Struct.loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     RF_Struct.d1*1e-3, ... % dx, m
                     RF_Struct.d2*1e-3, ... % dy, m
                     RF_Struct.d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     freq_rf,%freq_rf*1e9,... freq in Hz
                     +1);% standing wave
    LM_RF = M.get_length();
    M.set_odeint_algorithm('rk2');
    M.set_nsteps(LM_RF*1000/0.1); % [40 mm] with steps every 0.1 mm
    M.set_tt_nsteps(LM_RF*1000); % tt every mm
    M.set_phi((270*(1-LM/(2*RF_Track.clight/freq_rf)))*pi/180); M.set_t0(0);
##    M.set_phi(3*pi/2); M.set_t0(0);


    %% Lattice creation
    if MakeGifBool == false
        L = Lattice();
        L.append(M, 0, 0, -RF_Struct.LPipe, reference = "entrance")
        % Create first drift
        D0L = Q1_s0-LM_RF+RF_Struct.LPipe;
        D0 = Drift(D0L);
        D0.set_tt_nsteps(round(D0L*100)); % tt every 10 mm
        L.append(D0);
        L.append(Q1);
        L.append(D2);
    else
        V = Volume();
        V.add(M,0,0, -RF_Struct.LPipe);
        D0L = Q1_s0-LM_RF+RF_Struct.LPipe;
        D0 = Drift(D0L);
        D0.set_tt_nsteps(round(D0L*100));
        V.add(D0,0,0,LM_RF-RF_Struct.LPipe)
        V.add(Q1,0,0,LM_RF-RF_Struct.LPipe+D0L)
        V.add(D2,0,0,LM_RF-RF_Struct.LPipe+D0L+Q1.get_length())
    end

    %% Plot field on axis (if desired)
    PlotFieldBool = 0;
    if PlotFieldBool == true

        x_0 = -5*sigma_0; Xa_L = 5001; r_0 = 5*sigma_0;
        Xa = linspace(x_0, r_0, Xa_L); % m
##        Xa = linspace(-abs(RF_Struct.loc_x), abs(RF_Struct.loc_x), Xa_L); % m

        for ii = 1:50 % Loop through multipoles
            if ii == 1
              B_ideal = zeros(1,length(Xa));
            endif
            % Remember to convert emittance to [m.rad]
            m = (2*ii+2);
            if ii == 1 % if octupole, no recursivity.
                kNL = 2/(2*emitt_geo_x_0*1e-6*beta_x_0)/beta_x_0/tan(phase_adv_def); % calculate magnetic multipole
            else
                kNL = -(2*ii-1)./(emitt_geo_x_0*1e-6*beta_x_0)*kNL;
            end
            B_ideal = B_ideal+Pref*1e6/charge*kNL*(Xa/1000).^(m-1)/factorial(m-1)/LM/c;
        end

##        for ZPos = 0:5:40%80:5:142
        ZPos = M.get_length()/2*1000;
        Bx_x = []; By_x = []; Bz_x = [];
        Ex_x = []; Ey_x = []; Ez_x = [];
        for X = Xa
            [E,B] = M.get_field(X, 0, ZPos, 0); % x,y,z,t (mm, mm/c)
            Bx_x = [ Bx_x ; B(1) ];
            By_x = [ By_x ; B(2) ];
            Bz_x = [ Bz_x ; B(3) ];
            Ex_x = [ Ex_x ; E(1) ];
            Ey_x = [ Ey_x ; E(2) ];
            Ez_x = [ Ez_x ; E(3) ];
        end
        Ya = linspace(x_0, r_0, Xa_L); % m
        Bx_y = []; By_y = []; Bz_y = [];
        Ex_y = []; Ey_y = []; Ez_y = [];
        for Y = Ya
            [E,B] = M.get_field(0, Y, ZPos, 0); % x,y,z,t (mm, mm/c)
            Bx_y = [ Bx_y ; B(1) ];
            By_y = [ By_y ; B(2) ];
            Bz_y = [ Bz_y ; B(3) ];
            Ex_y = [ Ex_y ; E(1) ];
            Ey_y = [ Ey_y ; E(2) ];
            Ez_y = [ Ez_y ; E(3) ];
        end

        figure(); clf; subplot(2,1,1); hold on;
        yLim = 0.1;
        plot(Xa, Bx_x, 'linewidth',LW,'Displayname','B_x along x')
        plot(Xa, By_x, '', 'linewidth',LW,'Displayname','B_y along x')
        plot(Xa, Bz_x, '', 'linewidth',LW,'Displayname','B_z along x')
        plot(Xa,B_ideal,'--', 'linewidth',LW,'Displayname','Ideal B_y')
        GaussBeam = exp(-Xa.^2/2/sigma_0^2);
        plot(Xa, yLim*GaussBeam,'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        title(['z position = ' num2str(ZPos)])
        xlabel('x [mm]')
        ylabel('B [T]');
        xlim([x_0 r_0]);
##        title(['Field in entire component (MaxEz = ' num2str(MaxEz/1e6,DispSpec) ' MV/m)'])
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
        ylim([-yLim yLim])

        subplot(2,1,2); hold on;
        SigBool = abs(Xa)<5*sigma_0;
        yLim = 0.1;
        plot(Xa(SigBool), Bx_x(SigBool), 'linewidth',LW,'Displayname','B_x along x')
        plot(Xa(SigBool), By_x(SigBool), '--', 'linewidth',LW,'Displayname','B_y along x')
        plot(Xa(SigBool), yLim*GaussBeam(SigBool),'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        plot(Xa(SigBool),B_ideal(SigBool) ,'--', 'linewidth',LW,'Displayname','Ideal B_y')
        xlabel('x [mm]')
        ylabel('B [T]');
        title('Field across beam size')
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
        ylim([-yLim yLim])
##  end
  end

    %% Lattice tracking
    if MakeGifBool == false
        B1 = L.track(B0);

    else
        V.wp_dt_mm =  20;
        V.tt_dt_mm = 1;
        B1 = V.track(B0);
        R_max = r_t_mm*1.5;
        gif_name = 'test';
        F_Make_RF_Track_Gif_Azi(B0,V,gif_name,R_max)
    end

    % Extract phase space parameters
    Bf_phase = B1.get_phase_space();
    X_ff = Bf_phase(:,1);

    h = hist(X_ff,bins_optim,population);
    h = h(2:end-1); bins_optim = bins_optim(2:end-1);

    A = h(((length(bins_optim))-1)/2+1);


    BoxFitAll = A*(abs(bins_optim)<=r_t_mm);
##        SSE = sum((h-BoxFitAll).^2);

    PipeFactor = 0.8;
    BoxBool = abs(bins_optim)<=r_t_mm*PipeFactor;
    BoxData = h(BoxBool);
    BoxFit = A*ones(1,length(BoxData));
    SSE = sqrt(sum((BoxData-BoxFit).^2))/population*1000;
    FoM = SSE;
    DispSpec = '%0.2f';
    disp(['SSE = ' num2str(SSE,DispSpec) '; X = ' num2str(X) '; SF = ' num2str(SF)] );


    if PlotBoxBool == true
        figure(101); clf; hold on;
        plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW)
        plot(bins_optim,BoxFitAll/A,'b','Linewidth',LW)
        xlabel('x [mm]')
        ylabel('Relative Intensity');
        ylim([0 2])
        grid; box on;
        set(gca,'FontSize',16)
        drawnow
    end

endfunction
function [FoM] = BoxFitterMagnet(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_0,FracSearch,sigma_0,emitt_geo_x_0,beta_x_0,phase_adv_def,MakeGifBool)

    load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
##    X = zeros(1,Multipoles); % UNCOMMENT TO RUN

    MultArrayTemp =  MultArray_0 .* 10.^(F_Constraint( X, -FracSearch, +FracSearch))
    MultArrayOptim = [];

    for ii = 1:length(MultArrayTemp)
        MultArrayOptim = [MultArrayOptim 0 MultArrayTemp(ii)];
    end

    RF_Track; c = RF_Track.clight;
    % Create multipole magnet
    M = Multipole(LM);
    M.set_strengths([0 0 MultArrayOptim]* Pref/charge);
    M.set_odeint_algorithm('rk2');
    M.set_nsteps(LM*1000/0.1); % [40 mm] with steps every 0.1 mm
    ##M.set_nsteps(1); % [40 mm] with steps every 0.1 mm
    M.set_tt_nsteps(LM*1000); % tt every mm


    %% Lattice creation
    if MakeGifBool == false
        L = Lattice();
        L.append(M);
        L.append(D1);
        L.append(Q1);
        L.append(D2);
    else
        V = Volume();
        V.add(M,0,0,0);
        V.add(D1,0,0,LM)
        V.add(Q1,0,0,LM+D1.get_length())
        V.add(D2,0,0,LM+D1.get_length()+Q1.get_length())
    end


    %% Plot field on axis (if desired)
    PlotFieldBool = 1;
    if PlotFieldBool == true

        x_0 = -5*sigma_0; Xa_L = 5001; r_0 = 5*sigma_0;
        Xa = linspace(x_0, r_0, Xa_L); % m

        B_test = zeros(1,length(Xa));
        S = M.get_strengths();
        n_arr = linspace(1,length(S),length(S))-1;

        B_test = [];
        for ii = 1:length(n_arr)
            B_test = [B_test; (S(ii)/(LM*RF_Track.clight/1e6)./factorial((n_arr(ii))).*(Xa/1000).^n_arr(ii))];
        end
        B_test = sum(B_test);


        for ii = 1:50 % Loop through multipoles
            if ii == 1
              B_ideal = zeros(1,length(Xa));
            endif
            % Remember to convert emittance to [m.rad]
            m = (2*ii+2);
            if ii == 1 % if octupole, no recursivity.
                kNL = 2/(2*emitt_geo_x_0*1e-6*beta_x_0)/beta_x_0/tan(phase_adv_def); % calculate magnetic multipole
            else
                kNL = -(2*ii-1)./(emitt_geo_x_0*1e-6*beta_x_0)*kNL;
            end
            B_ideal = B_ideal+Pref*1e6/charge*kNL*(Xa/1000).^(m-1)/factorial(m-1)/LM/c;
        end

        Bx_x = []; By_x = []; Bz_x = [];
        Ex_x = []; Ey_x = []; Ez_x = [];
        for X = Xa
            [E,B] = M.get_field(X, 0, 0, 0); % x,y,z,t (mm, mm/c)
            Bx_x = [ Bx_x ; B(1) ];
            By_x = [ By_x ; B(2) ];
            Bz_x = [ Bz_x ; B(3) ];
            Ex_x = [ Ex_x ; E(1) ];
            Ey_x = [ Ey_x ; E(2) ];
            Ez_x = [ Ez_x ; E(3) ];
        end
        Ya = linspace(x_0, r_0, Xa_L); % m
        Bx_y = []; By_y = []; Bz_y = [];
        Ex_y = []; Ey_y = []; Ez_y = [];
        for Y = Ya
            [E,B] = M.get_field(0, Y, 0, 0); % x,y,z,t (mm, mm/c)
            Bx_y = [ Bx_y ; B(1) ];
            By_y = [ By_y ; B(2) ];
            Bz_y = [ Bz_y ; B(3) ];
            Ex_y = [ Ex_y ; E(1) ];
            Ey_y = [ Ey_y ; E(2) ];
            Ez_y = [ Ez_y ; E(3) ];
        end

        figure(); clf; subplot(2,1,1); hold on;
        yLim = 1;
        plot(Xa, Bx_x, 'linewidth',LW,'Displayname','B_x along x')
        plot(Xa, By_x, '', 'linewidth',LW,'Displayname','B_y along x')
        plot(Xa, Bz_x, '', 'linewidth',LW,'Displayname','B_z along x')
        plot(Xa, B_test, '--', 'linewidth',LW,'Displayname','Predicted B_y')
##            plot(Xa,B_ideal,'--', 'linewidth',LW,'Displayname','Ideal B_y')
        GaussBeam = exp(-Xa.^2/2/sigma_0^2);
        plot(Xa, yLim*GaussBeam,'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        xlabel('x [mm]')
        ylabel('B [T]');
        xlim([x_0 r_0]);
##            title(['Field in entire component (MaxEz = ' num2str(MaxEz/1e6,DispSpec) ' MV/m)'])
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
        ylim([-yLim yLim])

        subplot(2,1,2); hold on;
        SigBool = abs(Xa)<5*sigma_0;
        yLim = 0.1;
        plot(Xa(SigBool), Bx_x(SigBool), 'linewidth',LW,'Displayname','B_x along x')
        plot(Xa(SigBool), By_x(SigBool), '--', 'linewidth',LW,'Displayname','B_y along x')
        plot(Xa(SigBool), yLim*GaussBeam(SigBool),'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        plot(Xa(SigBool),B_ideal(SigBool) ,'--', 'linewidth',LW,'Displayname','Ideal B_y')
        xlabel('x [mm]')
        ylabel('B [T]');
        title('Field across beam size')
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
        ylim([-yLim yLim])

    end


    %% Lattice tracking
    if MakeGifBool == false
        B1 = L.track(B0);

    else
        V.wp_dt_mm =  20;
        V.tt_dt_mm = 1;
        B1 = V.track(B0);
        R_max = r_t_mm*1.5;
        gif_name = 'test';
        F_Make_RF_Track_Gif_Azi(B0,V,gif_name,R_max)
    end

    % Extract phase space parameters
    Bf_phase = B1.get_phase_space();
    X_ff = Bf_phase(:,1);

    h = hist(X_ff,bins_optim,population);
    h = h(2:end-1); bins_optim = bins_optim(2:end-1);

    A = h(((length(bins_optim))-1)/2+1);

    BoxFitAll = A*(abs(bins_optim)<=r_t_mm);
##        SSE = sum((h-BoxFitAll).^2);

    BoxBool = abs(bins_optim)<=r_t_mm;
    BoxData = h(BoxBool);
    BoxFit = A*ones(1,length(BoxData));
    SSE = sqrt(sum((BoxData-BoxFit).^2))/population*1000;
    FoM = SSE;
    DispSpec = '%0.2f';
    disp(['SSE = ' num2str(SSE,DispSpec) '; MultArray = ' num2str(MultArrayOptim)]);

    PlotBoxBool = 0;
    if PlotBoxBool == true
        figure(101); clf; hold on;
        plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW)
        plot(bins_optim,BoxFitAll/A,'b','Linewidth',LW)
        xlabel('x [mm]')
        ylabel('Relative Intensity');
        ylim([0 2])
        grid; box on;
        set(gca,'FontSize',16)
        drawnow
    end

endfunction



function [FoM] = BoxFitterCavityFreq(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_0,FracSearch,freq_rf_0,sigma_0,MakeGifBool,PlotBoxBool)

    load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
    RF_Track;
##    X = [zeros(1,Multipoles) 0]; % UNCOMMENT TO RUN
    freq_rf = freq_rf_0 .* 10.^(F_Constraint(X(end), -FracSearch, +FracSearch))

    MultArrayTemp =  MultArray_RF_0 .* 10.^(F_Constraint(X(1:end-1), -FracSearch, +FracSearch))
    MultArrayOptim = [];

    for ii = 1:length(MultArrayTemp)
        MultArrayOptim = [MultArrayOptim 0 MultArrayTemp(ii)];
    end
    MultArrayOptim = [0 0 0 MultArrayOptim]; % Must include the monopole!

    % Create multipole cavity
    r_rf_interest = 5*sigma_0;
    [M, MaxEz] = F_MultipoleCav(MultArrayOptim,freq_rf,LM,r_rf_interest,PlotBool=false);
    M.set_odeint_algorithm('rk2');
    M.set_nsteps(LM*1000/0.1); % [40 mm] with steps every 0.1 mm
    M.set_tt_nsteps(LM*1000); % tt every mm

    MaxEz

    %% Lattice creation
    if MakeGifBool == false
        L = Lattice();
        L.append(M);
        L.append(D1);
        L.append(Q1);
        L.append(D2);
    else
        V = Volume();
        V.add(M,0,0,0);
        V.add(D1,0,0,LM)
        V.add(Q1,0,0,LM+D1.get_length())
        V.add(D2,0,0,LM+D1.get_length()+Q1.get_length())
    end

    %% Plot field on axis (if desired)
    PlotFieldBool = 0;
    if PlotFieldBool == true

        x_0 = -5*sigma_0; Xa_L = 5001; r_0 = 5*sigma_0;
        Xa = linspace(x_0, r_0, Xa_L); % m

        E_test = zeros(1,length(Xa));
        B_test = zeros(1,length(Xa)); g_M = MultArrayOptim;  kappa_p = 2*pi*freq_rf/c; omega = 2*pi*freq_rf;
        M_index   = linspace(0,length(g_M)-1,length(g_M));
        for ii = 1:length(g_M)
            if g_M(ii) ~= 0 % Remove unnecessary calculation
                B_test  = B_test +real(1/omega.*kappa_p*g_M(ii).*(0.5*(besselj(M_index(ii)-1,kappa_p*Xa/1000)-besselj(M_index(ii)+1,kappa_p*Xa/1000))));
                E_test  = E_test +real(g_M(ii).*(besselj(M_index(ii),kappa_p*Xa/1000)));
            end
        end

        for ii = 1:50 % Loop through multipoles
            if ii == 1
              B_ideal = zeros(1,length(Xa));
            endif
            % Remember to convert emittance to [m.rad]
            m = (2*ii+2);
            if ii == 1 % if octupole, no recursivity.
                kNL = 2/(2*emitt_geo_x_0*1e-6*beta_x_0)/beta_x_0/tan(phase_adv_def); % calculate magnetic multipole
            else
                kNL = -(2*ii-1)./(emitt_geo_x_0*1e-6*beta_x_0)*kNL;
            end
            B_ideal = B_ideal+Pref*1e6/charge*kNL*(Xa/1000).^(m-1)/factorial(m-1)/LM/c;
        end

        x_0 = -5*sigma_0; Xa_L = 5001; r_0 = 5*sigma_0;
        Xa = linspace(x_0, r_0, Xa_L); % m
        Bx_x = []; By_x = []; Bz_x = [];
        Ex_x = []; Ey_x = []; Ez_x = [];
        for X = Xa
            [E,B] = M.get_field(X, 0, 0, 0); % x,y,z,t (mm, mm/c)
            Bx_x = [ Bx_x ; B(1) ];
            By_x = [ By_x ; B(2) ];
            Bz_x = [ Bz_x ; B(3) ];
            Ex_x = [ Ex_x ; E(1) ];
            Ey_x = [ Ey_x ; E(2) ];
            Ez_x = [ Ez_x ; E(3) ];
        end
        Ya = linspace(x_0, r_0, Xa_L); % m
        Bx_y = []; By_y = []; Bz_y = [];
        Ex_y = []; Ey_y = []; Ez_y = [];
        for Y = Ya
            [E,B] = M.get_field(0, Y, 0, 0); % x,y,z,t (mm, mm/c)
            Bx_y = [ Bx_y ; B(1) ];
            By_y = [ By_y ; B(2) ];
            Bz_y = [ Bz_y ; B(3) ];
            Ex_y = [ Ex_y ; E(1) ];
            Ey_y = [ Ey_y ; E(2) ];
            Ez_y = [ Ez_y ; E(3) ];
        end

        figure(); clf; subplot(2,1,1); hold on;
        yLim = 1;
        plot(Xa, Bx_x, 'linewidth',LW,'Displayname','B_x along x')
        plot(Xa, By_x, '', 'linewidth',LW,'Displayname','B_y along x')
        plot(Xa, Bz_x, '', 'linewidth',LW,'Displayname','B_z along x')
        plot(Xa, B_test, '--', 'linewidth',LW,'Displayname','Predicted B_y')
##            plot(Xa,B_ideal,'--', 'linewidth',LW,'Displayname','Ideal B_y')
        plot(Xa, E_test/max(E_test)*max(B_test), '--', 'linewidth',LW,'Displayname','Predicted E_z')
        GaussBeam = exp(-Xa.^2/2/sigma_0^2);
        plot(Xa, yLim*GaussBeam,'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        xlabel('x [mm]')
        ylabel('B [T]');
        xlim([x_0 r_0]);
        title(['Field in entire component (MaxEz = ' num2str(MaxEz/1e6,DispSpec) ' MV/m)'])
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
        ylim([-yLim yLim])

        subplot(2,1,2); hold on;
        SigBool = abs(Xa)<5*sigma_0;
        yLim = 0.1;
        plot(Xa(SigBool), Bx_x(SigBool), 'linewidth',LW,'Displayname','B_x along x')
        plot(Xa(SigBool), By_x(SigBool), '--', 'linewidth',LW,'Displayname','B_y along x')
        plot(Xa(SigBool), yLim*GaussBeam(SigBool),'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        plot(Xa(SigBool),B_ideal(SigBool) ,'--', 'linewidth',LW,'Displayname','Ideal B_y')
        xlabel('x [mm]')
        ylabel('B [T]');
        title('Field across beam size')
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
        ylim([-yLim yLim])
  end

    %% Lattice tracking
    if MakeGifBool == false
        B1 = L.track(B0);

    else
        V.wp_dt_mm =  20;
        V.tt_dt_mm = 1;
        B1 = V.track(B0);
        R_max = r_t_mm*1.5;
        gif_name = 'test';
        F_Make_RF_Track_Gif_Azi(B0,V,gif_name,R_max)
    end

    % Extract phase space parameters
    Bf_phase = B1.get_phase_space();
    X_ff = Bf_phase(:,1);

    h = hist(X_ff,bins_optim,population);
    h = h(2:end-1); bins_optim = bins_optim(2:end-1);

    A = h(((length(bins_optim))-1)/2+1);

    BoxFitAll = A*(abs(bins_optim)<=r_t_mm);
##        SSE = sum((h-BoxFitAll).^2);

    BoxBool = abs(bins_optim)<=0.9*r_t_mm; % NOTE NEW PARAMETER!
    BoxData = h(BoxBool);
    BoxX = bins_optim(BoxBool);
    BoxFit = A*ones(1,length(BoxData));
    SSE = sqrt(sum((BoxData-BoxFit).^2))/population*1000;
    FoM = SSE;
    DispSpec = '%0.2f';
    disp(['SSE = ' num2str(SSE,DispSpec) '; MultArray = ' num2str(MultArrayOptim)]);


    if PlotBoxBool == true
        figure(101); clf; hold on;
        plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW)
        plot(bins_optim,BoxFitAll/A,'b','Linewidth',LW)
        xlabel('x [mm]')
        ylabel('Relative Intensity');
        ylim([0 2])
        grid; box on;
        set(gca,'FontSize',16)
        drawnow

        figure(102); clf; hold on;
        plot(BoxX,BoxFit,'r','Linewidth',LW)
        plot(BoxX,BoxData,'b','Linewidth',LW)
        xlabel('x [mm]')
        ylabel('Relative Intensity');
        grid; box on;
        set(gca,'FontSize',16)
        drawnow
    end

endfunction



function [FoM] = BoxFitterCavityTE(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_TE_0,FracSearch,freq_rf,sigma_0,MakeGifBool,PlotBoxBool)

    load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
    RF_Track;
##    X = zeros(1,Multipoles); % UNCOMMENT TO RUN

    MultArrayTemp =  MultArray_RF_TE_0 .* 10.^(F_Constraint( X, -FracSearch, +FracSearch))
    MultArrayOptim = [];

    for ii = 1:length(MultArrayTemp)
        MultArrayOptim = [MultArrayOptim 0 MultArrayTemp(ii)];
    end
    MultArrayOptim = [0 0 0 MultArrayOptim]; % Must include the monopole!

    % Create multipole cavity
    r_rf_interest = 5*sigma_0;
    [M, MaxEx] = F_MultipoleCav_TE(MultArrayOptim,freq_rf,LM,r_rf_interest,PlotBool=false);
    M.set_odeint_algorithm('rk2');
    M.set_nsteps(LM*1000/0.1); % [40 mm] with steps every 0.1 mm
    M.set_tt_nsteps(LM*1000); % tt every mm

    MaxEx

    %% Lattice creation
    if MakeGifBool == false
        L = Lattice();
        L.append(M);
        L.append(D1);
        L.append(Q1);
        L.append(D2);
    else
        V = Volume();
        V.add(M,0,0,0);
        V.add(D1,0,0,LM)
        V.add(Q1,0,0,LM+D1.get_length())
        V.add(D2,0,0,LM+D1.get_length()+Q1.get_length())
    end

    %% Plot field on axis (if desired)
    PlotFieldBool = 0;
    if PlotFieldBool == true

        x_0 = -5*sigma_0; Xa_L = 5001; r_0 = 5*sigma_0;
        Xa = linspace(x_0, r_0, Xa_L); % m

        E_test = zeros(1,length(Xa));


        g_M = MultArrayOptim;   p=1; k_l = 2*pi*freq_rf/c;   k_p = 2*p*pi/(LM); kappa_p = sqrt(k_l^2-k_p^2); omega = 2*pi*freq_rf;
        M_index   = linspace(0,length(g_M)-1,length(g_M));
        for ii = 1:length(g_M)
            if g_M(ii) ~= 0 % Remove unnecessary calculation
                E_test  = E_test - real(k_p./(kappa_p^2 .*Xa/1000).*M_index(ii).*g_M(ii).*besselj(M_index(ii),kappa_p*Xa/1000));
            end
        end

        for ii = 1:50 % Loop through multipoles
            if ii == 1
              B_ideal = zeros(1,length(Xa));
            endif
            % Remember to convert emittance to [m.rad]
            m = (2*ii+2);
            if ii == 1 % if octupole, no recursivity.
                kNL = 2/(2*emitt_geo_x_0*1e-6*beta_x_0)/beta_x_0/tan(phase_adv_def); % calculate magnetic multipole
            else
                kNL = -(2*ii-1)./(emitt_geo_x_0*1e-6*beta_x_0)*kNL;
            end
            B_ideal = B_ideal+Pref*1e6/charge*kNL*(Xa/1000).^(m-1)/factorial(m-1)/LM/c;
        end

        x_0 = -5*sigma_0; Xa_L = 5001; r_0 = 5*sigma_0;
        Xa = linspace(x_0, r_0, Xa_L); % m
        Bx_x = []; By_x = []; Bz_x = [];
        Ex_x = []; Ey_x = []; Ez_x = [];
        for X = Xa
            [E,B] = M.get_field(X, 0, 0, 0); % x,y,z,t (mm, mm/c)
            Bx_x = [ Bx_x ; B(1) ];
            By_x = [ By_x ; B(2) ];
            Bz_x = [ Bz_x ; B(3) ];
            Ex_x = [ Ex_x ; E(1) ];
            Ey_x = [ Ey_x ; E(2) ];
            Ez_x = [ Ez_x ; E(3) ];
        end
        Ya = linspace(x_0, r_0, Xa_L); % m
        Bx_y = []; By_y = []; Bz_y = [];
        Ex_y = []; Ey_y = []; Ez_y = [];
        for Y = Ya
            [E,B] = M.get_field(0, Y, 0, 0); % x,y,z,t (mm, mm/c)
            Bx_y = [ Bx_y ; B(1) ];
            By_y = [ By_y ; B(2) ];
            Bz_y = [ Bz_y ; B(3) ];
            Ex_y = [ Ex_y ; E(1) ];
            Ey_y = [ Ey_y ; E(2) ];
            Ez_y = [ Ez_y ; E(3) ];
        end

        figure(); clf; subplot(2,1,1); hold on;
        yLim = 1;
        MaxVal = max([max(Ex_x), max(Ey_x), max(Ez_x)])/1e6;
        plot(Xa, Ex_x/1e6, 'linewidth',LW,'Displayname','E_x along x')
        plot(Xa, Ey_x/1e6, '', 'linewidth',LW,'Displayname','E_y along x')
        plot(Xa, Ez_x/1e6, '', 'linewidth',LW,'Displayname','E_z along x')
##            plot(Xa,B_ideal,'--', 'linewidth',LW,'Displayname','Ideal B_y')
        plot(Xa, E_test/1e6, '--', 'linewidth',LW,'Displayname','Predicted E_x')
        plot(Xa,-c*B_ideal/1e6,'--', 'linewidth',LW,'Displayname','Ideal E_x')
        GaussBeam = exp(-Xa.^2/2/sigma_0^2)*MaxVal;
        plot(Xa, yLim*GaussBeam,'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        xlabel('x [mm]')
        ylabel('E [MV/m]');
        xlim([x_0 r_0]);
        title(['Field in entire component (MaxEz = ' num2str(MaxEx/1e6,DispSpec) ' MV/m)'])
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
        %ylim([-yLim yLim])

        subplot(2,1,2); hold on;
        SigBool = abs(Xa)<5*sigma_0;
        yLim = 0.1;
        plot(Xa(SigBool), Ex_x(SigBool)/1e6, 'linewidth',LW,'Displayname','E_x along x')
        plot(Xa(SigBool), Ey_x(SigBool)/1e6, '--', 'linewidth',LW,'Displayname','E_y along x')
        plot(Xa(SigBool), GaussBeam(SigBool),'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        plot(Xa(SigBool),-c*B_ideal(SigBool)/1e6,'--', 'linewidth',LW,'Displayname','Ideal E_x')
        xlabel('x [mm]')
        ylabel('B [T]');
        title('Field across beam size')
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
  end

    %% Lattice tracking
    if MakeGifBool == false
        B1 = L.track(B0);
    else
        V.wp_dt_mm =  20;
        V.tt_dt_mm = 1;
        B1 = V.track(B0);
        R_max = r_t_mm*1.5;
        gif_name = 'test';
        F_Make_RF_Track_Gif_Azi(B0,V,gif_name,R_max)
    end

    % Extract phase space parameters
    Bf_phase = B1.get_phase_space();
    X_ff = Bf_phase(:,1);

    h = hist(X_ff,bins_optim,population);
    h = h(2:end-1); bins_optim = bins_optim(2:end-1);

    A = h(((length(bins_optim))-1)/2+1);

    BoxFitAll = A*(abs(bins_optim)<=r_t_mm);
##        SSE = sum((h-BoxFitAll).^2);

    BoxBool = abs(bins_optim)<=r_t_mm;
    BoxData = h(BoxBool);
    BoxFit = A*ones(1,length(BoxData));
    SSE = sqrt(sum((BoxData-BoxFit).^2))/population*1000;
    FoM = SSE;
    DispSpec = '%0.2f';
    disp(['SSE = ' num2str(SSE,DispSpec) '; MultArray = ' num2str(MultArrayOptim)]);


    if PlotBoxBool == true
        figure(101); clf; hold on;
        plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW)
        plot(bins_optim,BoxFitAll/A,'b','Linewidth',LW)
        xlabel('x [mm]')
        ylabel('Relative Intensity');
        ylim([0 2])
        grid; box on;
        set(gca,'FontSize',16)
        drawnow
    end

endfunction

function [FoM] = BoxFitterCavityTEFreq(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_TE_0,FracSearch,freq_rf_0,sigma_0,MakeGifBool,PlotBoxBool)

    load('/Users/wroe/cernbox2/Code/RF_Track/Functions/PlottingParameters.dat')
    RF_Track;
##    X = zeros(1,Multipoles); % UNCOMMENT TO RUN

    freq_rf = freq_rf_0 .* 10.^(F_Constraint(X(end), -FracSearch, +FracSearch))
    MultArrayTemp =  MultArray_RF_TE_0 .* 10.^(F_Constraint( X(1:end-1), -FracSearch, +FracSearch))
    MultArrayOptim = [];

    for ii = 1:length(MultArrayTemp)
        MultArrayOptim = [MultArrayOptim 0 MultArrayTemp(ii)];
    end
    MultArrayOptim = [0 0 0 MultArrayOptim]; % Must include the monopole!

    % Create multipole cavity
    r_rf_interest = 5*sigma_0;
    [M, MaxEx] = F_MultipoleCav_TE(MultArrayOptim,freq_rf,LM,r_rf_interest,PlotBool=false);
    M.set_odeint_algorithm('rk2');
    M.set_nsteps(LM*1000/0.1); % [40 mm] with steps every 0.1 mm
    M.set_tt_nsteps(LM*1000); % tt every mm

    MaxEx

    %% Lattice creation
    if MakeGifBool == false
        L = Lattice();
        L.append(M);
        L.append(D1);
        L.append(Q1);
        L.append(D2);
    else
        V = Volume();
        V.add(M,0,0,0);
        V.add(D1,0,0,LM)
        V.add(Q1,0,0,LM+D1.get_length())
        V.add(D2,0,0,LM+D1.get_length()+Q1.get_length())
    end

    %% Plot field on axis (if desired)
    PlotFieldBool = 0;
    if PlotFieldBool == true

        x_0 = -5*sigma_0; Xa_L = 5001; r_0 = 5*sigma_0;
        Xa = linspace(x_0, r_0, Xa_L); % m

        E_test = zeros(1,length(Xa));


        g_M = MultArrayOptim;   p=1; k_l = 2*pi*freq_rf/c;   k_p = 2*p*pi/(LM); kappa_p = sqrt(k_l^2-k_p^2); omega = 2*pi*freq_rf;
        M_index   = linspace(0,length(g_M)-1,length(g_M));
        for ii = 1:length(g_M)
            if g_M(ii) ~= 0 % Remove unnecessary calculation
                E_test  = E_test - real(k_p./(kappa_p^2 .*Xa/1000).*M_index(ii).*g_M(ii).*besselj(M_index(ii),kappa_p*Xa/1000));
            end
        end

        for ii = 1:50 % Loop through multipoles
            if ii == 1
              B_ideal = zeros(1,length(Xa));
            endif
            % Remember to convert emittance to [m.rad]
            m = (2*ii+2);
            if ii == 1 % if octupole, no recursivity.
                kNL = 2/(2*emitt_geo_x_0*1e-6*beta_x_0)/beta_x_0/tan(phase_adv_def); % calculate magnetic multipole
            else
                kNL = -(2*ii-1)./(emitt_geo_x_0*1e-6*beta_x_0)*kNL;
            end
            B_ideal = B_ideal+Pref*1e6/charge*kNL*(Xa/1000).^(m-1)/factorial(m-1)/LM/c;
        end

        x_0 = -5*sigma_0; Xa_L = 5001; r_0 = 5*sigma_0;
        Xa = linspace(x_0, r_0, Xa_L); % m
        Bx_x = []; By_x = []; Bz_x = [];
        Ex_x = []; Ey_x = []; Ez_x = [];
        for X = Xa
            [E,B] = M.get_field(X, 0, 0, 0); % x,y,z,t (mm, mm/c)
            Bx_x = [ Bx_x ; B(1) ];
            By_x = [ By_x ; B(2) ];
            Bz_x = [ Bz_x ; B(3) ];
            Ex_x = [ Ex_x ; E(1) ];
            Ey_x = [ Ey_x ; E(2) ];
            Ez_x = [ Ez_x ; E(3) ];
        end
        Ya = linspace(x_0, r_0, Xa_L); % m
        Bx_y = []; By_y = []; Bz_y = [];
        Ex_y = []; Ey_y = []; Ez_y = [];
        for Y = Ya
            [E,B] = M.get_field(0, Y, 0, 0); % x,y,z,t (mm, mm/c)
            Bx_y = [ Bx_y ; B(1) ];
            By_y = [ By_y ; B(2) ];
            Bz_y = [ Bz_y ; B(3) ];
            Ex_y = [ Ex_y ; E(1) ];
            Ey_y = [ Ey_y ; E(2) ];
            Ez_y = [ Ez_y ; E(3) ];
        end

        figure(); clf; subplot(2,1,1); hold on;
        yLim = 1;
        MaxVal = max([max(Ex_x), max(Ey_x), max(Ez_x)])/1e6;
        plot(Xa, Ex_x/1e6, 'linewidth',LW,'Displayname','E_x along x')
        plot(Xa, Ey_x/1e6, '', 'linewidth',LW,'Displayname','E_y along x')
        plot(Xa, Ez_x/1e6, '', 'linewidth',LW,'Displayname','E_z along x')
##            plot(Xa,B_ideal,'--', 'linewidth',LW,'Displayname','Ideal B_y')
        plot(Xa, E_test/1e6, '--', 'linewidth',LW,'Displayname','Predicted E_x')
        plot(Xa,-c*B_ideal/1e6,'--', 'linewidth',LW,'Displayname','Ideal E_x')
        GaussBeam = exp(-Xa.^2/2/sigma_0^2)*MaxVal;
        plot(Xa, yLim*GaussBeam,'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        xlabel('x [mm]')
        ylabel('E [MV/m]');
        xlim([x_0 r_0]);
        title(['Field in entire component (MaxEz = ' num2str(MaxEx/1e6,DispSpec) ' MV/m)'])
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
        %ylim([-yLim yLim])

        subplot(2,1,2); hold on;
        SigBool = abs(Xa)<5*sigma_0;
        yLim = 0.1;
        plot(Xa(SigBool), Ex_x(SigBool)/1e6, 'linewidth',LW,'Displayname','E_x along x')
        plot(Xa(SigBool), Ey_x(SigBool)/1e6, '--', 'linewidth',LW,'Displayname','E_y along x')
        plot(Xa(SigBool), GaussBeam(SigBool),'g:--', 'linewidth',LW,'Displayname','Particle Distribution')
        plot(Xa(SigBool),-c*B_ideal(SigBool)/1e6,'--', 'linewidth',LW,'Displayname','Ideal E_x')
        xlabel('x [mm]')
        ylabel('B [T]');
        title('Field across beam size')
        legend('Location','EastOutside')
        set(gca,'FontSize',FS)
  end

    %% Lattice tracking
    if MakeGifBool == false
        B1 = L.track(B0);
    else
        V.wp_dt_mm =  20;
        V.tt_dt_mm = 1;
        B1 = V.track(B0);
        R_max = r_t_mm*1.5;
        gif_name = 'test';
        F_Make_RF_Track_Gif_Azi(B0,V,gif_name,R_max)
    end

    % Extract phase space parameters
    Bf_phase = B1.get_phase_space();
    X_ff = Bf_phase(:,1);

    h = hist(X_ff,bins_optim,population);
    h = h(2:end-1); bins_optim = bins_optim(2:end-1);

    A = h(((length(bins_optim))-1)/2+1);

    BoxFitAll = A*(abs(bins_optim)<=r_t_mm);
##        SSE = sum((h-BoxFitAll).^2);

    BoxBool = abs(bins_optim)<=r_t_mm;
    BoxData = h(BoxBool);
    BoxFit = A*ones(1,length(BoxData));
    SSE = sqrt(sum((BoxData-BoxFit).^2))/population*1000;
    FoM = SSE;
    DispSpec = '%0.2f';
    disp(['SSE = ' num2str(SSE,DispSpec) '; MultArray = ' num2str(MultArrayOptim)]);


    if PlotBoxBool == true
        figure(101); clf; hold on;
        plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW)
        plot(bins_optim,BoxFitAll/A,'b','Linewidth',LW)
        xlabel('x [mm]')
        ylabel('Relative Intensity');
        ylim([0 2])
        grid; box on;
        set(gca,'FontSize',16)
        drawnow
    end

endfunction



MakeGifBool = 0;PlotBoxBool = 0; return
if RFCavityBool == true  ### UNIFORMISE WITH  RF CAVITY ###
        O = optimset('TolX', 0.1, 'TolFun', 0.1, 'MaxFunEvals', 1e3, 'MaxIter', 1e3); % Define optimset
##        MultArray_RF_0(2) = - MultArray_RF_0(2) ;
        anon_func_box = @(X)BoxFitterCavity(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_0,FracSearch,freq_rf,sigma_0,MakeGifBool,PlotBoxBool)
        X_0 = zeros(1,Multipoles);
        XOptim = fminsearch(anon_func_box, X_0, O);
        MultArray =  MultArray_RF_0 .* 10.^(F_Constraint( XOptim, -FracSearch, +FracSearch))
  elseif RFCavityBool == 2 ### UNIFORMISE WITH RF CAVITY AND VARY k ###
      FracSearch = 2;
      O = optimset('TolX', 0.1, 'TolFun', 0.1, 'MaxFunEvals', 1e3, 'MaxIter', 1e3); % Define optimset
##      freq_rf = 2.71e9; MultArray_RF_0 = 6.08e7;
##      freq_rf = 3e9; MultArray_RF_0 = 4.99e7;
      freq_rf_0 = freq_rf;
      anon_func_box = @(X)BoxFitterCavityFreq(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_0,FracSearch,freq_rf_0,sigma_0,MakeGifBool,PlotBoxBool)
      X_0 = [zeros(1,Multipoles) 0];
      XOptim = fminsearch(anon_func_box, X_0, O);
      MultArray =  MultArray_RF_0 .* 10.^(F_Constraint( XOptim(1:end-1), -FracSearch, +FracSearch))
      freq_rf =  freq_rf_0 .* 10.^(F_Constraint( XOptim(end), -FracSearch, +FracSearch))
  elseif RFCavityBool == 3 ### UNIFORMISE WITH TE MODE ###
        return
        O = optimset('TolX', 0.1, 'TolFun', 0.1, 'MaxFunEvals', 1e3, 'MaxIter', 1e3); % Define optimset
        anon_func_box = @(X)BoxFitterCavityTE(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_TE_0,FracSearch,freq_rf,sigma_0,MakeGifBool,PlotBoxBool)
        X_0 = zeros(1,Multipoles);
        XOptim = fminsearch(anon_func_box, X_0, O);
        MultArray =  MultArray_RF_0 .* 10.^(F_Constraint( XOptim, -FracSearch, +FracSearch))
  elseif RFCavityBool == 4 ### UNIFORMISE WITH RF CAVITY AND VARY k ###
      FracSearch = 2;
      return
      O = optimset('TolX', 0.1, 'TolFun', 0.1, 'MaxFunEvals', 1e3, 'MaxIter', 1e3); % Define optimset
      freq_rf_0 = freq_rf;
      anon_func_box = @(X)BoxFitterCavityTEFreq(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_TE_0,FracSearch,freq_rf_0,sigma_0,MakeGifBool,PlotBoxBool)
      X_0 = [zeros(1,Multipoles) 0];
      XOptim = fminsearch(anon_func_box, X_0, O);
      MultArray =  MultArray_RF_TE_0 .* 10.^(F_Constraint( XOptim(1:end-1), -FracSearch, +FracSearch))
      freq_rf =  freq_rf_0 .* 10.^(F_Constraint( XOptim(end), -FracSearch, +FracSearch))
  elseif RFCavityBool == 5; # UNIFORMISE WITH TM410
      FracSearch = 0.5;
      O = optimset('TolX', 0.1, 'TolFun', 0.1, 'MaxFunEvals', 1e3, 'MaxIter', 1e3); % Define optimset
      freq_rf_0 = freq_rf;
      anon_func_box = @(X)BoxFitterCavityLoad(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,FracSearch,freq_rf,sigma_0,MakeGifBool,PlotBoxBool,RF_Struct,Q1_s0)
      X_0 = [0];
      XOptim = fminsearch(anon_func_box, X_0, O);
  else #### UNIFORMISE WITH MAGNET ###
      O = optimset('TolX', 0.1, 'TolFun', 0.1, 'MaxFunEvals', 1e3, 'MaxIter', 1e3); % Define optimset
      anon_func_box = @(X)BoxFitterMagnet(X,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_0,FracSearch,sigma_0,emitt_geo_x_0,beta_x_0,phase_adv_def,0)
      X_0 = zeros(1,Multipoles);
      XOptim = fminsearch(anon_func_box, X_0, O);
      MultArray =  MultArray_0 .* 10.^(F_Constraint( XOptim, -FracSearch, +FracSearch))
end

return

##MultArray_RF_0 = [5.27e7, -8.6e7, 1.47e9];
##XOptim = zeros(1,Multipoles);
MakeGifBool = 0; PlotBoxBool = 1;
BoxFitterCavity(XOptim,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_0,FracSearch,freq_rf,sigma_0,MakeGifBool,PlotBoxBool)

##XOptim = -1;
MakeGifBool = 0; PlotBoxBool = 1;
BoxFitterCavityLoad(XOptim,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,FracSearch,freq_rf,sigma_0,MakeGifBool,PlotBoxBool,RF_Struct,Q1_s0)

##XOptim = [zeros(1,Multipoles) 0];
MakeGifBool = 0; PlotBoxBool = 1;
BoxFitterCavityFreq(XOptim,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_0,FracSearch,freq_rf_0,sigma_0,MakeGifBool,PlotBoxBool)

##MultArray_RF_0 = [5.27e7, -8.6e7, 1.47e9];
##XOptim = zeros(1,Multipoles);
MakeGifBool = 0; PlotBoxBool = 1;
BoxFitterCavityTE(XOptim,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_TE_0,FracSearch,freq_rf,sigma_0,MakeGifBool,PlotBoxBool)

##XOptim = zeros(1,Multipoles);
MakeGifBool = 1; PlotBoxBool = 1;
BoxFitterCavityTEFreq(XOptim,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_RF_TE_0,FracSearch,freq_rf_0,sigma_0,MakeGifBool,PlotBoxBool)

##XOptim = zeros(1,Multipoles);
MakeGifBool = 0;
BoxFitterMagnet(XOptim,LM,Pref,charge,D1,Q1,D2,B0,bins_optim,r_t_mm,population,MultArray_0,FracSearch,sigma_0,emitt_geo_x_0,beta_x_0,phase_adv_def,MakeGifBool)

return
### USEFUL CODE BUT NOT NEEDED ###

% display the difference between ideal and rf
for ii = 1:5
    n=ii+3;
    IdealTerm = 1/(2*n-5)/factorial(n-3)/((emitt_geo_x_0*1e-6*beta_x_0)^(n-3));
    rfTerm = (n-2)/factorial(n-4)/factorial(n)*(k_rf/2)^(2*n-5);
    if ii == 1
        Comp = (rfTerm(1)/IdealTerm(1));
    endif
    disp([n, rfTerm/IdealTerm, rfTerm/IdealTerm./Comp])
end

%% Plot the ideal magnetic field
PlotIdealField = 1;
if PlotIdealField == true

    figure(); clf; hold on;
    plot(Xa,B_ideal,'-', 'linewidth',LW,'Displayname', 'Ideal')

    MultArrayOptim = [0 2200]
    S = [0 0 MultArrayOptim]* Pref/charge; n_arr = linspace(1,length(S),length(S))-1;
    B_mag = [];
    for ii = 1:length(n_arr)
        B_mag = [B_mag; (S(ii)/(LM*RF_Track.clight/1e6)./factorial((n_arr(ii))).*(Xa/1000).^n_arr(ii))];
    end
    B_mag = sum(B_mag);
    plot(Xa, B_mag, '-', 'linewidth',LW,'Displayname', 'Magnet')

    B_rf = zeros(1,length(Xa)); g_M = [0 0 0 0 33.9e9];  kappa_p = 2*pi*freq_rf/c; omega = 2*pi*freq_rf; M_index   = linspace(0,length(g_M)-1,length(g_M));
    for ii = 1:length(g_M)
        if g_M(ii) ~= 0 % Remove unnecessary calculation
            B_rf  = B_rf +real(1/omega.*kappa_p*g_M(ii).*(0.5*(besselj(M_index(ii)-1,kappa_p*Xa/1000)-besselj(M_index(ii)+1,kappa_p*Xa/1000))));
        end
    end
    plot(Xa, B_rf, '-', 'linewidth',LW,'Displayname', 'RF Cavity')

    PlotFact = 5;
    [~,MinPos] = min(abs(Xa-PlotFact*sigma_0));
    GaussBeam = exp(-Xa.^2/2/sigma_0^2);
    MaxB = max(B_ideal(round(end/2):MinPos));
    plot(Xa,GaussBeam*MaxB,'g--', 'linewidth',LW,'HandleVisibility','off')
    xlabel('x [mm]'); ylabel('B [T]');
    legend('Location','SouthEast')
    xlim([-PlotFact*sigma_0 PlotFact*sigma_0]); ylim([-MaxB MaxB])
    set(gca,'FontSize',FS)
    grid on; box on;
end


%% Plot ideal fields and RF vs magnet
IdealLoops = 50;
B_ideal2 = zeros(1,length(Xa));
B_rf2 = zeros(1,length(Xa));
PlotFact = 5;
for ii = 1:IdealLoops % Loop through multipoles
    n = ii+3;
    temp = 1/factorial(n-3)*(-1)^n/(2*emitt_geo_x_0*1e-6*beta_x_0)^(n-3)/beta_x_0/tan(phase_adv_def)*Pref*1e6/charge*(Xa/1000).^(2*n-5)/(2*n-5)/LM/c;
    B_ideal2 = B_ideal2+temp;
    temp_rf = 4.99e7/c*(-1)^n*(n-2)/factorial(n-4)/factorial(n)*(k_rf/2*Xa/1000).^(2*n-5);
    B_rf2 = B_rf2+temp_rf;
end
figure(); hold all; plot(Xa,B_ideal); plot(Xa,B_ideal2,'--'); plot(Xa,B_rf2,'--','linewidth',LW); plot(Xa,B_rf,'-')
xlim([-PlotFact*sigma_0 PlotFact*sigma_0]); ylim([-MaxB MaxB])


#### GRAVEYARD ####


##function MagnetArray = RF_2_Magnet(MultArray_RF_0)
##
##  for ii = 1:length(MultArray_RF_0)
##      if ii == 1
##          kNL = RF_Oct*k_rf^(M-1)/(Pref*1e6)*charge*Leff/(2^M);
##      end
##
##
##  end
##
##end

