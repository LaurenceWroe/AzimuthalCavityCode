%% FastShapeSolver.m
% The aim of this code is to plot the Bessel shape and then indicate how
% the Bessel shape varies as theta changes.
c = physconst('lightspeed'); 
ShapeColours = [0 0 0.2; 0 0.2 1; 0 1 1];  


PointsFactor = 1; 
Roots = [1 2 3]; 

% Pillbox
m = [0];
BessVals = [1];
PhiVals = [0];
f = 3e9;

% ITERATION 1 - Feb 2025
m = [0, 1, 2, 3];
BessVals = [1, 0.025,0.028,-0.04 ];
PhiVals = [0, pi/2, 0, pi/2];
f = 3e9;

% ITERATION 1 with oct - Feb 2025
m = [0, 1, 2, 3, 4];
BessVals = [1, 0.025,0.0287,-0.058, -0.162-0.045];
PhiVals = [0, pi/2, 0, pi/2, 0];
f = 3e9;

% ITERATION 2 with oct - Feb 2025
m = [0, 1, 2, 3, 4];
BessVals = [1, 0.025+0.0035,0.0287+0.0053,-0.058-0.0152-0.003, -0.162-0.045];
PhiVals = [0, pi/2, 0, pi/2, 0];
f = 3e9;

% ITERATION 3 with oct - Feb 2025
m = [0, 1, 2, 3, 4];
BessVals = [1, 0.025+0.0035+0.0017,0.0287+0.0053+0.0021,-0.058-0.0152-0.003, -0.162-0.045-0.005];
PhiVals = [0, pi/2, 0, pi/2, 0];
f = 3e9;

% ITERATION 4 with oct - Feb 2025
m = [0, 1, 2, 3, 4];
BessVals = [1, 0.025+0.0035+0.0017-0.0005,0.0287+0.0053+0.0021-0.0007,-0.058-0.0152-0.003-0.004, -0.162-0.045-0.005-0.045];
PhiVals = [0, pi/2, 0, pi/2, 0];
f = 3e9;

% ITERATION 5 with oct - Feb 2025
m = [0, 1, 2, 3, 4];
BessVals = [1, 0.025+0.0035+0.0017-0.0005+0.0007, 0.0287+0.0053+0.0021-0.0007+0.0009,-0.058-0.0152-0.003-0.004, -0.162-0.045-0.005-0.045];
PhiVals = [0, pi/2, 0, pi/2, 0];
f = 3e9;

% ITERATION 8 with oct - Feb 2025
m = [0, 1, 2, 3, 4];
BessVals = [1, 0.025+0.0035+0.0017-0.0005+0.0007-0.000136+0.000257-0.000125-0.000124, 0.0287+0.0053+0.0021-0.0007+0.0009-0.00019,-0.058-0.0152-0.003-0.004, -0.162-0.045-0.005-0.045];
PhiVals = [0, pi/2, 0, pi/2, 0];
f = 3e9;

% OCTUPOLE
m = [4 6];
BessVals = [1 -8.25];
PhiVals = 0;
f = 3e9;

% OCTUPOLE
m = [4];
BessVals = [1];
PhiVals = 0;
f = 1.3e9;


% % ITERATION 1
% m = [0, 1, 2, 3];
% BessVals = [1, 0.022,0.0226,-0.055];
% PhiVals = [0, pi/2, 0, pi/2];
% f = 3e9;
% 
% % ITERATION 2
% m = [0, 1, 2, 3, 4];
% BessVals = [1, 0.022+0.0037,0.0226+0.008,-0.055-0.01, -0.2];
% PhiVals = [0, pi/2, 0, pi/2, 0];
% f = 3e9;
% 
% % ITERATION 3
% m = [0, 1, 2, 3, 4];
% BessVals = [1, 0.022+0.0037+0.0038,0.0226+0.008+0.008,-0.055-0.01, -0.2];
% PhiVals = [0, pi/2, 0, pi/2, 0];
% f = 3e9;
% 
% % Dipole build
% m = [0, 2];
% BessVals = [0, 1];
% PhiVals = [0, 0];
% f = 3e9;

Circ_r = 38.247509278403/1.003918629048720/1.000035001225043*0.999996666677778;
Circ_r = 38.247509278403*2.99961/3*3.00046/3*3.023484*3.000126/3/3;

