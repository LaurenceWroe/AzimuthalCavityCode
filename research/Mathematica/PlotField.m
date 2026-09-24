
m = 0; a = 19;
folder = ['Data/m_' num2str(m) '_a_' num2str(a)];
files = dir(folder);

for ii = 1:length(files)
    Files{ii} = files(ii).name;
end

g_Bool = find(contains(Files,'g'));
k_Bool = find(contains(Files,'k'));


g = load(fullfile(folder,files(g_Bool).name));
k = load(fullfile(folder,files(k_Bool).name));
figure(1); hold all;
plot(k,g,'linewidth',2)

z_Bool = find(contains(Files,'Z'));
z = load(fullfile(folder,files(z_Bool).name));
Ez_Bool = find(contains(Files,'Ez'));
figure(2); hold all;
for ii = 1:length(Ez_Bool)
    Ez = load(fullfile(folder,files(Ez_Bool(ii)).name));
    plot(z,Ez)
end


x_offsets_Bool = find(contains(Files,'Offsets'));
PxTime_Bool = find(contains(Files,'PxTime'));
PzStatic_Bool = find(contains(Files,'PzStat'));
PzTime_Bool = find(contains(Files,'PzTime'));


