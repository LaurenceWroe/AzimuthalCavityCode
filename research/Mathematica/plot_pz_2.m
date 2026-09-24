%%

clear all; close all;
FigNo = 1;
m=2; a_val = 81.7;
%m=13; a_val = 5;
%m=1; a_val = 60.9;
%m=0; a_val = 38.3;
Saver = false;
SaveName = ['P_m_' num2str(m)];
folder = ['Data/' SaveName];
FS = 32; LW = 2;
files = dir(folder);
colourmap = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250;...
    0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880; 0.3010 0.7450 0.9330; 0.6350 0.0780 0.1840];

% Cavity parameters
f = 3e9;
k_freq = 2*pi*f/physconst('lightspeed');
g = physconst('lightspeed')/f/2;

for ii = 1:length(files)
    Files{ii} = files(ii).name;
end

x_offsets_Bool = find(contains(Files,'Offsets'));
PxTime_Bool = find(contains(Files,'PxTime'));
PzStatic_Bool = find(contains(Files,'PzStat'));
PzTime_Bool = find(contains(Files,'PzTime'));
PxStatic_Bool = find(contains(Files,'PxStat'));

for ii = 1:length(x_offsets_Bool)
    Name_x{ii} = Files{x_offsets_Bool(ii)};
    Name_PxT{ii} = Files{PxTime_Bool(ii)};
    Name_PxS{ii} = Files{PxStatic_Bool(ii)};
    Name_PzT{ii} = Files{PzTime_Bool(ii)};
    Name_PzS{ii} = Files{PzStatic_Bool(ii)};
    temp = strfind(Name_x{ii},'_a_');
    x_a(ii) = str2num(Name_x{ii}(temp+3:end-4));
end
[a,sort_bool] = sort(x_a);
count = 1;
for ii = 1:length(x_offsets_Bool)
    FNamex = fullfile(folder,Name_x{sort_bool(ii)});
    x = load(FNamex);
    xplot = x.Expression1;

    FNamePzT = fullfile(folder,Name_PzT{sort_bool(ii)});
    PzT = load(FNamePzT);
    PzTplot = PzT.Expression1;

    FNamePxT = fullfile(folder,Name_PxT{sort_bool(ii)});
    PxT = load(FNamePxT);
    PxTplot = PxT.Expression1;

    FNamePzS = fullfile(folder,Name_PzS{sort_bool(ii)});
    PzS = load(FNamePzS);
    PzSplot = PzS.Expression1;

    FNamePxS = fullfile(folder,Name_PxS{sort_bool(ii)});
    PxS = load(FNamePxS);
    PxSplot = PxS.Expression1;

    leg = a(ii);

    % figure(3); hold all;
    % poly_x = [xplot.^(m-1)]\PzTplot
    % plot(a(ii),poly_x,'x')
    % % plot(a(ii),PxTplot(1),'x')
    rleg = ['$' num2str(a(ii)/a_val*10,'%.0f') 'R/10$'];
    if strcmp(rleg,'$1R/10$')
        rleg = '$R/10$';
    end

    PzTFormula = g*1*sin(k_freq*g/2)/(k_freq*g/2)*(xplot/(leg/1000)).^m;

    

    figure(FigNo); hold all;
    plot(xplot*1000,PzTplot,'linewidth',LW,'DisplayName',rleg,'Color',colourmap(ii,:))
    plot(xplot*1000,PzTFormula,'linewidth',LW,'DisplayName',rleg,'Color','k')
    poly_PzT(count) = xplot.^(m)\PzTplot;
    plot(xplot*1000,poly_PzT(count)*xplot.^(m),'--','linewidth',LW*2,'Color',colourmap(ii,:),'HandleVisibility','off')
    % plot(xplot/xplot(end),PzTplot,'linewidth',2,'DisplayName',num2str(a(ii),'%.2f'))
    % plot(xplot*1000,PzTplot/PzTplot(1),'linewidth',2,'DisplayName',num2str(a(ii),'%.2f'))

    figure(FigNo+1); hold all;
    plot(xplot*1000,PxTplot,'-','linewidth',LW,'DisplayName',rleg,'Color',colourmap(ii,:))
    poly_PxT(count) = xplot.^(m-1)\PxTplot;
    plot(xplot*1000,poly_PxT(count)*xplot.^(m-1),'--','linewidth',LW*2,'Color',colourmap(ii,:),'HandleVisibility','off')
    % plot(xplot/xplot(end),PxTplot,'-','linewidth',2,'DisplayName',num2str(a(ii),'%.2f'))
    % plot(xplot*1000,PxTplot/PxTplot(1),'-','linewidth',2,'DisplayName',num2str(a(ii),'%.2f'))

    

    figure(FigNo+2); hold all;
    plot(xplot*1000,PzSplot,'-','linewidth',LW,'DisplayName',rleg,'Color',colourmap(ii,:))

    fitfun = fittype( @(A,k,x) A*besselj(m,k*x) );
    x0 = [1,63];
    [fitted_curve,gof] = fit(xplot,PzSplot,fitfun,'StartPoint',x0);
    A(count) = fitted_curve.A; k(count) = fitted_curve.k;
    plot(xplot*1000,A(count)*besselj(m,k(count)*xplot),'--','linewidth',LW*2,'Color',colourmap(ii,:),'HandleVisibility','off')
    
    
    figure(FigNo+3); hold all;
    plot(xplot*1000,PxSplot,'-','linewidth',LW,'DisplayName',rleg,'Color',colourmap(ii,:))
    fitfun_x = fittype( @(A_x,k_x,x) A_x*(besselj(m-1,k_x*x)-besselj(m+1,k_x*x)));
    x0_x = [1,63];
    [fitted_curve_x,gof_x] = fit(xplot,PxSplot,fitfun_x,'StartPoint',x0_x);
    A_x(count) = fitted_curve_x.A_x; k_x(count) = fitted_curve_x.k_x;
    % plot(xplot*1000,A_x(count)*(besselj(m-1,k_x(count)*xplot)-besselj(m+1,k_x(count)*xplot)),'--','linewidth',LW*2,'Color',colourmap(ii,:),'HandleVisibility','off')
    % plot(xplot*1000,PxSplot(1)*(besselj(m-1,k_freq*xplot)-besselj(m+1,k_freq*xplot)),'--','linewidth',LW*2,'Color',colourmap(ii,:),'HandleVisibility','off')
    plot(xplot*1000,(besselj(m-1,k_freq*xplot)-besselj(m+1,k_freq*xplot))*PxSplot(20)/(besselj(m-1,k_freq*xplot(20))-besselj(m+1,k_freq*xplot(20))),'--','linewidth',LW*2,'Color',colourmap(ii,:),'HandleVisibility','off')
    count = count + 1;

