clear all; close all;

m = 1;
folder = ['Data/k_m_' num2str(m)];
files = dir(folder);
FS = 32; 
if m == 0
    yName = '$g_0$ [V]'; xUpper = 600; yLower = -0.005; yUpper = 0.04;
    a_val = 38.3;
elseif m == 1
    yName = '$g_1$ [V]'; xUpper = 300; yLower = -0.05; yUpper = 0.5;
    a_val = 60.9;
elseif m == 2
    yName = '$g_2$ [V]'; xUpper = 300; yLower = -0.5; yUpper = 2;
    a_val = 81.7;
end


for ii = 1:length(files)
    Files{ii} = files(ii).name;
end

g_Bool = find(contains(Files,'g'));
k_Bool = find(contains(Files,'k'));

for ii = 1:length(k_Bool)
    Name_k{ii} = Files{k_Bool(ii)};
    Name_g{ii} = Files{g_Bool(ii)};
    temp = strfind(Name_k{ii},'_a_');
    k_r(ii) = str2num(Name_k{ii}(temp+3:end-4));
end


[r,sort_bool] = sort(k_r);
figure(1);  hold all
for ii = 1:1:length(k_Bool)
    
    k = load(fullfile(folder,Name_k{sort_bool(ii)}));
    g = load(fullfile(folder,Name_g{sort_bool(ii)}));
    try
        kplot = k.Expression1; gplot = real(g.Expression1);
    catch
        kplot = k; gplot = g;
    end
    rleg = ['$' num2str(r(ii)/a_val*10,'%.0f') 'R/10$'];
    if strcmp(rleg,'$1R/10$')
        rleg = '$R/10$';
    end
    % plot(kplot(gplot~=0),gplot(gplot~=0),'linewidth',2,'DisplayName',['$' num2str(r(ii)) '$'])
    gplot(10001) = NaN;gplot(10000) = NaN;gplot(10002) = NaN;gplot(10003) = NaN;
    gplot(10001) = NaN; gplot(9999) = NaN;
    plot(kplot,gplot,'linewidth',2,'DisplayName',['$' rleg '$'])
    % plot(kplot(gplot>-1e9),gplot(gplot>-1e9),'linewidth',2,'DisplayName',['$' rleg '$'])
end
% k_lin = linspace(0,300,201); plot(kx,0.02*besselj(0,k_lin*0.038),'k--')
xlabel('$k$ [1/m]','interpreter','latex')
ylabel(yName,'interpreter','latex');  ylim([yLower,yUpper])
xlim([0,xUpper]);
box on; grid on;
set(gcf,'Color','w')
legend('show','location','northeast','interpreter','latex')
set(gca,'FontSize',FS)
saveas(gcf,fullfile('pngs',['g_m_' num2str(m) '.png']))



