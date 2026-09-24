


function [MultipoleCav,MaxEz] = F_MultipoleCav(MultArrayOptim,freq_rf,LM,r_rf_interest,PlotBool)

##    MultArrayOptim = [0 0 0 0 4.6828e7]; freq_rf = 3e9; k = 2*pi*freq_rf/299792458; LM = 0.04; r_rf_interest = 2.4048/k*1000; PlotBool = true; MultArrayOptim = [1];
    %% Init RF-track
    RF_Track;
    c = RF_Track.clight;
    LM_mm = LM*1000; % [mm] make it mm instead


    ### MULTIPOLE SPEC ###
    g_M    = MultArrayOptim;
    M        = linspace(0,length(g_M)-1,length(g_M));
    phi_M = zeros(1,length(g_M));
    p = 0;


    ### SPECIFY PARAMETERS FOR FIELD ###
    r_max = r_rf_interest; % [mm]. Specify max radius for beam

    r_spacing = 0.1;
    theta_spacing = pi/360;
    z_spacing = LM_mm/10; % [mm]

    ### BEGIN SCRIPT AUTOMATIC ###

    % Create arrays
    ra = (0:r_spacing:r_max)/1000; % [m]
    ta = 0:theta_spacing:2*pi; % [rad]
    za = (0:z_spacing:LM_mm)/1000; % [m]

    % Create matrices for speedy processing
    [Ra,Ta,Za] = ndgrid(ra,ta,za);

    # This corrects for undefined theta at r = 0
    Ta(1,:,:) = 0;

    Er_temp = zeros(size(Ra));
    Et_temp = zeros(size(Ra));
    Ez_temp = zeros(size(Ra));
    Br_temp = zeros(size(Ra));
    Bt_temp = zeros(size(Ra));
    Bz_temp = zeros(size(Ra));


    % Calculate some values for ease
    lambda = c/(freq_rf); omega = 2*pi*freq_rf;
    k_l = 2*pi/lambda;   % [m]
    k_p = 2*p*pi/(LM); % [m]
    kappa_p = sqrt(k_l^2-k_p^2);

    r_test = 10*2.4048/k_l; r_test_arr = linspace(0,r_test,1001); % [mm]
    Ez_lin = zeros(1,1001);

    % Loop through each of the multipole values, adding to each one
    for ii = 1:length(g_M)
          if g_M(ii) ~= 0 % Remove unnecessary calculation
              Er_temp  = Er_temp - sin(k_p*Za).*k_p./kappa_p.*g_M(ii).*(0.5*(besselj(M(ii)-1,kappa_p*Ra)-besselj(M(ii)+1,kappa_p*Ra))).*cos(M(ii).*Ta-phi_M(ii));
              Et_temp  = Et_temp + sin(k_p*Za).*k_p./(kappa_p^2 .*Ra).*M(ii).*g_M(ii).*besselj(M(ii),kappa_p*Ra).*sin(M(ii).*Ta-phi_M(ii));
              Ez_temp = Ez_temp + cos(k_p*Za)*g_M(ii).*besselj(M(ii),kappa_p*Ra).*cos(M(ii).*Ta-phi_M(ii));

              Ez_lin = Ez_lin + g_M(ii).*besselj(M(ii),kappa_p*r_test_arr); % basic test

              Br_temp  = Br_temp +i/omega.*cos(k_p*Za).*(k_p.^2+kappa_p.^2)./(kappa_p.^2.*Ra).*M(ii).*g_M(ii).*besselj(M(ii),kappa_p*Ra).*sin(M(ii).*Ta-phi_M(ii));
              Bt_temp  = Bt_temp +i/omega.*cos(k_p*Za).*(k_p.^2+kappa_p.^2)./kappa_p*g_M(ii).*(0.5*(besselj(M(ii)-1,kappa_p*Ra)-besselj(M(ii)+1,kappa_p*Ra))).*cos(M(ii).*Ta-phi_M(ii));
              #Bz_temp = 0;
          end
    end

    % Convert any Nans arising from 0/0 to 0
    Er_temp(isnan(Er_temp))=0;
    Et_temp(isnan(Et_temp))=0;
    Ez_temp(isnan(Ez_temp))=0;
    Br_temp(isnan(Br_temp))=0;
    Bt_temp(isnan(Bt_temp))=0;
    Bz_temp(isnan(Bz_temp))=0;

    ### CONVERT TO MATCH CST SAVE FORMAT ###
    % Convert to mm and save some things
    a1 = Ra*1000; a2 = Ta; a3 = Za*1000;
    SF = 1; % Make sure the units of g_m make sense
    E1_Mat = Er_temp*SF; E2_Mat = Et_temp*SF; E3_Mat = Ez_temp*SF;
    B1_Mat = Br_temp*SF; B2_Mat = Bt_temp*SF; B3_Mat = Bz_temp*SF;
    d1 = r_spacing; d2 = theta_spacing; d3 = z_spacing;
    loc_x = 0; loc_y = 0;


    MaxEz = max(Ez_lin);

    if PlotBool == true
        index = 1;
        r_max = max(max(max(Ra)));
        x_plot = Ra.*cos(Ta); y_plot = Ra.*sin(Ta);
