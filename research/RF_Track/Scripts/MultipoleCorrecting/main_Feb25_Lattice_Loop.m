

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
Pref = logspace(0,4,101);
##Pref = 1; % [MeV]
freq_rf = 3;
B_time = 0; % Makes the bunch one rf period long
r_beam = 8; % [mm]
rings = 5; p_per_ring = 180; % Macro_part = product+1

FigNo = 1;
RF_Phase = [0 90]; % KEEP THIS ZERO FOR NOW does two tests - X and X + 90
FieldBool = 2; % Make 0 to turn off B field and 1 to turn off E field
FigureBool = 0;

colour_RFT = autumn(rings); colour_TLL = winter(rings); colour_PW = bone(rings);
colours = viridis(rings);

%% Define RF Cavity %%
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/CouplerCorrected/';
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/CouplerUncorrected/';
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/NoCoupler/';
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/2502_CouplerCorrected/';
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/2502_DualPort/';
RF_Folder = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/260216_Azi/';
RF_File = '0_25_Steps.dat';

RF_Struct = load(fullfile(RF_Folder,RF_File));

# scale on-axis to 10 MV/m
SizeMat = size(RF_Struct.a1);
MaxEz_OnAxis = max(abs(real(RF_Struct.E3_Mat((SizeMat(1)+1)/2,(SizeMat(1)+1)/2,:))));
SF = 10e6/MaxEz_OnAxis;
SF = 1; % remove this????

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

%% Useful derived quantities
for mm = 1:length(Pref)
    mm
    Eref = sqrt(Pref(mm)^2+mass^2);
    gammaref(mm) = Eref./mass;
    betaref(mm) =sqrt(1-1/gammaref(mm)^2);

    ##% Check Ez_on_axis
    ##figure(); hold all;
    ##z_on = RF_Struct.a3(34,34,:);
    ##Ez_on = RF_Struct.E3_Mat(34,34,:);
    ##plot(z_on,Ez_on)
    ##Zt = linspace(RF_Cav.get_z0*1000, RF_Cav.get_z1*1000, 5001);
    ##[E_field_on,B_field_on] = RF_Cav.get_field(0, 0, Zt, 0);
    ##Ez_on2 = E_field_on(:,3);
    ##plot(Zt,Ez_on2)




    %%%%% Build distribution %%%%%
    nParticles = rings*p_per_ring;
    B = Load_ConcentricBeam_2(rings,p_per_ring,r_beam,gammaref(mm),B_time);

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

        % Check on axis field again
        Za = linspace(L{2}.get_z0*1000, L{2}.get_z1*1000, 5001);
        [E_field_on_stat,B_field_on_stat] = L{2}.get_field(0, 0, Za,L{2}.get_t0);
        [E_field_on,B_field_on] = L{2}.get_field(0, 0, Za,Za);
        Ez_on3 = E_field_on(:,3);
        if jj == 1
            Ez_on3 = E_field_on(:,3);
            Vz_on_field = trapz(Za/1e3,Ez_on3/1e6); %[MV]
        end
        %plot(Za,Ez_on3)

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
        Delta_p_x_Lor = charge*trapz(Za/1e3,Ex_t_Mod-By_t_Mod*beta_z*c,3)/1e6; % [keV/c]
        Delta_p_y_Lor = charge*trapz(Za/1e3,Ey_t_Mod+Bx_t_Mod*beta_z*c,3)/1e6; % [keV/c]

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

          if jj == 1
              Vz_on_track = delta_Pz_ring(1,1); %[MV]
          end

          %% Calculation using derived formulae
          f_l = 3e9;
          k_l = 2*pi*f_l/c; G = c/2/3e9; a = 10;

          if jj == 1
            tilde_G_0 = 1; tilde_G_1 = 0.354579; tilde_G_2 = 0.055528;
    ##      tilde_G_0 = 1; tilde_G_1 = besselj(1,k_l*a*1e-3)/besselj(0,k_l*a*1e-3); tilde_G_2 = besselj(2,k_l*a*1e-3)/besselj(0,k_l*a*1e-3);

              function [FoM] = FitFunction(X,tilde_G_0,delta_Pz_ring,R_arr,RF_Phase,a,Vz_on_track,T_arr)

                  GArray =  X;

                  DeltaPzForm = Vz_on_track*cosd(RF_Phase(1))*(tilde_G_0*(R_arr(end)./a).^0+X(1)*(R_arr(end)./a).^1.*cos(T_arr)+X(2)*(R_arr(end)./a).^2.*cos(2*T_arr));

                  SSE = sqrt(sum((DeltaPzForm-delta_Pz_ring(end,:)).^2));

              ##    FoM = SSE;
                  FoM = SSE;

                  DispSpec = '%0.1f';

              end
              Sigmas2Fit = 5;
              O = optimset('TolX', 0.01, 'TolFun', 0.01, 'MaxFunEvals', 1e5, 'MaxIter', 1e5); % Define optimset
              FitHandle = @(X)FitFunction(X,tilde_G_0,delta_Pz_ring,R_arr,RF_Phase,a,Vz_on_track,T_arr);
              X_0 = [tilde_G_1, tilde_G_2];