end
figure(FigNo+1);
xlabel('$r$ [mm]','interpreter','latex')
ylabel('$\Delta p_r(r, 0)$ [eV/c]','interpreter','latex'); 
box on; grid on;
set(gcf,'Color','w')
legend('show','location','NorthEast','interpreter','latex')
set(gca,'FontSize',FS)

if Saver == true
    saveas(gcf,fullfile('pngs',[SaveName '_x_t.png']))
end

figure(FigNo+3);
xlabel('$r$ [mm]','interpreter','latex')
ylabel('$\Delta p_r(r, 0)$ [eV/c]','interpreter','latex'); 
box on; grid on;
set(gcf,'Color','w')
% legend('show','location','NorthEast','interpreter','latex')
set(gca,'FontSize',FS)

if Saver == true
    saveas(gcf,fullfile('pngs',[SaveName '_x_s.png']))
end

figure(FigNo);
xlabel('$r$ [mm]','interpreter','latex')
ylabel('$\Delta p_z(r, 0)$ [eV/c]','interpreter','latex'); 
if m == 0
    ax = get(gca); ax.YAxis.TickLabelFormat = '%.4f';ax.YAxis.Exponent = -2;
end
box on; grid on;
set(gcf,'Color','w')
set(gca,'FontSize',FS)

if Saver == true
    saveas(gcf,fullfile('pngs',[SaveName '_z_t.png']))
end

figure(FigNo+2);
xlabel('$r$ [mm]','interpreter','latex')
ylabel('$\Delta p_z(r, 0)$ [eV/c]','interpreter','latex'); 
box on; grid on;
set(gcf,'Color','w')
set(gca,'FontSize',FS)

if Saver == true
    saveas(gcf,fullfile('pngs',[SaveName '_z_s.png']))
end


%%

% 
% 
% x_offsets = load(fullfile(folder,files(x_offsets_Bool).name));
% PxTime = load(fullfile(folder,files(PxTime_Bool).name));
% PzStatic = load(fullfile(folder,files(PzStatic_Bool).name));
% PzTime = load(fullfile(folder,files(PzTime_Bool).name));
% 
% xplot = x_offsets.Expression1;
% PzTplot = PzTime.Expression1;
% PxTplot = PxTime.Expression1;
% 
% figure(1); subplot(2,2,1); hold all;
% plot(xplot,PzTplot,'-','linewidth',2,'DisplayName','t')
% xlabel('$x$ [mm]','interpreter','latex')
% ylabel('$\Delta p_z$ [eV/c]','interpreter','latex'); 
% box on; grid on;
% set(gcf,'Color','w')
% legend('show','location','northeast','interpreter','latex')
% set(gca,'FontSize',16)
% 
% subplot(2,2,3); hold all;
% plot(xplot,PxTplot,'-','linewidth',2,'DisplayName','t')
% xlabel('$x$ [mm]','interpreter','latex')
% ylabel('$\Delta p_x$ [eV/c]','interpreter','latex'); 
% box on; grid on;
% set(gcf,'Color','w')
% legend('show','location','northeast','interpreter','latex')
% set(gca,'FontSize',16)