k =2*pi*f/c;
ArgRange = 32/k;

%%
[r_0, theta, RootStruct] = F_AziShapeCalc_Fast(f,PointsFactor,ArgRange,m,BessVals,PhiVals,Roots);

theta_0 = repmat(theta,length(Roots),1);

% r_Save = r_0(1,:)/r_0(1,1)*Norm;
%%
rCorr = r_0(1,:); thetaCorr = theta_0(1,:);
rPill = c./(2*pi*3e9)*F_besselzero(0,1);
rPill = 38.247509278403*2.99961/3*3.00046/3*3.023484*3.000126/3/3/1000;
yMult = 1000; LW = 2.5; TFS = 8; LS = 12; TS = 12; MS = 10;

figure();  hold all
% subplot(1,2,1); hold all
subplot(1,6,[1 3]); hold all
plot(rPill.*cos(thetaCorr)*yMult,rPill.*sin(thetaCorr)*yMult,'k','linewidth',LW,'DisplayName','Circular pillbox')
plot(rCorr.*cos(thetaCorr)*yMult,rCorr.*sin(thetaCorr)*yMult,'r--','linewidth',LW,'DisplayName','Multipole-free')
% plot(rTemp.*cos(thetaCorr)*yMult,rTemp.*sin(thetaCorr)*yMult,'b--','linewidth',LW,'DisplayName','Iteration 4')
set(gca,'xlim',[-50 50])
axis equal; box on
set(gca,'FontSize',TS)
legend('show','FontSize',LS,'interpreter','latex')
xlabel('$x$ [mm]','Fontweight','demi','FontSize',LS,'Interpreter','latex'); 
ylabel('$y$ [mm]','Fontweight','demi','FontSize',LS,'Interpreter','latex');
plot(xlim,[0 0],'k','handlevisibility','off')
plot([0 0],ylim,'k','handlevisibility','off')
grid on; box on;

% subplot(1,3,3); hold all
% subplot(1,2,2); hold all
subplot(1,6,[5 6]); hold all
L = length(rCorr);
rTemp = rCorr;
% xTemp = rCorr.*cos(thetaCorr+pi/2);
% yTemp = rCorr.*sin(thetaCorr+pi/2);
% rTemp = sqrt(xTemp.^2+yTemp.^2);
% rTemp(1:(L-1)/4+1) = rCorr(3*(L-1)/4+1:end);
% rTemp((L-1)/4+1:end) = rCorr(1:3*(L-1)/4+1);
plot((thetaCorr)*180/pi,(rTemp-rPill)*1e3,'b','linewidth',2)
plot(xlim,[0 0],'k','handlevisibility','off')
set(gca,'xlim',[0 360])
xticks([0 180 360])
xticklabels({'0','180','360'})
set(gca,'FontSize',TS)
xlabel('$\theta$ [deg]','Fontweight','demi','FontSize',LS,'Interpreter','latex');
ylabel('${\Delta}r_0$ [mm]','Fontweight','demi','FontSize',LS,'Interpreter','latex');
box on; grid on;

set(gcf,'color','w');
Save = 0;
if Save == true
    SaveFolder = pwd;
    Save_Str = 'Iteration 4 mm';
    exportgraphics(gcf,[SaveFolder Save_Str '.png'],'Resolution',300)
    saveas(gcf,[SaveFolder Save_Str '.fig'])
end

%% Save to .txt (Single - TXT)
Saver = 0;
if Saver == true
    %r_Save = r_0(1,:)*0.03668402/r_0(1,1); theta_Save = theta_0(1,:);
    r_Save = r_0(2,:); theta_Save = theta_0(1,:);
    ScaleFactor = 1000; % Puts into mm
    SaveFolder = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\';
    SaveName = ['TM410_L'];
    MatrixToSave = ScaleFactor*[(r_Save.*cos(theta_Save)); (r_Save.*sin(theta_Save))];
    fileID = fopen([SaveFolder SaveName '.txt'],'w');
    %fileID = fopen(['40cmCirc.txt'],'w');
    fprintf(fileID,'%8.5f, %8.5f\n',MatrixToSave);
    fclose(fileID);
end