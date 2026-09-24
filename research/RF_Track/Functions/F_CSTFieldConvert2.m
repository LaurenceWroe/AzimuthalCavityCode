# CSTFieldConvert.m
clear all; close all;
RF_Track;
c = RF_Track.clight;


##EMFolderMain = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/Azimuthally/Maps/NoPipe/';
#EMFolderMain = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps/TM0210Acc_PipeAzi/';
#EMFolderSub_E = 'Mode 1_e.txt';
#EMFolderSub_H = 'Mode 1_h.txt';

EMFolderMain = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/CouplerNoCorrection/';
EMFolderMain = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/CouplerUncorrected//';
EMFolderMain = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/2502_QuadPort/';
EMFolderMain = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/2502CSTFile_10mm/';
EMFolderMain = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/MultipoleCorrecting/Maps/260216_Cancel10/';
EMFolderMain = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260310_TM_610_Pill/';
##EMFolderMain = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/260310_LBand_TM_410/';
##EMFolderMain = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250317_TM24610_-11_7_50/';
EMFolderMain = '/Users/wroe/cernbox2/Code/RF_Track/Scripts/uniform_beam/Maps2/250608_TM46810/';
EMFolderSub_E = 'Mode 1_e__subvol.txt';
EMFolderSub_H = 'Mode 1_h__subvol.txt';

save_file = '0_5_Steps.dat';
save_folder = EMFolderMain;


E_Mat = dlmread(fullfile(EMFolderMain,EMFolderSub_E));
E_Mat = E_Mat(3:end,:);
x_E = E_Mat(:,1); y_E = E_Mat(:,2); z_E = E_Mat(:,3);
Ex = (E_Mat(:,4)+1i*E_Mat(:,5)); Ey = (E_Mat(:,6)+1i*E_Mat(:,7)); Ez = (E_Mat(:,8)+1i*E_Mat(:,9));

x_E(abs(x_E)<1e-12) = 0; y_E(abs(y_E)<1e-12) = 0; z_E(abs(z_E)<1e-12) = 0;
temp_x = sort(unique(x_E)); temp_y = sort(unique(y_E)); temp_z = sort(unique(z_E));

dx = temp_x(2)-temp_x(1); dy = temp_y(2)-temp_y(1); dz = temp_z(2)-temp_z(1);


H_Mat = dlmread(fullfile(EMFolderMain,EMFolderSub_H));
mu_0 = 4*pi*1e-7;
H_Mat = H_Mat(3:end,:);
x_B = H_Mat(:,1); y_B = H_Mat(:,2); z_B = H_Mat(:,3);
Bx = (H_Mat(:,4)+1i*H_Mat(:,5))*mu_0; By = (H_Mat(:,6)+1i*H_Mat(:,7))*mu_0; Bz = (H_Mat(:,8)+1i*H_Mat(:,9))*mu_0;

x_B(abs(x_B)<1e-12) = 0; y_B(abs(y_B)<1e-12) = 0; z_B(abs(z_B)<1e-12) = 0;
temp2_x = sort(unique(x_B)); temp2_y = sort(unique(y_B)); temp2_z = sort(unique(z_B));
% Note Bx varies x then varies y then varies z

if length(temp2_x) != length(temp_x) || length(temp2_y) != length(temp_y) || length(temp2_z) != length(temp_z)
    warning('E and H files are not the same size')
end

### CONVERT EM FIELD TO REQUIRED FORM ###
dimx = length(temp_x); dimy = length(temp_y); dimz = length(temp_z);

Ex_Mat = zeros(dimx,dimy,dimz); Bx_Mat = zeros(dimx,dimy,dimz);
Ey_Mat = zeros(dimx,dimy,dimz); By_Mat = zeros(dimx,dimy,dimz);
Ez_Mat = zeros(dimx,dimy,dimz); Bz_Mat = zeros(dimx,dimy,dimz);
X_test = zeros(dimx,dimy,dimz); Y_test = zeros(dimx,dimy,dimz); Z_test = zeros(dimx,dimy,dimz);