##              [XOptim,SSE] = fminsearch(FitHandle, X_0, O);
##              tilde_G_0 = 1; tilde_G_1 = XOptim(1); tilde_G_2 = XOptim(2);
              tilde_G_0 = 1; tilde_G_1 = 0.354579; tilde_G_2 = 0.055528;
          end
##          tilde_G_1_loop(mm) = XOptim(1); tilde_G_2_loop(mm) = XOptim(2); SSE_loop(mm) = SSE;
          tilde_G_1_loop(mm) =0.354579; tilde_G_2_loop(mm) = 0.055528;

    ##      tilde_G_0_Norm = -3.9376e+07; % Need to get this factor
    ##      BoreNorm = tilde_G_0_Norm*SF/1e6;
    ##      BoreNorm = abs(tilde_G_0_Norm/1e6);
          Norm2Track = 1;
          if jj == 1
              DeltaPzForm = zeros(size(Delta_p_z));
              for ii = 1:length(R_arr)
    ##              DeltaPzForm(ii,:) = BoreNorm*G*sin(k_l*G/2)/(k_l*G/2)*cosd(RF_Phase(jj))*(tilde_G_0*(R_arr(ii)./a).^0+tilde_G_1*(R_arr(ii)./a).^1.*cos(T_arr)+tilde_G_2*(R_arr(ii)./a).^2.*cos(2*T_arr));
                  if Norm2Track == 1
                  DeltaPzForm(ii,:) = Vz_on_track*cosd(RF_Phase(jj))*(tilde_G_0*(R_arr(ii)./a).^0+tilde_G_1*(R_arr(ii)./a).^1.*cos(T_arr)+tilde_G_2*(R_arr(ii)./a).^2.*cos(2*T_arr));
                else
                  DeltaPzForm(ii,:) = charge*Vz_on_field*cosd(RF_Phase(jj))*(tilde_G_0*(R_arr(ii)./a).^0+tilde_G_1*(R_arr(ii)./a).^1.*cos(T_arr)+tilde_G_2*(R_arr(ii)./a).^2.*cos(2*T_arr));
                end

              end
              DeltaPzForm(:,1);
          end
          if jj == 2
              DeltaPxForm = zeros(size(Delta_p_z));
              DeltaPyForm = zeros(size(Delta_p_z));
              for ii = 1:length(R_arr)
                   if Norm2Track == 1
                    DeltaPxForm(ii,:) = (-1)*c/(2*pi*f_l)/(a*1e-3)*Vz_on_track*sind(RF_Phase(jj))*(1*tilde_G_1*(R_arr(ii)./a).^0*cos(0*T_arr)+2*tilde_G_2*(R_arr(ii)./a).^1.*cos(1*T_arr));
                    DeltaPyForm(ii,:) = (-1)*-c/(2*pi*f_l)/(a*1e-3)*Vz_on_track*sind(RF_Phase(jj))*(1*tilde_G_1*(R_arr(ii)./a).^0.*sin(0*T_arr)+2*tilde_G_2*(R_arr(ii)./a).^1.*sin(1*T_arr));
                   else
                    DeltaPxForm(ii,:) = (-1)*charge*c/(2*pi*f_l)/(a*1e-3)*Vz_on_field*sind(RF_Phase(jj))*(1*tilde_G_1*(R_arr(ii)./a).^0*cos(0*T_arr)+2*tilde_G_2*(R_arr(ii)./a).^1.*cos(1*T_arr));
                    DeltaPyForm(ii,:) = (-1)*-charge*c/(2*pi*f_l)/(a*1e-3)*Vz_on_field*sind(RF_Phase(jj))*(1*tilde_G_1*(R_arr(ii)./a).^0.*sin(0*T_arr)+2*tilde_G_2*(R_arr(ii)./a).^1.*sin(1*T_arr));
                   end
              end
          end

          LW = 1;
          if jj == 1

          if FigureBool == 1
                figure();
                subplot(2,3,3);
                hold all;
                for kk = 1:rings
                    plot(T_arr*180/pi,delta_Pz_ring(kk,:),'-','color',colours(kk,:),'linewidth',LW-0.2);
                    plot(T_arr*180/pi,DeltaPzForm(kk,:),'--','color',colours(kk,:),'linewidth',LW+0.2);
                end
                xlabel('$\theta$ [deg]','interpreter','latex'); ylabel(['$\Delta P_z$ [MeV/c]' ; ' '; ' '],'interpreter','latex'); grid on; box on;
                FS = 16;
                set(gca,'FontSize',FS)
                xlim([0 360]);
                set(gcf,'Position',[212 130 824 682])
            end

            MaxPzError = max(max(abs(delta_Pz_ring-DeltaPzForm)));
            PzError = abs(delta_Pz_ring-DeltaPzForm);
            [Max_z_val,Max_z_Pos] = max(PzError);
            [MaxPzError,Max_z_Pos2] = max(Max_z_val);
            MaxPzPercentErr = abs(MaxPzError/DeltaPzForm(Max_z_Pos(Max_z_Pos2),Max_z_Pos2))*100;
            PzErr(mm) = MaxPzError;
            PzPerErr(mm) = MaxPzPercentErr;
            Pz_SSE(mm,:) = sqrt(sum((DeltaPzForm'-delta_Pz_ring').^2));
            Pz_RMSE(mm,:) = sqrt(1/length(DeltaPzForm)*sum((DeltaPzForm'-delta_Pz_ring').^2));

          endif

          if jj == 2
              if FigureBool == 1
                    figure();
                    subplot(2,3,3);
                    hold all;
                    for kk = 1:rings
                        plot(T_arr*180/pi,delta_Px_ring(kk,:),'-','color',colours(kk,:),'linewidth',LW-0.2);
                        plot(T_arr*180/pi,DeltaPxForm(kk,:),'--','color',colours(kk,:),'linewidth',LW+0.2);
                    end
                    FS = 16;
                    set(gca,'FontSize',FS)
                    xlim([0 360]);
                    xlabel('$\theta$ [deg]','interpreter','latex'); ylabel(['$\Delta P_x$ [MeV/c]' ; ' '; ' '],'interpreter','latex'); grid on; box on;
                    set(gcf,'Position',[212 130 824 682])

                    figure(3);
                    subplot(2,3,3);
                    hold all;
                    for kk = 1:rings
                        plot(T_arr*180/pi,delta_Py_ring(kk,:),'-','color',colours(kk,:),'linewidth',LW-0.2);
                        plot(T_arr*180/pi,DeltaPyForm(kk,:),'--','color',colours(kk,:),'linewidth',LW+0.2);
                    end
                    xlabel('$\theta$ [deg]','interpreter','latex'); ylabel(['$\Delta P_y$ [MeV/c]' ; ' '; ' '],'interpreter','latex'); grid on; box on;
                    FS = 16;
                    set(gca,'FontSize',FS)
                    xlim([0 360]);
                    set(gcf,'Position',[212 130 824 682])
                end

                MaxPxError = max(max(abs(delta_Px_ring-DeltaPxForm)));
                PxError = abs(delta_Px_ring-DeltaPxForm);
                [Max_x_val,Max_x_Pos] = max(PxError);
                [MaxPxError,Max_x_Pos2] = max(Max_x_val);
                MaxPxPercentErr = abs(MaxPxError/DeltaPxForm(Max_x_Pos(Max_x_Pos2),Max_x_Pos2))*100;
                PxErr(mm) = MaxPxError;
                PxPerErr(mm) = MaxPxPercentErr;
                Px_RMSE(mm,:) = sqrt(1/length(DeltaPxForm)*sum((DeltaPxForm'-delta_Px_ring').^2));
                Px_SSE(mm,:) = sqrt(sum((DeltaPxForm'-delta_Px_ring').^2));
                MaxPxError = max(max(2*(delta_Px_ring-DeltaPxForm)./(abs(delta_Px_ring)+abs(DeltaPxForm))))*100;

                MaxPyError = max(max(abs(delta_Py_ring-DeltaPyForm)));
                PyError = abs(delta_Py_ring-DeltaPyForm);
                [Max_y_val,Max_y_Pos] = max(PyError);
                [MaxPyError,Max_y_Pos2] = max(Max_y_val);
                MaxPyPercentErr = abs(MaxPyError/DeltaPyForm(Max_y_Pos(Max_y_Pos2),Max_y_Pos2))*100;
                PyErr(mm) = MaxPyError;
                PyPerErr(mm) = MaxPyPercentErr;
                Py_SSE(mm,:) = sqrt(sum((DeltaPyForm'-delta_Py_ring').^2));
                Py_RMSE(mm,:) = sqrt(1/length(DeltaPyForm)*sum((DeltaPyForm'-delta_Py_ring').^2));
                MaxPyError = max(max(2*(delta_Py_ring-DeltaPyForm)./(abs(delta_Py_ring)+abs(DeltaPyForm))))*100;
            endif

        % Plot final phase space
        if FigureBool == 1
            figure();
            subplot(2,2,1); plot(M1(:,3),M1(:,5),'x'); xlabel('x [mm]'); ylabel('y [mm]');
            subplot(2,2,2); plot(M1(:,4),M1(:,6),'x'); xlabel('Px [MeV/c]'); ylabel('Py [MeV/c]');
            subplot(2,2,3); plot(M1(:,8),M1(:,7),'x'); xlabel('t [mm/c]'); ylabel('P [MeV/c]');
            subplot(2,2,4); plot(M1(:,1),M1(:,9),'x'); xlabel('z [mm]'); ylabel('Pz [MeV/c]');
        end

         %%%% RF Focusing Calculation %%%%
         if jj == 1
             Delta_p_r_RF = pi*freq_rf*1e9.*R_mat/1e3/gammaref(mm)^2/beta_z.^2/c*cosd(RF_Phase(jj)).*V_Mat/1e3;
             Delta_p_x_RF = Delta_p_r_RF.*cos(T_mat);
             Delta_p_y_RF = Delta_p_r_RF.*sin(T_mat);
             if FigureBool == 1
                 figure();
                 subplot(2,1,1); plot(T_arr,Delta_p_x_RF); xlabel('\theta [rad]'); ylabel(['\Delta P_x [keV/c]'; ' ' ; ' ']); grid on; box on;
                 subplot(2,1,2); plot(T_arr,Delta_p_y_RF); xlabel('\theta [rad]'); ylabel(['\Delta P_y [keV/c]'; ' ' ; ' ']); grid on; box on;
                 title('RF Focusing')
             end
         end
    end

