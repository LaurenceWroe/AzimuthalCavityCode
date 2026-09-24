%%

clear all

folder = ['Data/P_m_0'];
m=2;
SubNo = 5;
files = dir(folder);

for ii = 1:length(files)
    Files{ii} = files(ii).name;
end

x_offsets_Bool = find(contains(Files,'Offsets'));
PxTime_Bool = find(contains(Files,'PxTime'));
PzStatic_Bool = find(contains(Files,'PzStat'));
PzTime_Bool = find(contains(Files,'PzTime'));

for ii = 1:length(x_offsets_Bool)
    Name_x{ii} = Files{x_offsets_Bool(ii)};
    Name_PxT{ii} = Files{PxTime_Bool(ii)};
    Name_PzT{ii} = Files{PzTime_Bool(ii)};
    temp = strfind(Name_x{ii},'_a_');
    x_a(ii) = str2num(Name_x{ii}(temp+3:end-4));
end
[a,sort_bool] = sort(x_a);

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

    % figure(3); hold all;
    % poly_x = [xplot.^(m-1)]\PzTplot
    % plot(a(ii),poly_x,'x')
    % % plot(a(ii),PxTplot(1),'x')

    figure(2); subplot(3,2,SubNo); hold all;
    plot(xplot*1000,PzTplot,'linewidth',2,'DisplayName',num2str(a(ii),'%.2f'))
    % plot(xplot/xplot(end),PzTplot,'linewidth',2,'DisplayName',num2str(a(ii),'%.2f'))
    % plot(xplot*1000,PzTplot/PzTplot(1),'linewidth',2,'DisplayName',num2str(a(ii),'%.2f'))

    subplot(3,2,SubNo+1); hold all;
    plot(xplot*1000,PxTplot,'-','linewidth',2,'DisplayName',num2str(a(ii),'%.2f'))
    % plot(xplot/xplot(end),PxTplot,'-','linewidth',2,'DisplayName',num2str(a(ii),'%.2f'))
    % plot(xplot*1000,PxTplot/PxTplot(1),'-','linewidth',2,'DisplayName',num2str(a(ii),'%.2f'))

    

end
xlabel('$x$ [mm]','interpreter','latex')
ylabel('$\Delta p_x$ [eV/c]','interpreter','latex'); 
box on; grid on;
set(gcf,'Color','w')
legend('show','location','NorthEast','interpreter','latex')
set(gca,'FontSize',15)

subplot(3,2,SubNo);
xlabel('$x$ [mm]','interpreter','latex')
ylabel('$\Delta p_z$ [eV/c]','interpreter','latex'); 
box on; grid on;
set(gcf,'Color','w')
% legend('show','location','northeast','interpreter','latex')
set(gca,'FontSize',15)

%saveas(gcf,fullfile('pngs','P_m_0_1_2_vert.png'))


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