##        x_plot = linspace(-r_max,r_max,length(Ra));
##        y_plot = linspace(-r_max,r_max,length(Ra));
        figure(); surf(x_plot(1:end,:,index),y_plot(:,:,index),abs(Ez_temp(:,:,index)))
        shading interp;
        xlabel('x [mm]'); ylabel('y [mm]'); zlabel('E_z [MV/m]'); set(gca,'Fontsize',16);

        mesh_size = size(x_plot); arrows_x = 50; arrows_y = 50;
        dq_x = round(mesh_size(1)/arrows_x); dq_y = round(mesh_size(2)/arrows_y);
        figure(); h = quiver(x_plot(1:dq_x:end,1:dq_y:end,index),y_plot(1:dq_x:end,1:dq_y:end,index),Br_temp(1:dq_x:end,1:dq_y:end,index).*cos(Ta(1:dq_x:end,1:dq_y:end,index))-Bt_temp(1:dq_x:end,1:dq_y:end,index).*sin(Ta(1:dq_x:end,1:dq_y:end,index)),Br_temp(1:dq_x:end,1:dq_y:end,index).*sin(Ta(1:dq_x:end,1:dq_y:end,index))+Bt_temp(1:dq_x:end,1:dq_y:end,index).*cos(Ta(1:dq_x:end,1:dq_y:end,index)));
        %set (h, "maxheadsize", 0.01);
        pause(0.1); % this appears to help
        xlabel('x [mm]'); ylabel('y [mm]'); set(gca,'Fontsize',16);
    end

    ### GENERATE FIELD MAP ELEMENTS ###
    MultipoleCav = RF_FieldMap_CINT(imag(E1_Mat), imag(E2_Mat), imag(E3_Mat), ...
                     imag(B1_Mat), imag(B2_Mat),  imag(B3_Mat), ...
                     loc_x*1e-3,  loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     d1*1e-3, ... % dr [m]
                     d2, ... % dtheta [rad]
                     d3*1e-3, ... % dz [m]
                     -1, ... % take the default length
                     0, ... % remove time dependence - fix later
                     +1);% standing wave
     MultipoleCav.set_cylindrical(true);



    if PlotBool == true
       MultipoleCav2 = RF_FieldMap_CINT(real(E1_Mat), real(E2_Mat), real(E3_Mat), ...
                     real(B1_Mat), real(B2_Mat),  real(B3_Mat), ...
                     loc_x*1e-3,  loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     d1*1e-3, ... % dr [m]
                     d2, ... % dtheta [rad]
                     d3*1e-3, ... % dz [m]
                     -1, ... % take the default length
                     0, ... % remove time dependence - fix later
                     +1);% standing wave
       MultipoleCav2.set_cylindrical(true);
       Z_index = 1;

       mesh_size = size(x_plot); arrows_x = 50; arrows_y = 50;
       dq_x = round(mesh_size(1)/arrows_x); dq_y = round(mesh_size(2)/arrows_y);

       pa = (-r_max:r_spacing:r_max);
       [Xa,Ya,Za] = ndgrid(pa,pa,za);
        X = Xa(1:dq_x:end,1:dq_y:end,Z_index);
        Y = Ya(1:dq_x:end,1:dq_y:end,Z_index);

        [E,B] = MultipoleCav2.get_field(X(:),Y(:),zeros(size(X(:))),zeros(size(X(:))));

        figure(); surf(X,Y,reshape(E(:,3),size(X)));
        shading interp;
        xlabel('x [mm]'); ylabel('y [mm]'); zlabel('E_z [MV/m]'); set(gca,'Fontsize',16);

        [E,B] = MultipoleCav.get_field(X(:),Y(:),zeros(size(X(:))),zeros(size(X(:))));

        Bx_RF = reshape(B(:,1),size(X));
        By_RF = reshape(B(:,2),size(Y));
        figure(); h = quiver(X,Y,Bx_RF,By_RF);
    end

end


