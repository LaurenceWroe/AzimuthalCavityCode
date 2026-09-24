
m = 4; a = 85;
folder = ['Data/m_' num2str(m) '_a_' num2str(a)];
files = dir(folder);
x_offsets = load(fullfile(folder,files(3).name));
PxTime = load(fullfile(folder,files(4).name));
PzStatic = load(fullfile(folder,files(5).name));
PzTime = load(fullfile(folder,files(6).name));



figure(); hold all;
plot(x_offsets,PzTime,'x-')
poly_z = [x_offsets.^m]\PzTime
plot(x_offsets,poly_z*x_offsets.^m)

figure(); hold all;
plot(x_offsets,PxTime,'x-')
poly_x = [x_offsets.^(m-1)]\PxTime
plot(x_offsets,poly_x*x_offsets.^(m-1))