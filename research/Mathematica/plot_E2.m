%%

clear all
close all;
c = physconst('lightspeed');

f = 3e9; XLim = 100; FS = 24; FigNo = 101;
folder = 'Data/E_m_13'; a_val = 5; m = 13; a_str = num2str(a_val/1); CSTFile = 'Data/CSTFile_5mm/Mode 1_e.txt';
folder = 'Data/E_m_0_1_2'; a_val = 10; m = 16; a_str = num2str(a_val/1); CSTFile = 'Data/CSTFile_10mm_2/Mode 1_e.txt';

files = dir(folder);
colourmap = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250;...
    0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880; 0.3010 0.7450 0.9330; 0.6350 0.0780 0.1840];


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
%%
TimeArray = cos(2*pi*f/c*zplot);
colourcount = 1;
for ii = 1:2:count-1
    %for ii = [1 6 11]
    FName = fullfile(folder,Name_Ez{sort_bool(ii)});
    Ez = load(FName);
    rpos = strfind(FName,'_r_');
    rleg = num2str(str2num(FName(rpos+3:end-4)),'%.0f');
    rleg2 = ['a/' num2str(a_val/str2num(FName(rpos+3:end-4)),'%.0f')];
    if strcmp(rleg2,'a/1')
        rleg2 = 'a';
    elseif strcmp(rleg2,'a/Inf')
        rleg2 = '0';
    end
    Ezplot = Ez.Expression1;
    figure(FigNo);  hold all;
    % plot(zplot*1000,Ezplot,'linewidth',2,'DisplayName',['$' rleg '$'])
    plot(zplot*1000,Ezplot,'linewidth',2,'DisplayName',['$r~=~' rleg '$ mm'],'Color',colourmap(colourcount,:))
    figure(FigNo+1); hold all;
    % plot(zplot*1000,Ezplot.*TimeArray,'linewidth',2,'DisplayName',['$' rleg '$'])
    plot(zplot*1000,Ezplot.*TimeArray,'linewidth',2,'DisplayName',['$r~=~' rleg '$ mm'],'Color',colourmap(colourcount,:))
    Trapz(colourcount) = trapz(zplot*1000,Ezplot.*TimeArray);
    colourcount = colourcount + 1;
    rleg
end


figure(FigNo);
xlabel('$z$ [mm]','interpreter','latex')
ylabel('$Ez(r, 0, z, t=0)$ [V/m]','interpreter','latex'); xlim([-XLim XLim])
box on; grid on;
set(gcf,'Color','w')
%legend('show','location','northoutside','interpreter','latex','orientation','horizontal','NumColumns',3)
set(gca,'FontSize',FS)
pos = get(gcf,'position');
% title(name,'interpreter','none')
% set(gcf,'position',[pos(1),pos(2),pos(3)/2,pos(4)])

% saveas(gcf,fullfile('pngs',[SaveName '.png']))
ax = gca;
ax.LineWidth = 1.5;
ax.GridLineWidth = 1;

figure(FigNo+1);
xlabel('$z$ [mm]','interpreter','latex')
ylabel('$Ez(r, 0, z, t =z /c)$ [V/m]','interpreter','latex'); xlim([-XLim XLim])
box on; grid on;
set(gcf,'Color','w')
%legend('show','location','northeast','interpreter','latex')
set(gca,'FontSize',FS)
pos = get(gcf,'position');
% set(gcf,'position',[pos(1),pos(2),pos(3)/2,pos(4)])

% saveas(gcf,fullfile('pngs',[SaveName '_t.png']))
ax = gca;
ax.LineWidth = 1.5;
ax.GridLineWidth = 1;



%%
NoLPoints = 100; % 1000
NoLPoints = 500; % 1000
NoLPoints = 1000; % 1000
NoCirclePoints = 360;%60;
RPoints = 10; R_arr = linspace(1,10,10);