[Xa,Ya,Za] = ndgrid(temp_x,temp_y,temp_z);


Ex_Mat = reshape(Ex, size(Xa));
Ey_Mat = reshape(Ey, size(Ya));
Ez_Mat = reshape(Ez, size(Za));
Bx_Mat = reshape(Bx, size(Xa));
By_Mat = reshape(By, size(Ya));
Bz_Mat = reshape(Bz, size(Za));

if sum(real(Bx+By+Bz)) ~= 0 || sum(imag(Ex+Ey+Ez)) ~= 0
    warning('CST field writing issue')
end

%% NOTE ROTATION FUNCTIONALITY NOT COMPLETE
% NEED TO ADD IN A PROCEDURE TO RECALCULATE
% IN CARTESIAN SPACE FOR RF_FieldMap_CINT
##theta = 0;
##E1_Mat = Ex_Mat*cos(theta) - Ey_Mat*sin(theta);
##E2_Mat = Ex_Mat*sin(theta) + Ey_Mat*cos(theta);
##E3_Mat = Ez_Mat;
##
##B1_Mat = Bx_Mat*cos(theta) - By_Mat*sin(theta);
##B2_Mat = Bx_Mat*sin(theta) + By_Mat*cos(theta);
##B3_Mat = Bz_Mat;
##
##a1 = Xa*cos(theta) - Ya*sin(theta);
##a2 = Xa*sin(theta) + Ya*cos(theta);
##a3 = Za;

a1 = Xa; a2 = Ya; a3 = Za;
E1_Mat = Ex_Mat; E2_Mat = Ey_Mat; E3_Mat = Ez_Mat;
B1_Mat = Bx_Mat; B2_Mat = By_Mat; B3_Mat = Bz_Mat;

d1 = dx; d2 = dy; d3 = dz;
loc_x = min(temp_x); loc_y = min(temp_x);
save(fullfile(save_folder,save_file),'a1','a2','a3','E1_Mat','E2_Mat','E3_Mat','B1_Mat','B2_Mat','B3_Mat','d1','d2','d3','loc_x','loc_y')

return

p = size(B3_Mat);
Z_index = (p(3)+1)/2;
Z_index = 1;
##Z_index = 1;

##for index = 1:10:p(3)
figure(); surf(a1(1:end,:,Z_index),a2(:,:,Z_index),abs(E3_Mat(:,:,Z_index)))
shading interp;
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('E_z [MV/m]'); set(gca,'Fontsize',16);

mesh_size = size(a1); arrows_x = 10; arrows_y = 10;
dq_x = round(mesh_size(1)/arrows_x); dq_y = round(mesh_size(2)/arrows_y);
figure(); h = quiver(a1(1:dq_x:end,1:dq_y:end,Z_index),a2(1:dq_x:end,1:dq_y:end,Z_index),B1_Mat(1:dq_x:end,1:dq_y:end,Z_index),B2_Mat(1:dq_x:end,1:dq_y:end,Z_index));
##set (h, "maxheadsize", 0.01);
pause(0.1); % this appears to help
xlabel('x [mm]'); ylabel('y [mm]'); set(gca,'Fontsize',16);
##end

RF_Track;
M = RF_FieldMap_CINT(imag(E1_Mat), imag(E2_Mat), real(E3_Mat), ...
                     imag(B1_Mat), imag(B2_Mat),  imag(B3_Mat), ...
                     loc_x*1e-3,  loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     d1*1e-3, ... % dx, m
                     d2*1e-3, ... % dy, m
                     d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     0,%freq_rf*1e9,... freq in Hz
                     +1);% standing wave

