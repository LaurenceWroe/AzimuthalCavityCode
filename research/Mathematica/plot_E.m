%%

clear all
% close all;
c = physconst('lightspeed');

f = 3e9; XLim = 100; FS = 32; FigNo = 101;

folder = 'Data/E_m_12'; 
% folder = ['Data/E_m_1_a_30_1.5G'];
a_val = 38.3; m = 0;
folder = ['Data/E_m_' num2str(m) '_test']; a_str = num2str(a_val/2);
% name = 'E_m_0_test';
% folder = ['Data/240706_ConvergenceTest/' name];
files = dir(folder);

SaveName = ['Ez_m_' num2str(m)];

for ii = 1:length(files)
    Files{ii} = files(ii).name;
end



z_Bool = find(contains(Files,['Z_m_' num2str(m) '_a_' a_str]));
z = load(fullfile(folder,files(z_Bool).name));
zplot = z.Expression1;
Ez_Bool = find(contains(Files,['Ez_m_' num2str(m) '_a_' a_str])); 


for ii = 1:length(Ez_Bool)
    Name_Ez{ii} = Files{Ez_Bool(ii)};
    temp = strfind(Name_Ez{ii},'_r_');
    Ez_r(ii) = str2num(Name_Ez{ii}(temp+3:end-4));
end
[r_temp,sort_bool_temp] = sort(Ez_r);

count = 1;
for jj = 1:length(r_temp)%[1 7 12] 
    sort_bool(count) = sort_bool_temp(jj);
    r(count) = r_temp(jj);
    count = count + 1;
end

TimeArray = cos(2*pi*f/c*zplot);

 for ii = 1:count-1
%for ii = [1 6 11]
    FName = fullfile(folder,Name_Ez{sort_bool(ii)});
    Ez = load(FName);
    rpos = strfind(FName,'_r_');
    rleg = num2str(str2num(FName(rpos+3:end-4)),'%.1f');
    rleg2 = ['a/' num2str(a_val/str2num(FName(rpos+3:end-4)),'%.0f')];
    if strcmp(rleg2,'a/1')
        rleg2 = 'a';
    elseif strcmp(rleg2,'a/Inf')
        rleg2 = '0';
    end
    Ezplot = Ez.Expression1;
    figure(FigNo);  hold all;
    % plot(zplot*1000,Ezplot,'linewidth',2,'DisplayName',['$' rleg '$'])
    plot(zplot*1000,Ezplot,'linewidth',2,'DisplayName',['$' rleg2 '$'])
    figure(FigNo+1); hold all;
    % plot(zplot*1000,Ezplot.*TimeArray,'linewidth',2,'DisplayName',['$' rleg '$'])
    plot(zplot*1000,Ezplot.*TimeArray,'linewidth',2,'DisplayName',['$' rleg2 '$'])
end

figure(FigNo);
xlabel('$z$ [mm]','interpreter','latex')
ylabel('$Ez$ [V/m]','interpreter','latex'); xlim([-XLim XLim])
box on; grid on;
set(gcf,'Color','w')
legend('show','location','northeast','interpreter','latex')
set(gca,'FontSize',FS)
pos = get(gcf,'position');
% title(name,'interpreter','none')
% set(gcf,'position',[pos(1),pos(2),pos(3)/2,pos(4)])

% saveas(gcf,fullfile('pngs',[SaveName '.png']))

figure(FigNo+1);
xlabel('$z$ [mm]','interpreter','latex')
ylabel('$Ez$ [V/m]','interpreter','latex'); xlim([-XLim XLim])
box on; grid on;
set(gcf,'Color','w')
legend('show','location','northeast','interpreter','latex')
set(gca,'FontSize',FS)
pos = get(gcf,'position');
% set(gcf,'position',[pos(1),pos(2),pos(3)/2,pos(4)])

% saveas(gcf,fullfile('pngs',[SaveName '_t.png']))