% loop through on-axis
fid = fopen(CSTFile);
header = fgetl(fid);
fgetl(fid);
Ez_on = ones(1,NoLPoints); count = 1;
for ii = 1:NoLPoints+1
    line = fgetl(fid);
    Ez_on(ii) = str2num(line(17*7+1:17*8));
    x_0_test(ii) = str2num(line(17*0+1:17*1));
    y_0_test(ii) = str2num(line(17*1+1:17*2));
    z_0_test(ii) = str2num(line(17*2+1:17*3));
    count = count+1;
end

% loop through the curves
x_R_test = ones(RPoints,NoCirclePoints,NoLPoints);y_R_test = ones(size(x_R_test));z_R_test = ones(size(x_R_test));
Ez_R = ones(size(x_R_test));
for jj = 1:NoLPoints+1
    for kk = 1:NoCirclePoints
        for ii = 1:RPoints
            line = fgetl(fid);
            Ez_R(ii,kk,jj) = str2num(line(17*7+1:17*8));
            x_R_test(ii,kk,jj) = str2num(line(17*0+1:17*1));
            y_R_test(ii,kk,jj) = str2num(line(17*1+1:17*2));
            z_R_test(ii,kk,jj) = str2num(line(17*2+1:17*3));
        end
    end
    jj
end

E0_Factor = 1e6/max(abs(Ez_on));
E0_Factor = 1;
Ez_R_Norm = E0_Factor*Ez_R; %NOTE NOTE NOTE NOTE THIS NORMALISATION FACTOR
Ez_on = Ez_on*E0_Factor;
BoreNorm = 3.9376e+07;%4.3405e7*1.00216651;
BoreNorm = -3.9376e+07; % FILL

figure(FigNo); hold all;
count = 1;
plot(flip(z_0_test-z_0_test(1)),Ez_on/BoreNorm,'--','linewidth',2,'handlevisibility','off','Color',colourmap(count,:))
r_arr = 0;
for ii = 2:2:10
    count = count+1;
    R_val = R_arr(ii)/1e3
    r_arr = [r_arr R_val*1e3];
    jj = 1;
    Ez_line = squeeze(Ez_R_Norm(ii,jj,:));
       
    figure(FigNo); hold all;
    plot(flip(z_0_test-z_0_test(1)),Ez_line/BoreNorm,'--','linewidth',2,'handlevisibility','off','Color',colourmap(count,:))
    xlim([0 50])
end

figure(FigNo+1); hold all;
count = 1;
t_arr = cos(2*pi*3e9*z_0_test/1e3/c);
plot(flip(z_0_test-z_0_test(1)),Ez_on.*t_arr/BoreNorm,'--','linewidth',2,'handlevisibility','off','Color',colourmap(count,:))
Trapz_CST(count) = 2*trapz(z_0_test-z_0_test(1),Ez_on.*t_arr/BoreNorm);
for ii = 2:2:10
    count = count+1;
    R_val = R_arr(ii)/1e3;
    jj = 1;
    Ez_line = squeeze(Ez_R_Norm(ii,jj,:));
       
    figure(FigNo+1); hold all;
    plot(flip(z_0_test-z_0_test(1)),Ez_line'.*t_arr/BoreNorm,'--','linewidth',2,'handlevisibility','off','Color',colourmap(count,:))
    xlim([0 50])
    Trapz_CST(count) = 2*trapz(z_0_test,Ez_line'.*t_arr/BoreNorm);
end

%%

f = 3e9;
k_freq = 2*pi*f/physconst('lightspeed');
g = physconst('lightspeed')/f/2;
%PzTFormula = g*sin(k_freq*g/2)/(k_freq*g/2)*((r_arr/5).^0+0.1605*(r_arr/5).^1+0.0125*(r_arr/5).^2)*1000
PzTFormula = g*sin(k_freq*g/2)/(k_freq*g/2)*((r_arr/a_val).^0+0.3464*(r_arr/a_val).^1+0.0546*(r_arr/a_val).^2)*1000
%%
ylim([-0.5 2.5])
%%

exportgraphics(gcf, [pwd '/figure/myPlot2.png'], 'Resolution', 300);