X = a1(1:dq_x:end,1:dq_y:end,Z_index);
Y = a2(1:dq_x:end,1:dq_y:end,Z_index);
ZPos = a3(1,1,Z_index)+M.get_length()/2*1000;
##ZPos = M.get_length()/2*1000;

[E,B] = M.get_field(X(:),Y(:),ones(size(X(:)))*ZPos,zeros(size(X(:))));
Bx_RF = reshape(B(:,1),size(X));
By_RF = reshape(B(:,2),size(Y));
figure(); h = quiver(X,Y,Bx_RF,By_RF,'linewidth',0.75);
xlabel('x [mm]'); ylabel('y [mm]'); set(gca,'Fontsize',16);
return

freq = 3e9;
M_complex = RF_FieldMap_CINT(E1_Mat, E2_Mat, E3_Mat, ...
                     B1_Mat, B2_Mat,  B3_Mat, ...
                     loc_x*1e-3,  loc_y*1e-3, ... % this is bottom left corner of mesh, m
                     d1*1e-3, ... % dx, m
                     d2*1e-3, ... % dy, m
                     d3*1e-3, ... % dz, m
                     -1, ... % take the default size
                     freq,%freq_rf*1e9,... freq in Hz
                     +1);% standing wave
M_complex.set_phi(pi/2); M_complex.set_t0(0);
X = a1(1:dq_x:end,1:dq_y:end,Z_index);
Y = a2(1:dq_x:end,1:dq_y:end,Z_index);
ZPos = a3(1,1,Z_index)+M.get_length()/2*1000;
##ZPos = M.get_length()/2*1000;

for phi = 0:pi/10:2*pi
    t = RF_Track.s/freq*phi/(2*pi);
    [E,B] = M_complex.get_field(X(:),Y(:),ones(size(X(:)))*ZPos,t*ones(size(X(:))));
    Bx_RF = reshape(B(:,1),size(X));
    By_RF = reshape(B(:,2),size(Y));

    figure(1); clf; surf(X,Y,reshape(E(:,3),size(X))/1e6); shading interp;
    title(['Ez Max = ' num2str(max(E(:,3))/1e6) 'MV/m']);xlabel('x [mm]'); ylabel('y [mm]'); set(gca,'Fontsize',16);
    figure(2); clf; h = quiver(X,Y,Bx_RF,By_RF,'linewidth',0.75);
    title(['Bz Max = ' num2str(max(sqrt(B(:,1).^2+B(:,2).^2))) 'mT']); xlabel('x [mm]'); ylabel('y [mm]'); set(gca,'Fontsize',16);
    pause(0.1)
end

return


ra = linspace(0,120.68867,501);
figure();  hold all;
plot(ra,By_x,'r')
plot(ra,Bx_x,'g')
freq_rf = 3e9; kappa_p = 2*pi*freq_rf/c; omega = 2*pi*freq_rf;
B_pred = real(1/omega.*kappa_p*4.6828e7*(0.5*(besselj(3,kappa_p*ra/1000)-besselj(5,kappa_p*ra/1000))));
SF = 1;
plot(ra,B_pred*SF,'b');


figure();  hold all;
plot(ra,Ez_x,'r')
E_pred = real(4.6828e7.*(besselj(4,kappa_p*ra/1000)));
plot(ra,E_pred*SF,'b');
##return
##SF = max(Ez_x)/max(E_pred)
##
##Bx_y = []; By_y = []; Bz_y = [];
##Ex_y = []; Ey_y = []; Ez_y = [];
##for Y = ra
##    [E,B] = M.get_field(0, Y, ZPos, 0); % x,y,z,t (mm, mm/c)
##    Bx_y = [ Bx_y ; B(1) ];
##    By_y = [ By_y ; B(2) ];
##    Bz_y = [ Bz_y ; B(3) ];
##    Ex_y = [ Ex_y ; E(1) ];
##    Ey_y = [ Ey_y ; E(2) ];
##    Ez_y = [ Ez_y ; E(3) ];
##end
##