end




return

figure();
##subplot(2,3,3);
hold all;
for kk = 2:rings
##    plot(gammaref,Pz_SSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
##    plot(betaref,Pz_SSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
##    plot(Pref,Pz_SSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
    plot(Pref,Pz_RMSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
end
##xlabel('$\gamma_{i}$','interpreter','latex'); xlim([gammaref(1),gammaref(end)]); set(gca,'yscale','log','xscale','log')
##xlabel('$\beta_{i,z}$','interpreter','latex'); xlim([betaref(1),betaref(end)]); set(gca,'yscale','log')
xlabel('$p_{i,z}$ [MeV/c]','interpreter','latex'); xlim([Pref(1),Pref(end)]); set(gca,'yscale','log','xscale','log')
##ylabel(['RSS($\Delta p_z$) [(MeV/c)$^2$]' ; ' '; ' '],'interpreter','latex');
ylabel(['RMSD($\Delta p_z$) [MeV/c]' ; ' '; ' '],'interpreter','latex');
grid on; box on;
FS = 12;
set(gca,'FontSize',FS)
set(gcf,'Position',[534 278 283 400])

##FS = 16;
##set(gcf,'Position',[212 130 824 682])
##set(gca,'FontSize',FS)


figure();
##subplot(2,3,3);
hold all;
for kk = 1:rings
##    plot(gammaref,Px_SSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
##    plot(betaref,Px_SSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
##    plot(Pref,Px_SSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
     plot(Pref,Px_RMSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
end
##xlabel('$\gamma_{i}$','interpreter','latex'); xlim([gammaref(1),gammaref(end)]); set(gca,'yscale','log','xscale','log')
##xlabel('$\beta_{i,z}$','interpreter','latex'); xlim([betaref(1),betaref(end)]); set(gca,'yscale','log')
xlabel('$p_{i,z}$ [MeV/c]','interpreter','latex'); xlim([Pref(1),Pref(end)]); set(gca,'yscale','log','xscale','log')
##ylabel(['RSS($\Delta p_x$) [(MeV/c)$^2$]' ; ' '; ' '],'interpreter','latex');
ylabel(['RMSD($\Delta p_x$) [MeV/c]' ; ' '; ' '],'interpreter','latex');
grid on; box on;
FS = 12;
set(gca,'FontSize',FS)
set(gcf,'Position',[534 278 283 400])

##FS = 16;
##set(gcf,'Position',[212 130 824 682])
##set(gca,'FontSize',FS)



figure();
##subplot(2,3,3);
hold all;
for kk = 1:rings
##    plot(gammaref,Py_SSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
##    plot(betaref,Py_SSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
##    plot(Pref,Py_SSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
        plot(Pref,Py_RMSE(:,kk),'-','color',colours(kk,:),'linewidth',LW)
end
##xlabel('$\gamma_{i}$','interpreter','latex'); xlim([gammaref(1),gammaref(end)]); set(gca,'yscale','log','xscale','log')
##xlabel('$\beta_{i,z}$','interpreter','latex'); xlim([betaref(1),betaref(end)]); set(gca,'yscale','log')
xlabel('$p_{i,z}$ [MeV/c]','interpreter','latex'); xlim([Pref(1),Pref(end)]); set(gca,'yscale','log','xscale','log')
##ylabel(['RSS($\Delta p_y$) [(MeV/c)$^2$]' ; ' '; ' '],'interpreter','latex');
ylabel(['RMSD($\Delta p_y$) [MeV/c]' ; ' '; ' '],'interpreter','latex');
grid on; box on;
FS = 12;
set(gca,'FontSize',FS)
set(gcf,'Position',[534 278 283 400])

##FS = 16;
##set(gcf,'Position',[212 130 824 682])
##grid on; box on;
##set(gca,'FontSize',FS)




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
    L{2}.set_phid(RF_Phase(1))
    NoTheta = 201; NoR = 5;
    theta_arr = linspace(0,2*pi,NoTheta);
    r_arr = linspace(0,9,NoR);
    r_arr = linspace(0,8,NoR);
    colours = viridis(NoR);
    Volt = zeros(NoTheta,NoR);
    Volt_t = zeros(NoTheta,NoR);
    count_t = 1;
    for theta = theta_arr
        Za = linspace(L{2}.get_z0*1000, L{2}.get_z1*1000, 5001);
        count_r = 1;
        for r = r_arr
            X = r*cos(theta); Y = r*sin(theta);
            [E_field,B_field] = L{2}.get_field(X, Y, Za, L{2}.get_t0); % x,y,z,t (mm, mm/c)
            [E_field_t,B_field_t] = L{2}.get_field(X, Y, Za, Za); % x,y,z,t (mm, mm/c)
            Ez = E_field(:,3);
            Volt(count_t,count_r) = trapz(Za,Ez)/1e9;
            Ez_t = E_field_t(:,3);
            Volt_t(count_t,count_r) = trapz(Za,Ez_t)/1e9;
             count_r = count_r+1;
        endfor
      count_t = count_t+1;
     end
##      figure(1);
##      plot(r_arr,Volt)
      figure(); subplot(2,2,2); hold all;
      for ii = 1:NoR
        %plot(theta_arr*180/pi,-Volt_t(:,ii)*1000,'-','color',colours(ii,:),'linewidth',1.2,'handlevisibility','off')
        plot(theta_arr*180/pi,Volt_t(:,ii)/Vz_on_field,'-','color',colours(ii,:),'linewidth',1.2,'displayname',['r = ' num2str(r_arr(ii)) ' mm'])
      end
      xlabel('$\theta$ [deg]','interpreter','latex')
      ylabel('$\Delta p_z$ [MeV/c]','interpreter','latex');
      ytickangle(gca,45)
      %legend('location','NorthEast','orient','vertical')
      %legend('location','NorthOutside','orientation','horizontal')
      box on; grid on;
      set(gcf,'Color','w')
      FS = 16;
      set(gca,'FontSize',FS)
      xlim([0 360]);
      set(gcf,'Position',[212 130 824 682])
##      yticks([1, 1.0001, 1.0002, 1.0003])
yticks([0.99995,1,1.00005])
      yticklabels({'0.99995' ; '1'; '1.00005'})


end

legend({'$r$ = 0 mm','$r$ = 2 mm','$r$ = 4 mm','$r$ = 6 mm','$r$ = 8 mm'}, 'location','NorthOutside','orient','horizontal','interpreter','latex')
set(gca,'Fontsize',16)

