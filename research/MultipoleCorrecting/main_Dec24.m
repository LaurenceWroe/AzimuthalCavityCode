
% Preamble
clear; close all; clc;
c = physconst('lightspeed');

%%% Specified parameters

% FILE
CSTFile = 'T059';

% CHOOSE SOLVER
eigenbool = 1;
HTCondorBool = 1;
pipe_circ_bool = 1; Pipe_SF = 0.1;

% FREQUENCIES
f_upper = 3.005;
f_lower = 2.995;
f_monitor = 3;

% f_upper = 1.305;
% f_lower = 1.295;
% f_monitor = 1.3;

% CAVITY DIMENSIONS
x_wg = 72.136;
z_wg = 1000*c/2/f_monitor/1e9;%50;%34.036;
L_wg = 100;
r_blend = 10;
r_coupcav = 6;
r_pipe = 50;
MeshBomb_PipeFactor = 1.2; % how much the mesh bomb extends into the cavity

% COUPLER DEPENDENT FACTORS
% g_0=g_1=g_2
%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\QuadDip.txt'; freq_ratio = 3.00102/3; x_coup = 15; % 5 mm beam pipe
shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\QuadDip.txt'; freq_ratio = 3.0001211/3*3.00602/3*3.00102/3; x_coup = 15;

%simple pill
%x_coup = 15;% Need to store something
%with coupler
bess_bool = true; % true = build shape
CouplerBool = 0;
% SINGLE PORT
freq_ratio = 3.01095/3; x_coup = 15.645; % with beampipe % ITERATION 0 (Perfect cylinder PILLBOX)
shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\MonoOnly.txt'; freq_ratio = 3.0003229/3*2.99964/3*2.99981/3*3.01095/3; x_coup = 15.645; % with beampipe % ITERATION 0 (Solved for PILLBOX)
%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\IterationFeb1.txt'; freq_ratio = 3.0002482/3*2.99835/3*3.01/3; x_coup = 16.399; % with beampipe % ITERATION 1 - Feb 2025

%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\IterationOct_Feb1.txt'; freq_ratio = 2.99827/3*3.0002482/3*2.99835/3*3.01/3; x_coup = 16.578; % with beampipe % ITERATION OCT 1 - Feb 2025
%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\IterationOct_Feb2.txt'; freq_ratio = 2.99894/3*2.99827/3*3.0002482/3*2.99835/3*3.01/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\IterationOct_Feb3.txt'; freq_ratio = 2.99894/3*2.99827/3*3.0002482/3*2.99835/3*3.01/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\IterationOct_Feb4.txt'; freq_ratio = 3.0001440/3*2.99894/3*2.99827/3*3.0002482/3*2.99835/3*3.01/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\IterationOct_Feb5.txt'; freq_ratio = 2.9996228/3*3.0001440/3*2.99894/3*2.99827/3*3.0002482/3*2.99835/3*3.01/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\IterationOct_Feb6.txt'; freq_ratio = 2.9999333/3*2.9996228/3*3.0001440/3*2.99894/3*2.99827/3*3.0002482/3*2.99835/3*3.01/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\IterationOct_Feb10.txt'; freq_ratio = 2.9999333/3*2.9996228/3*3.0001440/3*2.99894/3*2.99827/3*3.0002482/3*2.99835/3*3.01/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
LocalMeshSize = 1.8; %TM410 = 3.5, 4 = default, 2 azifinal , 2.9 for quad, 2.5 dip, 2.3 for mono coupler (1.8)
MeshFactor = 1;

shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM4610_6.7.txt'; freq_ratio = 2.99971/3*2.98826/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
%LocalMeshSize = 4; 
%MeshFactor = 2;

shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM4610_6.3.txt'; freq_ratio = 2.99971/3*2.98826/3*3.0117/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
LocalMeshSize = 8; MeshFactor = 5;
LocalMeshSize = 3.3; MeshFactor = 1.6;

CSTFile = 'T003';
shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM4610_5.7.txt'; freq_ratio = 2.99971/3*2.98826/3*3.0117/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
LocalMeshSize = 8; MeshFactor = 5;
LocalMeshSize = 3.3; MeshFactor = 1.6;

CSTFile = 'T010';
shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM46810_Good.txt'; freq_ratio = 2.99971/3*2.98826/3*3.0117/3*2.9995/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
LocalMeshSize = 8; MeshFactor = 5;
LocalMeshSize = 4.3; MeshFactor = 2.6;



%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM46810.txt'; freq_ratio = 2.99971/3*2.98826/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM610.txt'; freq_ratio = 2.99971/3*2.98826/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM810.txt'; freq_ratio = 2.99971/3*2.98826/3*3.01187/3; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
%LocalMeshSize = 3.3; MeshFactor = 1.6;

%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM_24610_-7_7.txt';  x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
%r_pipe = 50; LocalMeshSize = 4; MeshFactor = 2; freq_ratio = 3.01174/3*2.99971/3*2.98826/3; % 50 mm pipe
%LocalMeshSize = 8; MeshFactor = 5;

% shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM4610.txt'; freq_ratio = 1; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025

%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM04610_6.7.txt';  x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025
%r_pipe = 10;LocalMeshSize = 1.7; MeshFactor = 0.6; freq_ratio = 3.02417/3; % 10 mm pipe
%r_pipe = 20;LocalMeshSize = 2.3; MeshFactor =0.9; freq_ratio = 3.14/3; % 20 mm pipe
%r_pipe = 30; LocalMeshSize = 2.6; MeshFactor =1.1; freq_ratio = 3.264/3; % 30 mm pipe

%LocalMeshSize = 15; 
%MeshFactor = 10;

%shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM410.txt'; freq_ratio = 1; x_coup = 16.736; 
% LocalMeshSize = 7.5;4.2; %TM410 = 3.5, 4 = default, 2 azifinal , 2.9 for quad, 2.5 dip, 2.3 for mono coupler (1.8)
% MeshFactor = 3.5;1.7; %TM410 = 1.7,  3=default% 1 azifinal, 1.9 for quad, 1.5 dip, 1.3 for mono coupler (1) % default is 10. With no meshbomb = 50 k, meshfactor = 2 = 850k, 3 = 250 k

% shape_file = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\TM410_L.txt'; freq_ratio = 1; x_coup = 16.736; % with beampipe % ITERATION OCT 1 - Feb 2025


%freq_ratio = 2.99993/3*2.99826/3*2.99835/3*3.01/3; x_coup = 16.525; % with beampipe % ITERATION 2
%freq_ratio = 2.99984/3*2.99993/3*2.99826/3*2.99835/3*3.01/3; x_coup = 16.5575; % with beampipe % ITERATION 3

%freq_ratio = 2.99835/3*3.01/3; x_coup = 16.399; % with beampipe % ITERATION 1 
%freq_ratio = 2.99993/3*2.99826/3*2.99835/3*3.01/3; x_coup = 16.525; % with beampipe % ITERATION 2
%freq_ratio = 2.99984/3*2.99993/3*2.99826/3*2.99835/3*3.01/3; x_coup = 16.5575; % with beampipe % ITERATION 3

% NPORT
XSymBool = 2; % Make this 1 to have x symmetry and make it 2 to have y symmetry
NPort = 1;  % Make 1 to just have 1 port, 2 to have 2 ports and 3 to have 3 ports
%NPort = 2; freq_ratio = 2.99154/3*3.0024/3*3.0031/3*3.004/3; x_coup = 14.6; % TWO PORTS
%NPort = 4; freq_ratio = 2.99934/3*2.97142/3*3.01562/3; x_coup = 13.2; % FOUR PORTS

% MESH BOMB AND CYLINDER FACTORS
mesh_bool = 0; % set true to make the mesh bomb
mesh_discrete = 0; % set true to make the mesh bomb discrete
SymBool_z = 1;
PointsMakerBool = 1; % pointsmakerbool makes a .txt file of points
CurveMakerBool = 0; % curvemakerbool makes a series of circles REMEMBER, THERE IS NO LONGER OUTPUTTED POSITIONS!
NoLPoints = 1000; % 1000
NoCirclePoints = 60;%60;
ExpFactor = 0;
RPoints = 10;
Rmin = 1;
Rmax = r_pipe; % 9
%LocalMeshSize = 15; %TM410 = 3.5, 4 = default, 2 azifinal , 2.9 for quad, 2.5 dip, 2.3 for mono coupler (1.8)
%MeshFactor = 7; %TM410 = 1.7,  3=default% 1 azifinal, 1.9 for quad, 1.5 dip, 1.3 for mono coupler (1) % default is 10. With no meshbomb = 50 k, meshfactor = 2 = 850k, 3 = 250 k
%MeshFactor = 2.5; % pillbox: 5 = 20k cells, 3 = 60 k,

%% DERVIED PARAMETERS AND SETTINGS
%%% DERIVED PARAMETERS
freq_rf = 3e9; 
L_cav = z_wg;
L_pipe = 1*z_wg;%1*z_wg;
L_tot = 2*L_pipe+L_cav;
%16.24 = No beampipe;
r_cav = 38.2471*freq_ratio;

% PATHS ETC
Path = 'C:\Wroe\CST_Sims\Coupler';
FormatSpec = '%.4f';
freq_upper = num2str(f_upper);
freq_lower = num2str(f_lower);

if eigenbool == 1
    if HTCondorBool == 1
        TemplateFile = fullfile(pwd,'HTCondorTemplate2.cst'); % template for HT Condor eigenmode
        %TemplateFile = fullfile(pwd,'HTCondorTemplate4.cst'); % template for HT Condor eigenmode
        TemplateFile = fullfile(pwd,'HTCondorTemplate5.cst'); % template for HT Condor eigenmode + exports subvolume and circular field
    else
        TemplateFile = fullfile(pwd,'LocalEigenTemplate.cst'); % template for local eigenmode
    end
else
    TemplateFile = fullfile(pwd,'S11_OptimTemplate.cst'); % template for s11 optimising
end


%%

cst = actxserver('CSTStudio.application');
mws = cst.invoke('NewMWS'); % open a new cst template
invoke(mws, 'OpenFile', TemplateFile);
filename = [Path '\Playground\' CSTFile];
fullname = [filename '.cst'];
% if exist(fullname)
%     error('filename exists')
% end
invoke(mws,'SaveAs',fullname,'True');

InvokeQuit = true; % SET AS FALSE TO KEEP PROJECT OPEN

%%
invoke(mws,'StoreParameter','L_cav',L_cav);
invoke(mws,'StoreParameter','L_pipe',L_pipe);
invoke(mws,'StoreParameter','L_wg',L_wg);
invoke(mws,'StoreParameter','x_wg',x_wg);
invoke(mws,'StoreParameter','r_cav',r_cav);
invoke(mws,'StoreParameter','z_wg',z_wg);
invoke(mws,'StoreParameter','x_coup',x_coup);
invoke(mws,'StoreParameter','r_blend',r_blend);
invoke(mws,'StoreParameter','r_coupcav',r_coupcav);
invoke(mws,'StoreParameter','freq_lower',freq_lower);
invoke(mws,'StoreParameter','freq_upper',freq_upper);
invoke(mws,'StoreParameter','r_pipe',r_pipe);
invoke(mws,'StoreParameter','LocalMeshSize',LocalMeshSize);


%% use template eigenmode_3

clear sCommand ss;   %
ss{1} = 'With Units';
ss{2} = '     .Geometry "mm" ';
ss{3} = '     .Frequency "GHz" ';
ss{4} = '     .Voltage "V" ';
ss{5} = '     .Resistance "Ohm" ';
ss{6} = '     .Inductance "H" ';
ss{7} = '     .TemperatureUnit "Kelvin" ';
ss{8} = '     .Time "ns" ';
ss{9} = '     .Current "A" ';
ss{10} = '     .Conductance "Siemens" ';
ss{11} = '     .Capacitance "F" ';
ss{12} = 'End With ';

ss{13} = 'With MStaticSolver ';
ss{14} = '     .IgnorePECMaterial "True" ';
ss{15} = '     .Method "Hexahedral Mesh"';
ss{16} = 'End With ';

ss{17} = 'With Background ';
ss{18} = '     .Type "pec"';
ss{19} = 'End With ';

ss{20} = 'With Mesh ';
ss{21} = '     .MeshType "Tetrahedral" ';
ss{22} = '     .SetCreator "High Frequency"';
ss{23} = 'End With ';

ss{24} = 'With MeshSettings';
ss{25} = '     .SetMeshType "Tet"';
ss{26} = '     .Set "Version", 1%';
ss{27} = '     .Set "SrfMeshGradation", "1.5"';
ss{28} = '     .Set "UseSameSrfAndVolMeshGradation", "1"';
ss{29} = '     .Set "VolMeshGradation", "1.5"';
ss{30} = '     .Set "CurvatureOrderPolicy", "fixedorder"';
ss{31} = '     .Set "CurvatureOrder", "2"';
ss{32} = 'End With';

ss{33} = 'With Mesh ';
ss{34} = '     .LinesPerWavelength "15"';
ss{35} = '     .MinimumStepNumber "15"';
ss{36} = '     .PointAccEnhancement "50"';
ss{37} = 'End With';

ss{38} = 'With MeshSettings';
ss{39} = '     .SetMeshType "Hex"';
ss{40} = '     .Set "StepsPerWaveNear", "15"';
ss{41} = '     .Set "StepsPerBoxNear", "20"';
ss{42} = '     .Set "RatioLimitGeometry", "50"';
ss{43} = '     .Set "EquilibrateOn", "1"';
ss{44} = '     .Set "Equilibrate", "1.5"';
ss{45} = 'End With';

ss{46} = 'PICSolver.Global "LongitudinalEmittance", "True"';

ss{47} = 'Solver.AdaptivePortMeshing "False"';

ss{48} = 'With MeshSettings';
ss{49} = '     .SetMeshType "Tet"';
ss{50} = '     .Set "Version", 1%';
ss{51} = 'End With';

ss{52} = 'With Mesh';
ss{53} = '     .MeshType "Tetrahedral"';
ss{54} = 'End With';

ss{55} = 'ChangeSolverType("HF Eigenmode")';

sCommand = ss{1};
for kk=2:length(ss)
    if kk == 13 || kk == 1 || kk == 20 || kk == 24 || kk == 33 || kk == 38 ...
            || kk == 46 || kk == 47 || kk == 48 || kk == 52 || kk == 55|| kk == 56
        sCommand = [sCommand 10 10 ss{kk}];
    else
        sCommand = [sCommand 10 ss{kk}];
    end
end
invoke(mws,'AddToHistory','define template',sCommand);

%% define component1
invoke(mws,'AddToHistory','new component: component1','Component.New "component1"');

%% define pillbox
if bess_bool ~= true
    clear sCommand ss;   %
    ss{1} = 'With Cylinder';
    ss{2} = '     .Reset';
    ss{3} = '     .Name "solid1" ';
    ss{4} = '     .Component "component1" ';
    ss{5} = '     .Material "Vacuum"';
    ss{6} = '     .OuterRadius "r_cav" ';
    ss{7} = '     .InnerRadius "0.0" ';
    ss{8} = '     .Axis "z" ';
    ss{9} = '     .Zrange "-L_cav/2", "L_cav/2" ';
    ss{10} = '     .Xcenter "0" ';
    ss{11} = '     .Ycenter "0" ';
    ss{12} = '     .Segments "0" ';
    ss{13} = '     .Create ';
    ss{14} = 'End With';
    
    sCommand = ss{1};
    for kk=2:length(ss)
        sCommand = [sCommand 10 ss{kk}];
    end
    invoke(mws,'AddToHistory','define pillbox',sCommand);
else
    Shape_Pos_Load = readmatrix(shape_file);
    Shape_Pos = Shape_Pos_Load*freq_ratio;
    clear sCommand ss;   %
    ss{1} = 'With Spline';
	ss{2} = '     .Reset';
	ss{3} = '     .Name "BessShape"';
	ss{4} = '     .Curve "curve1"';
    ss{5} = ['     .Point "' num2str(Shape_Pos(1,1)) '", "' num2str(Shape_Pos(1,2)) '"'];
    ss{6} = '     .SetInterpolationType "PointInterpolation"';
    count = 1;
    for nn = 2:length(Shape_Pos)
        ss{6+count} = ['     .LineTo "' num2str(Shape_Pos(nn,1)) '", "' num2str(Shape_Pos(nn,2)) '"'];
        count = count + 1;
    end
    ss{6+count} = '     .Create';
    ss{7+count} = 'End With';
    sCommand = ss{1};
    for kk=2:length(ss)
        sCommand = [sCommand 10 ss{kk}];
    end
    invoke(mws,'AddToHistory','define bess curve',sCommand);

    clear sCommand ss;   %
    ss{1} = 'With CoverCurve';
	ss{2} = '     .Reset';
	ss{3} = '     .Name "TempFace"';
	ss{4} = '     .Component "component1"';
	ss{5} = '     .Material "Vacuum"';
	ss{6} = '     .Curve "curve1:BessShape"';
	ss{7} = '     .DeleteCurve "True"';
	ss{8} = '     .Create';
	ss{9} = 'End With';
    sCommand = ss{1};
    for kk=2:length(ss)
        sCommand = [sCommand 10 ss{kk}];
    end
    invoke(mws,'AddToHistory','cover Bess curve',sCommand);

    invoke(mws,'AddToHistory','pick face','Pick.PickFaceFromId "component1:TempFace", "1"');

    clear sCommand ss;   %
    ss{1} = 'With Extrude';
	ss{2} = '     .Reset';
	ss{3} = '     .Name "solid1"';
	ss{4} = '     .Component "component1"';
	ss{5} = '     .Material "Vacuum"';
	ss{6} = '     .Mode "Picks"';
	ss{7} = ['     .Height "' num2str(L_cav) '"'];
	ss{8} = '     .Twist "0.0"';
	ss{9} = '     .Taper "0.0"';
	ss{10} = '     .UsePicksForHeight "False"';
	ss{11} = '     .DeleteBaseFaceSolid "True"';
	ss{12} = '     .ClearPickedFace "True"';
	ss{13} = '     .Create';
	ss{14} = 'End With';
	
    sCommand = ss{1};
    for kk=2:length(ss)
        sCommand = [sCommand 10 ss{kk}];
    end
    invoke(mws,'AddToHistory','extrude Bess curve',sCommand);

    invoke(mws,'AddToHistory','delete curve','Curve.DeleteCurve "curve1"');

    clear sCommand ss;   %
    ss{1} = 'With Transform';
    ss{2} = '   .Reset';
    ss{3} = '   .Name "component1"'; 
    ss{4} = '   .Vector "0", "0", "-L_cav/2"'; 
    ss{5} = '   .UsePickedPoints "False"'; 
    ss{6} = '   .InvertPickedPoints "False"'; 
    ss{7} = '   .MultipleObjects "False"'; 
    ss{8} = '   .GroupObjects "False"'; 
    ss{9} = '   .Repetitions "1"'; 
    ss{10} = '   .MultipleSelection "False"'; 
    ss{11} = '   .Transform "Shape", "Translate"'; 
    ss{12} = 'End With';
    sCommand = ss{1};
    for kk=2:length(ss)
        sCommand = [sCommand 10 ss{kk}];
    end
    invoke(mws,'AddToHistory','Orientate Shape',sCommand);

end


%% Begin making pillbox
if CouplerBool == 1
    %% define connecting brick
    clear sCommand ss;
    ss{1} = 'With Brick';
    ss{2} = '     .Reset';
    ss{3} = '     .Name "solid2"';
    ss{4} = '     .Component "component1"';
    ss{5} = '     .Material "Vacuum"';
    ss{6} = '     .Xrange "-x_wg/2", "x_wg/2"';
    ss{7} = '     .Yrange "r_cav+r_coupcav", "r_cav+r_coupcav+L_wg"';
    ss{8} = '     .Zrange "-z_wg/2", "z_wg/2"';
    ss{9} = '     .Create';
    ss{10} = 'End With';

    sCommand = ss{1};
    for kk=2:length(ss)
        sCommand = [sCommand 10 ss{kk}];
    end
    invoke(mws,'AddToHistory','define brick',sCommand);

    %% define edge
    invoke(mws,'AddToHistory','pick edge','Pick.PickEdgeFromId "component1:solid2", "10", "1"');
    invoke(mws,'AddToHistory','pick edge','Pick.PickEdgeFromId "component1:solid2", "9", "4"');

    %% define blend edges of: component1:solid2
    invoke(mws,'AddToHistory','blend edges','Solid.BlendEdge "r_blend"');

    %% define brick
    clear sCommand ss;
    ss{1} = 'With Brick';
    ss{2} = '     .Reset';
    ss{3} = '     .Name "solid3"';
    ss{4} = '     .Component "component1"';
    ss{5} = '     .Material "Vacuum"';
    ss{6} = '     .Xrange "-x_coup/2", "x_coup/2"';
    ss{7} = '     .Yrange "0", "L_wg"';
    ss{8} = '     .Zrange "-z_wg/2", "z_wg/2"';
    ss{9} = '     .Create';
    ss{10} = 'End With';

    sCommand = ss{1};
    for kk=2:length(ss)
        sCommand = [sCommand 10 ss{kk}];
    end
    invoke(mws,'AddToHistory','define brick',sCommand);

    %% add shapes
    invoke(mws,'AddToHistory','add1','Solid.Add "component1:solid2", "component1:solid3"');

    %% make n ports
    if NPort == 2
        clear sCommand ss;
        ss{1} = '';
        ss{2} = 'With Transform';
        ss{3} = '.Reset';
        ss{4} = '.Name "component1:solid2"';
        ss{5} = '.Origin "Free"';
        ss{6} = '.Center "0", "0", "0"';
        ss{7} = '.Angle "0", "0", "180"';
        ss{8} = '.MultipleObjects "True"';
        ss{9} = '.GroupObjects "False"';
        ss{10} = '.Repetitions "1"';
        ss{11} = '.MultipleSelection "False"';
        ss{12} = '.Destination ""';
        ss{13} = '.Material ""';
        ss{14} = '.Transform "Shape", "Rotate"';
        ss{15} = 'End With';

        sCommand = ss{1};
        for kk=2:length(ss)
            sCommand = [sCommand 10 ss{kk}];
        end
       invoke(mws,'AddToHistory','create n ports',sCommand);
       invoke(mws,'AddToHistory','add ports','Solid.Add "component1:solid1", "component1:solid2_1"');
    elseif NPort == 4
        clear sCommand ss;
        ss{1} = '';
        ss{2} = 'With Transform';
        ss{3} = '.Reset';
        ss{4} = '.Name "component1:solid2"';
        ss{5} = '.Origin "Free"';
        ss{6} = '.Center "0", "0", "0"';
        ss{7} = '.Angle "0", "0", "90"';
        ss{8} = '.MultipleObjects "True"';
        ss{9} = '.GroupObjects "False"';
        ss{10} = '.Repetitions "3"';
        ss{11} = '.MultipleSelection "False"';
        ss{12} = '.Destination ""';
        ss{13} = '.Material ""';
        ss{14} = '.Transform "Shape", "Rotate"';
        ss{15} = 'End With';

        sCommand = ss{1};
        for kk=2:length(ss)
            sCommand = [sCommand 10 ss{kk}];
        end
        invoke(mws,'AddToHistory','create n ports',sCommand);
        invoke(mws,'AddToHistory','add ports','Solid.Add "component1:solid1", "component1:solid2_1"');
        invoke(mws,'AddToHistory','add ports','Solid.Add "component1:solid1", "component1:solid2_2"');
        invoke(mws,'AddToHistory','add ports','Solid.Add "component1:solid1", "component1:solid2_3"');
    end

    %%
    invoke(mws,'AddToHistory','add2','Solid.Add "component1:solid1", "component1:solid2"');

    %% make port
    invoke(mws,'AddToHistory','pick face', 'Pick.PickFaceFromId "component1:solid1", "11"');

    clear sCommand ss;
    ss{1} = 'With Port';
    ss{2} = '     .Reset';
    ss{3} = '     .PortNumber "1"';
    ss{4} = '     .Label ""';
    ss{5} = '     .Folder ""';
    ss{6} = '     .NumberOfModes "1"';
    ss{7} = '     .AdjustPolarization "False"';
    ss{8} = '     .PolarizationAngle "0.0"';
    ss{9} = '     .ReferencePlaneDistance "0"';
    ss{10} = '     .TextSize "50"';
    ss{11} = '     .TextMaxLimit "0"';
    ss{12} = '     .Coordinates "Picks"';
    ss{13} = '     .Orientation "positive"';
    ss{14} = '     .PortOnBound "True"';
    ss{15} = '     .ClipPickedPortToBound "False"';
    ss{16} = '     .Xrange "-36.068", "36.068"';
    ss{17} = '     .Yrange "148.3", "148.3"';
    ss{18} = '     .Zrange "-17.018", "17.018"';
    ss{19} = '     .XrangeAdd "0.0", "0.0"';
    ss{20} = '     .YrangeAdd "0.0", "0.0"';
    ss{21} = '     .ZrangeAdd "0.0", "0.0"';
    ss{22} = '     .SingleEnded "False"';
    ss{23} = '     .WaveguideMonitor "False"';
    ss{24} = '     .Create';
    ss{25} = 'End With';

    sCommand = ss{1};
    for kk=2:length(ss)
        sCommand = [sCommand 10 ss{kk}];
    end
    invoke(mws,'AddToHistory','define port',sCommand);
end

%% create beam pipe

if pipe_circ_bool == 1
    clear sCommand ss;   %

    ss{1} = 'With Cylinder';
    ss{2} = '     .Reset';
    ss{3} = '     .Name "solid2"';
    ss{4} = '     .Component "component1"';
    ss{5} = '     .Material "Vacuum"';
    ss{6} = '     .OuterRadius "r_pipe"';
    ss{7} = '     .InnerRadius "0.0"';
    ss{8} = '     .Axis "z"';
    ss{9} = '     .Zrange "-(L_cav/2+L_pipe)", "(L_cav/2+L_pipe)"';
    ss{10} = '     .Xcenter "0"';
    ss{11} = '     .Ycenter "0"';
    ss{12} = '     .Segments "0"';
    ss{13} = '     .Create';
    ss{14} = 'End With';


    sCommand = ss{1};
    for kk=2:length(ss)
        if kk == 14
            sCommand = [sCommand 10 10 ss{kk}];
        else
            sCommand = [sCommand 10 ss{kk}];
        end
    end
    invoke(mws,'AddToHistory','create pipe',sCommand);
    invoke(mws,'AddToHistory','add pipe','Solid.Add "component1:solid1", "component1:solid2"');
else
    
    clear sCommand ss;   %
    ss{1} = 'With Transform';
    ss{2} = '.Reset';
    ss{3} = '.Name "component1"';
    ss{4} = '.Origin "Free"';
    ss{5} = '.Center "0", "0", "0"';
    ss{6} = ['.ScaleFactor "' num2str(Pipe_SF) '", "' num2str(Pipe_SF) '", "' num2str(Pipe_SF) '"'];
    ss{7} = '.MultipleObjects "True"';
    ss{8} = '.GroupObjects "False"';
    ss{9} = '.Repetitions "1"';
    ss{10} = '.MultipleSelection "False"';
    ss{11} = '.Destination ""';
    ss{12} = '.Material ""';
    ss{13} = '.Transform "Shape", "Scale"';
    ss{14} = 'End With';

    sCommand = ss{1};
    for kk=2:length(ss)
        if kk == 14
            sCommand = [sCommand 10 10 ss{kk}];
        else
            sCommand = [sCommand 10 ss{kk}];
        end
    end
    invoke(mws,'AddToHistory','scale shape',sCommand);
    invoke(mws,'AddToHistory','pick face','Pick.PickFaceFromId "component1:solid1_1", "2"');

    clear sCommand ss;   %
    ss{1} = 'With Extrude';
    ss{2} = '.Reset';
    ss{3} = '.Name "solid2"';
    ss{4} = '.Component "component1"';
    ss{5} = '.Material "Vacuum"';
    ss{6} = '.Mode "Picks"';
    ss{7} = '.Height "L_pipe"';
    ss{8} = '.Twist "0.0"';
    ss{9} = '.Taper "0.0"';
    ss{10} = '.UsePicksForHeight "False"';
    ss{11} = '.DeleteBaseFaceSolid "False"';
    ss{12} = '.KeepMaterials "False"';
    ss{13} = '.ClearPickedFace "True"';
    ss{14} = '.Create';
    ss{15} = 'End With';

    sCommand = ss{1};
    for kk=2:length(ss)
        if kk == 14
            sCommand = [sCommand 10 10 ss{kk}];
        else
            sCommand = [sCommand 10 ss{kk}];
        end
    end
    invoke(mws,'AddToHistory','extrude 1',sCommand);

    invoke(mws,'AddToHistory','pick face','Pick.PickFaceFromId "component1:solid1_1", "3"');
    clear sCommand ss;   %
    ss{1} = 'With Extrude';
    ss{2} = '.Reset';
    ss{3} = '.Name "solid3"';
    ss{4} = '.Component "component1"';
    ss{5} = '.Material "Vacuum"';
    ss{6} = '.Mode "Picks"';
    ss{7} = '.Height "L_pipe"';
    ss{8} = '.Twist "0.0"';
    ss{9} = '.Taper "0.0"';
    ss{10} = '.UsePicksForHeight "False"';
    ss{11} = '.DeleteBaseFaceSolid "False"';
    ss{12} = '.KeepMaterials "False"';
    ss{13} = '.ClearPickedFace "True"';
    ss{14} = '.Create';
    ss{15} = 'End With';

    sCommand = ss{1};
    for kk=2:length(ss)
        if kk == 14
            sCommand = [sCommand 10 10 ss{kk}];
        else
            sCommand = [sCommand 10 ss{kk}];
        end
    end
    invoke(mws,'AddToHistory','extrude2',sCommand);
    invoke(mws,'AddToHistory','add pipe','Solid.Add "component1:solid1_1", "component1:solid2"');
    invoke(mws,'AddToHistory','add pipe','Solid.Add "component1:solid1_1", "component1:solid3"');
    invoke(mws,'AddToHistory','add pipe','Solid.Add "component1:solid1", "component1:solid1_1"');

end




%% set frequency range
invoke(mws,'AddToHistory','set freq', 'Solver.FrequencyRange "freq_lower", "freq_upper"');

%% go to freq solver
invoke(mws,'AddToHistory','change solver', 'ChangeSolverType "HF Frequency Domain"');


%% define freq sweep

clear sCommand ss;   %
ss{1} = 'Mesh.SetCreator "High Frequency"';

ss{2} = 'With FDSolver';
ss{3} = '     .Reset';
ss{4} = '     .SetMethod "Tetrahedral", "General purpose"';
ss{5} = '     .OrderTet "Second"';
ss{6} = '     .OrderSrf "First"';
ss{7} = '     .Stimulation "All", "All"';
ss{8} = '     .ResetExcitationList';
ss{9} = '     .AutoNormImpedance "False"';
ss{10} = '     .NormingImpedance "50"';
ss{11} = '     .ModesOnly "False"';
ss{12} = '     .ConsiderPortLossesTet "True"';
ss{13} = '     .SetShieldAllPorts "False"';
ss{14} = '     .AccuracyHex "1e-6"';
ss{15} = '     .AccuracyTet "1e-4"';
ss{16} = '     .AccuracySrf "1e-3"';
ss{17} = '     .LimitIterations "False"';
ss{18} = '     .MaxIterations "0"';
ss{19} = '     .SetCalcBlockExcitationsInParallel "True", "True", ""';
ss{20} = '     .StoreAllResults "False"';
ss{21} = '     .StoreResultsInCache "False"';
ss{22} = '     .UseHelmholtzEquation "True"';
ss{23} = '     .LowFrequencyStabilization "True"';
ss{24} = '     .Type "Auto"';
ss{25} = '     .MeshAdaptionHex "False"';
ss{26} = '     .MeshAdaptionTet "True"';
ss{27} = '     .AcceleratedRestart "True"';
ss{28} = '     .FreqDistAdaptMode "Distributed"';
ss{29} = '     .NewIterativeSolver "True"';
ss{30} = '     .TDCompatibleMaterials "False"';
ss{31} = '     .ExtrudeOpenBC "False"';
ss{32} = '     .SetOpenBCTypeHex "Default"';
ss{33} = '     .SetOpenBCTypeTet "Default"';
ss{34} = '     .AddMonitorSamples "True"';
ss{35} = '     .CalcPowerLoss "True"';
ss{36} = '     .CalcPowerLossPerComponent "False"';
ss{37} = '     .StoreSolutionCoefficients "True"';
ss{38} = '     .UseDoublePrecision "False"';
ss{39} = '     .UseDoublePrecision_ML "True"';
ss{40} = '     .MixedOrderSrf "False"';
ss{41} = '     .MixedOrderTet "False"';
ss{42} = '     .PreconditionerAccuracyIntEq "0.15"';
ss{43} = '     .MLFMMAccuracy "Default"';
ss{44} = '     .MinMLFMMBoxSize "0.3"';
ss{45} = '     .UseCFIEForCPECIntEq "True"';
ss{46} = '     .UseEnhancedCFIE2 "True"';
ss{47} = '     .UseFastRCSSweepIntEq "false"';
ss{48} = '     .UseSensitivityAnalysis "False"';
ss{49} = '     .UseEnhancedNFSImprint "False"';
ss{50} = '     .RemoveAllStopCriteria "Hex"';
ss{51} = '     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"';
ss{52} = '     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"';
ss{53} = '     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"';
ss{54} = '     .RemoveAllStopCriteria "Tet"';
ss{55} = '     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"';
ss{56} = '     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"';
ss{57} = '     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"';
ss{58} = '     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"';
ss{59} = '     .RemoveAllStopCriteria "Srf"';
ss{60} = '     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"';
ss{61} = '     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"';
ss{62} = '     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"';
ss{63} = '     .SweepMinimumSamples "3"';
ss{64} = '     .SetNumberOfResultDataSamples "1001"';
ss{65} = '     .SetResultDataSamplingMode "Automatic"';
ss{66} = '     .SweepWeightEvanescent "1.0"';
ss{67} = '     .AccuracyROM "1e-4"';
ss{68} = ['     .AddSampleInterval "' num2str(freq_lower) '", "' num2str(freq_upper) '", "1", "Automatic", "False"'];
ss{69} = '     .AddSampleInterval "", "", "", "Automatic", "False"';
ss{70} = '     .MPIParallelization "False"';
ss{71} = '     .UseDistributedComputing "False"';
ss{72} = '     .NetworkComputingStrategy "RunRemote"';
ss{73} = '     .NetworkComputingJobCount "3"';
ss{74} = '     .UseParallelization "True"';
ss{75} = '     .MaxCPUs "1024"';
ss{76} = '     .MaximumNumberOfCPUDevices "2"';
ss{77} = 'End With';

ss{78} = 'With IESolver';
ss{79} = '     .Reset';
ss{80} = '     .UseFastFrequencySweep "True"';
ss{81} = '     .UseIEGroundPlane "False"';
ss{82} = '     .SetRealGroundMaterialName ""';
ss{83} = '     .CalcFarFieldInRealGround "False"';
ss{84} = '     .RealGroundModelType "Auto"';
ss{85} = '     .PreconditionerType "Auto"';
ss{86} = '     .ExtendThinWireModelByWireNubs "False"';
ss{87} = '     .ExtraPreconditioning "False"';
ss{88} = 'End With';

ss{89} = 'With IESolver';
ss{90} = '     .SetFMMFFCalcStopLevel "0"';
ss{91} = '     .SetFMMFFCalcNumInterpPoints "6"';
ss{92} = '     .UseFMMFarfieldCalc "True"';
ss{93} = '     .SetCFIEAlpha "0.500000"';
ss{94} = '     .LowFrequencyStabilization "False"';
ss{95} = '     .LowFrequencyStabilizationML "True"';
ss{96} = '     .Multilayer "False"';
ss{97} = '     .SetiMoMACC_I "0.0001"';
ss{98} = '     .SetiMoMACC_M "0.0001"';
ss{99} = '     .DeembedExternalPorts "True"';
ss{100} = '     .SetOpenBC_XY "True"';
ss{101} = '     .OldRCSSweepDefintion "False"';
ss{102} = '     .SetRCSOptimizationProperties "True", "100", "0.00001"';
ss{103} = '     .SetAccuracySetting "Custom"';
ss{104} = '     .CalculateSParaforFieldsources "True"';
ss{105} = '     .ModeTrackingCMA "True"';
ss{106} = '     .NumberOfModesCMA "3"';
ss{107} = '     .StartFrequencyCMA "-1.0"';
ss{108} = '     .SetAccuracySettingCMA "Default"';
ss{109} = '     .FrequencySamplesCMA "0"';
ss{110} = '     .SetMemSettingCMA "Auto"';
ss{111} = '     .CalculateModalWeightingCoefficientsCMA "True"';
ss{112} = '     .DetectThinDielectrics "True"';
ss{113} = 'End With';

sCommand = ss{1};
for kk=2:length(ss)
    if kk == 77 || kk == 88 || kk == 113
        sCommand = [sCommand 10 10 ss{kk}];
    else
        sCommand = [sCommand 10 ss{kk}];
    end
end
invoke(mws,'AddToHistory','define freq sweep',sCommand);


%% make mesh
invoke(mws,'AddToHistory','create meshgroup', 'Group.Add "meshgroup1", "mesh"');

clear sCommand ss;   %
ss{1} = 'With MeshSettings';
ss{2} = '     With .ItemMeshSettings("group$meshgroup1")';
ss{3} = '          .SetMeshType "Tet"';
ss{4} = '          .Set "LayerStackup", "Automatic"';
ss{5} = '          .Set "LocalAutomaticEdgeRefinement", "0"';
ss{6} = '          .Set "LocalAutomaticEdgeRefinementOverwrite", 0';
ss{7} = '          .Set "MaterialIndependent", 0';
ss{8} = '          .Set "OctreeSizeFaces", "0"';
ss{9} = '          .Set "PatchIndependent", 0';
ss{10} = '          .Set "Size", "LocalMeshSize"';
ss{11} = '     End With';
ss{12} = 'End With';

sCommand = ss{1};
for kk=2:length(ss)
    if kk == 11 || kk == 1
        sCommand = [sCommand 10 10 ss{kk}];
    else
        sCommand = [sCommand 10 ss{kk}];
    end
end
invoke(mws,'AddToHistory','set mesh properties',sCommand);

invoke(mws,'AddToHistory','add to mesh','Group.AddItem "solid$component1:solid1", "meshgroup1"');

%% define monitors

if eigenbool == false
    clear sCommand ss;
    ss{1} = 'With Monitor';
    ss{2} = '     .Reset';
    ss{3} = ['     .Name "e-field (f=' num2str(f_monitor) ')"'];
    ss{4} = '     .Dimension "Volume"';
    ss{5} = '     .Domain "Frequency"';
    ss{6} = '     .FieldType "Efield"';
    ss{7} = '     .MonitorValue "3"';
    ss{8} = '     .UseSubvolume "False"';
    ss{9} = '     .Coordinates "Structure"';
    ss{10} = '     .SetSubvolume "-38.3", "38.3", "-38.3", "148.3", "-17.018", "17.018"';
    ss{11} = '     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0"';
    ss{12} = '     .SetSubvolumeInflateWithOffset "False"';
    ss{13} = '     .Create';
    ss{14} = 'End With';
    
    sCommand = ss{1};
    for kk=2:length(ss)
        sCommand = [sCommand 10 ss{kk}];
    end
    invoke(mws,'AddToHistory','define monitor',sCommand);
end

%% define background

clear sCommand ss;   %

ss{1} = 'With Background';
ss{2} = '     .ResetBackground';
ss{3} = '     .XminSpace "0.0"';
ss{4} = '     .XmaxSpace "0.0"';
ss{5} = '     .YminSpace "0.0"';
ss{6} = '     .YmaxSpace "0.0"';
ss{7} = '     .ZminSpace "0.0"';
ss{8} = '     .ZmaxSpace "0.0"';
ss{9} = '     .ApplyInAllDirections "False"';
ss{10} = 'End With';

ss{11} = 'With Material';
ss{12} = '     .Reset';
ss{13} = '     .Rho "0.0"';
ss{14} = '     .ThermalType "Normal"';
ss{15} = '     .ThermalConductivity "0"';
ss{16} = '     .SpecificHeat "0", "J/K/kg"';
ss{17} = '     .DynamicViscosity "0"';
ss{18} = '     .Emissivity "0"';
ss{19} = '     .MetabolicRate "0.0"';
ss{20} = '     .VoxelConvection "0.0"';
ss{21} = '     .BloodFlow "0"';
ss{22} = '     .MechanicsType "Unused"';
ss{23} = '     .IntrinsicCarrierDensity "0"';
ss{24} = '     .FrqType "all"';
ss{25} = '     .Type "Lossy metal"';
ss{26} = '     .MaterialUnit "Frequency", "Hz"';
ss{27} = '     .MaterialUnit "Geometry", "m"';
ss{28} = '     .MaterialUnit "Time", "s"';
ss{29} = '     .MaterialUnit "Temperature", "Kelvin"';
ss{30} = '     .Mu "1.0"';
ss{31} = '     .Sigma "5.8e7"';
ss{32} = '     .LossyMetalSIRoughness "0.0"';
ss{33} = '     .ReferenceCoordSystem "Global"';
ss{34} = '     .CoordSystemType "Cartesian"';
ss{35} = '     .NLAnisotropy "False"';
ss{36} = '     .NLAStackingFactor "1"';
ss{37} = '     .NLADirectionX "1"';
ss{38} = '     .NLADirectionY "0"';
ss{39} = '     .NLADirectionZ "0"';
ss{40} = '     .LatticeScattering "Electron", "0.1", "0."';
ss{41} = '     .LatticeScattering "Hole", "0.1", "0."';
ss{42} = '     .EffectiveMassForConductivity "Electron", "0.25"';
ss{43} = '     .EffectiveMassForConductivity "Hole", "0.35"';
ss{44} = '     .Colour "0.6", "0.6", "0.6"';
ss{45} = '     .Wireframe "False"';
ss{46} = '     .Reflection "False"';
ss{47} = '     .Allowoutline "True"';
ss{48} = '     .Transparentoutline "False"';
ss{49} = '     .Transparency "0"';
ss{50} = '     .ChangeBackgroundMaterial';
ss{51} = 'End With';

sCommand = ss{1};
for kk=2:length(ss)
    if kk == 10 || kk == 51
        sCommand = [sCommand 10 10 ss{kk}];
    else
        sCommand = [sCommand 10 ss{kk}];
    end
end
invoke(mws,'AddToHistory','define background',sCommand);

%% Add a boundary

clear sCommand ss;   %

if NPort == 1
    if XSymBool == 1
        ss{1} = 'With Boundary';
        ss{2} = '     .Xmin "electric"';
        ss{3} = '     .Xmax "electric"';
        ss{4} = '     .Ymin "electric"';
        ss{5} = '     .Ymax "electric"';
        ss{6} = '     .Zmin "electric"';
        ss{7} = '     .Zmax "electric"';
        ss{8} = '     .Xsymmetry "magnetic"';
        ss{9} = '     .Ysymmetry "none"';
        ss{10} = '     .Zsymmetry "electric"';
        ss{11} = '     .ApplyInAllDirections "False"';
        ss{12} = 'End With';
    elseif XSymBool == 2
        ss{1} = 'With Boundary';
        ss{2} = '     .Xmin "electric"';
        ss{3} = '     .Xmax "electric"';
        ss{4} = '     .Ymin "electric"';
        ss{5} = '     .Ymax "electric"';
        ss{6} = '     .Zmin "electric"';
        ss{7} = '     .Zmax "electric"';
        ss{8} = '     .Xsymmetry "magnetic"';
        ss{9} = '     .Ysymmetry "magnetic"';
        ss{10} = '     .Zsymmetry "electric"';
        ss{11} = '     .ApplyInAllDirections "False"';
        ss{12} = 'End With';
    else
        ss{1} = 'With Boundary';
        ss{2} = '     .Xmin "electric"';
        ss{3} = '     .Xmax "electric"';
        ss{4} = '     .Ymin "electric"';
        ss{5} = '     .Ymax "electric"';
        ss{6} = '     .Zmin "electric"';
        ss{7} = '     .Zmax "electric"';
        ss{8} = '     .Xsymmetry "none"';
        ss{9} = '     .Ysymmetry "none"';
        ss{10} = '     .Zsymmetry "electric"';
        ss{11} = '     .ApplyInAllDirections "False"';
        ss{12} = 'End With';
    end
elseif NPort == 2
    ss{1} = 'With Boundary';
    ss{2} = '     .Xmin "electric"';
    ss{3} = '     .Xmax "electric"';
    ss{4} = '     .Ymin "electric"';
    ss{5} = '     .Ymax "electric"';
    ss{6} = '     .Zmin "electric"';
    ss{7} = '     .Zmax "electric"';
    ss{8} = '     .Xsymmetry "none"';
    ss{9} = '     .Ysymmetry "magnetic"';
    ss{10} = '     .Zsymmetry "electric"';
    ss{11} = '     .ApplyInAllDirections "False"';
    ss{12} = 'End With';
elseif NPort == 4
    ss{1} = 'With Boundary';
    ss{2} = '     .Xmin "electric"';
    ss{3} = '     .Xmax "electric"';
    ss{4} = '     .Ymin "electric"';
    ss{5} = '     .Ymax "electric"';
    ss{6} = '     .Zmin "electric"';
    ss{7} = '     .Zmax "electric"';
    ss{8} = '     .Xsymmetry "magnetic"';
    ss{9} = '     .Ysymmetry "magnetic"';
    ss{10} = '     .Zsymmetry "electric"';
    ss{11} = '     .ApplyInAllDirections "False"';
    ss{12} = 'End With';
end

sCommand = ss{1};
for kk=2:length(ss)
    sCommand = [sCommand 10 ss{kk}];
end
invoke(mws,'AddToHistory','add boundary condition',sCommand);



%% MESH BOMB MAKER
if mesh_bool == true && eigenbool == true
    % Create Cylinders
    count = 0;
    for nn = RPoints:-1:1
        clear sCommand ss;   %
        if nn < RPoints
            R = Rmin+(nn-1)*(Rmax-Rmin)/(RPoints-1)/((RPoints-nn)^ExpFactor);
        else
            R = Rmax;
        end
        SaveBombName = num2str(round(R*10000)/10000);
        MeshCylName = ['bomb_R_' SaveBombName];

        if mesh_discrete == true
            theta = linspace(0,2*pi,NoCirclePoints);
            ss{1} = '   With Polygon'; 
            ss{2} = '        .Reset'; 
            ss{3} = '        .Name "temp"'; 
            ss{4} = '        .Curve "curve1"'; 
            ss{5} = ['        .Point "' num2str(R) '", "0"']; 
            countloop = 1;
            for kk = 2:length(theta)-1
                ss{5+countloop} = ['        .LineTo "' num2str(R*cos(theta(kk))) '", "' num2str(R*sin(theta(kk))) '"']; 
                countloop = countloop+1;
            end     
            ss{5+countloop} = ['        .LineTo "' num2str(R) '", "0"']; 
            ss{6+countloop} = '        .Create';
            ss{7+countloop} = '   End With';

            sCommand = ss{1};
            for kk=2:length(ss)
                sCommand = [sCommand 10 ss{kk}];
            end
            invoke(mws,'AddToHistory','define meshbomb',sCommand);

            clear sCommand ss;   %

            ss{1} = 'With CoverCurve';
	        ss{2} = '     .Reset';
	        ss{3} = '     .Name "TempBomb"';
	        ss{4} = '     .Component "component1"';
	        ss{5} = '     .Material "Vacuum"';
	        ss{6} = '     .Curve "curve1:temp"';
	        ss{7} = '     .DeleteCurve "True"';
	        ss{8} = '     .Create';
	        ss{9} = 'End With';
            sCommand = ss{1};
            for kk=2:length(ss)
                sCommand = [sCommand 10 ss{kk}];
            end
            invoke(mws,'AddToHistory','cover bomb curve',sCommand);
        
            invoke(mws,'AddToHistory','pick face','Pick.PickFaceFromId "component1:TempBomb", "1"');
        
            clear sCommand ss;   %
            ss{1} = 'With Extrude';
	        ss{2} = '     .Reset';
	        ss{3} = ['   .Name "' MeshCylName '"'];
	        ss{4} = '     .Component "component1"';
	        ss{5} = '     .Material "Vacuum"';
	        ss{6} = '     .Mode "Picks"';
	        ss{7} = ['     .Height "' num2str(L_cav*MeshBomb_PipeFactor) '"'];
	        ss{8} = '     .Twist "0.0"';
	        ss{9} = '     .Taper "0.0"';
	        ss{10} = '     .UsePicksForHeight "False"';
	        ss{11} = '     .DeleteBaseFaceSolid "True"';
	        ss{12} = '     .ClearPickedFace "True"';
	        ss{13} = '     .Create';
	        ss{14} = 'End With';
	        
            sCommand = ss{1};
            for kk=2:length(ss)
                sCommand = [sCommand 10 ss{kk}];
            end
            invoke(mws,'AddToHistory','extrude Bomb curve',sCommand);
        
            invoke(mws,'AddToHistory','delete curve','Curve.DeleteCurve "curve1"');
        
            clear sCommand ss;   %
            ss{1} = 'With Transform';
            ss{2} = '   .Reset';
            ss{3} = ['   .Name "component1:' MeshCylName '"']; 
            ss{4} = ['   .Vector "0", "0", "-L_cav/2*' num2str(MeshBomb_PipeFactor) '"']; 
            ss{5} = '   .UsePickedPoints "False"'; 
            ss{6} = '   .InvertPickedPoints "False"'; 
            ss{7} = '   .MultipleObjects "False"'; 
            ss{8} = '   .GroupObjects "False"'; 
            ss{9} = '   .Repetitions "1"'; 
            ss{10} = '   .MultipleSelection "False"'; 
            ss{11} = '   .Transform "Shape", "Translate"'; 
            ss{12} = 'End With';
            sCommand = ss{1};
            for kk=2:length(ss)
                sCommand = [sCommand 10 ss{kk}];
            end
            invoke(mws,'AddToHistory','Transform Bomb',sCommand);


        else
            ss{1} = '   With Cylinder';
            ss{2} = '       .Reset';
            ss{3} = ['       .Name "' MeshCylName '"'];
            ss{4} = '       .Component "component1"';
            ss{5} = '       .Material "Vacuum"';
            ss{6} = ['       .OuterRadius ' num2str(R)];
            ss{7} = ['       .InnerRadius ' '"0.0"'];
            ss{8} = '        .Axis "z"';
            ss{9} = ['       .Zrange ' num2str(-L_cav/2*MeshBomb_PipeFactor) ', ' num2str(L_cav/2*MeshBomb_PipeFactor)];
            ss{10} = '       .Xcenter "0.0"';
            ss{11} = '        .Ycenter "0.0"';
            ss{12} = '        .Segments "0"';
            ss{13} = '        .Create';
            ss{14} = '   End With';
            sCommand = ss{1};
            for kk=2:length(ss)
                sCommand = [sCommand 10 ss{kk}];
            end
            invoke(mws,'AddToHistory','define meshbomb',sCommand);
        end

        if count > 0
            invoke(mws,'AddToHistory','insert meshbomb',['Solid.Insert "component1:' NamePrev '", "component1:' MeshCylName '"']);
        else
            invoke(mws,'AddToHistory','insert meshbomb',['Solid.Insert "component1:solid1", "component1:' MeshCylName '"']);
        end
        count = count + 1;
        NamePrev = MeshCylName;

        invoke(mws,'AddToHistory','create meshgroup',['Group.Add "meshgroup' num2str(nn+1) '", "mesh"']);
        invoke(mws,'AddToHistory','add to meshgroup',['Group.AddItem "solid$component1:' MeshCylName '", "meshgroup' num2str(nn+1) '"']);

        clear sCommand ss;
        ss{1} = 'With MeshSettings';
        ss{2} = ['  With .ItemMeshSettings ("group$meshgroup' num2str(nn+1) '")'];
        ss{3} = '       .SetMeshType "Tet"';
        ss{4} = '       .Set "LayerStackup", "Automatic"';
        ss{5} = '       .Set "LocalAutomaticEdgeRefinement", "0"';
        ss{6} = '       .Set "LocalAutomaticEdgeRefinementOverwrite", 0';
        ss{7} = '       .Set "MaterialIndependent", 0';
        ss{8} = '       .Set "OctreeSizeFaces", "0"';
        ss{9} = '       .Set "PatchIndependent", 0';
        ss{10} = ['        .Set "Size", "' num2str(MeshFactor) '"'];
        ss{11} = '   End With';
        ss{12} = 'End With';

        sCommand = ss{1};
        for kk=2:length(ss)
            sCommand = [sCommand 10 ss{kk}];
        end
        invoke(mws,'AddToHistory','define mesh settings',sCommand);
    end
end


%% Make it into eigenmode solver
if eigenbool == true
    %% CYLINDER MAKER
    CurveName = 'cylinder_R_';
    SubCurveName = CurveName;
    xOffset = 0; yOffset = 0;
    points_file = 'points.txt';
    
    R_arr = zeros(1,RPoints);
    for nn = 1:RPoints
        if nn < RPoints
            R_arr(nn) = Rmin+(nn-1)*(Rmax-Rmin)/(RPoints-1)/((RPoints-nn)^ExpFactor);
        else
            R_arr(nn) = Rmax;
        end
    end
    
    if PointsMakerBool == true
        z_on = ones(1,NoLPoints); x_on = ones(1,NoLPoints); y_on = ones(1,NoLPoints);
        for ll = 0:(NoLPoints)
            if SymBool_z == 0
                z_on(ll+1) = (-L_cav/2-L_pipe)+2*(L_cav/2+L_pipe)/NoLPoints*ll;
            else
                z_on(ll+1) = (-L_cav/2-L_pipe)+(L_cav/2+L_pipe)/NoLPoints*ll;
            end
            x_on(ll+1) = xOffset;
            y_on(ll+1) = yOffset;
        end
    
        z_R = ones(RPoints,NoCirclePoints,NoLPoints); x_R = ones(RPoints,NoCirclePoints,NoLPoints); y_R = ones(RPoints,NoCirclePoints,NoLPoints);
        for nn = 1:RPoints
            R = R_arr(nn);
            SaveCurveName = num2str(round(R*10000)/10000);
    
            for ll = 0:(NoLPoints)
                for mm = 0:(NoCirclePoints-1)
                    Theta = 2*pi/NoCirclePoints*mm;
                    x_R(nn,mm+1,ll+1) = R*cos(Theta)+xOffset;
                    y_R(nn,mm+1,ll+1) = R*sin(Theta)+yOffset;
                    if SymBool_z == 0
                        z_R(nn,mm+1,ll+1) = (-L_cav/2-L_pipe)+2*(L_cav/2+L_pipe)/NoLPoints*ll;
                    else
                        z_R(nn,mm+1,ll+1) = (-L_cav/2-L_pipe)+(L_cav/2+L_pipe)/NoLPoints*ll;
                    end
                end
            end
        end
        PointsMatrix = [x_on' y_on' z_on'; x_R(:) y_R(:) z_R(:)];
        writematrix(PointsMatrix, [filename '\Points.txt'],'Delimiter','tab')
        %writematrix(PointsMatrix, [CSTFile 'points.txt'],'Delimiter','tab')
    end
    
    
    if CurveMakerBool == true
    
        clear sCommand ss;
        ss{1} = 'With Polygon3D';
        ss{2} = '    .Reset';
        ss{3} = '    .Version 10';
        ss{4} = ['    .Name "' CurveName '0"'];
        ss{5} = ['    .Curve "' SubCurveName '0"'];
    
        count = 1;
        z_on = ones(1,NoLPoints); x_on = ones(1,NoLPoints); y_on = ones(1,NoLPoints);
        for ll = 0:(NoLPoints)
            if SymBool_z == 0
                z_on(ll+1) = (-L_cav/2-L_pipe)+2*(L_cav/2+L_pipe)/NoLPoints*ll;
            else
                z_on(ll+1) = (L_cav/2+L_pipe)/NoLPoints*ll;
            end
            x_on(ll+1) = xOffset;
            y_on(ll+1) = yOffset;
            ss{5+count} = ['    .Point "' num2str(x_on(ll+1)) '", "' num2str(y_on(ll+1)) '", "' num2str(z_on(ll+1)) '"'];
            count = count + 1;
        end
        ss{5+count} = '    .Create';
        ss{6+count} = 'End With';
        sCommand = ss{1};
        for kk=2:length(ss)
              sCommand = [sCommand 10 ss{kk}];
        end
        invoke(mws,'AddToHistory','define curve',sCommand);
    
    
        z_R = ones(RPoints,NoCirclePoints,NoLPoints); x_R = ones(RPoints,NoCirclePoints,NoLPoints); y_R = ones(RPoints,NoCirclePoints,NoLPoints);
        for nn = 1:RPoints
            clear sCommand ss;   %
            R = R_arr(nn);
            SaveCurveName = num2str(round(R*10000)/10000);
    
            ss{1} = 'With Polygon3D';
            ss{2} = '    .Reset';
            ss{3} = '    .Version 10';
            ss{4} = ['    .Name "' CurveName SaveCurveName '"'];
            ss{5} = ['    .Curve "' SubCurveName SaveCurveName '"'];
            count = 1;
            for ll = 0:(NoLPoints)
                for mm = 0:(NoCirclePoints-1)
                    Theta = 2*pi/NoCirclePoints*mm;
                    x_R(nn,mm+1,ll+1) = R*cos(Theta)+xOffset;
                    y_R(nn,mm+1,ll+1) = R*sin(Theta)+yOffset;
                    if SymBool_z == 0
                        z_R(nn,mm+1,ll+1) = (-L_cav/2-L_pipe)+2*(L_cav/2+L_pipe)/NoLPoints*ll;
                    else
                        z_R(nn,mm+1,ll+1) = (L_cav/2+L_pipe)/NoLPoints*ll;
                    end
                    ss{5+count} = ['    .Point "' num2str(x_R(nn,mm+1,ll+1)) '", "' num2str(y_R(nn,mm+1,ll+1)) '", "' num2str(z_R(nn,mm+1,ll+1)) '"'];
                    count = count + 1;
                end
            end
            ss{5+count} = '    .Create';
            ss{6+count} = 'End With';
            sCommand = ss{1};
            for kk=2:length(ss)
                sCommand = [sCommand 10 ss{kk}];
            end
            invoke(mws,'AddToHistory','define curve',sCommand);
        end
    end

    %% Make into eigenmode solver
    invoke(mws,'AddToHistory','change to eigenmode','ChangeSolverType "HF Eigenmode"');
    clear sCommand ss;
    ss{1} = 'Mesh.SetFlavor "High Frequency"';
    
    ss{2} = 'Mesh.SetCreator "High Frequency"';
    
    ss{3} = 'EigenmodeSolver.Reset'; 
    ss{4} = 'With Solver';
    ss{5} = '     .CalculationType "Eigenmode"'; 
    ss{6} = '     .AKSReset ';
    ss{7} = '     .AKSPenaltyFactor "1" ';
    ss{8} = '     .AKSEstimation "0" ';
    ss{9} = '     .AKSAutomaticEstimation "True" ';
    ss{10} = '     .AKSEstimationCycles "5" ';
    ss{11} = '     .AKSIterations "2" ';
    ss{12} = '     .AKSAccuracy "1e-12" ';
    ss{13} = 'End With';
    ss{14} = 'With EigenmodeSolver ';
    ss{15} = '     .SetMethodType "AKS", "Hex" ';
    ss{16} = '     .SetMethodType "Default", "Tet" ';
    ss{17} = '     .SetMeshType "Tetrahedral Mesh" ';
    ss{18} = '     .SetMeshAdaptationHex "False" ';
    ss{19} = '     .SetMeshAdaptationTet "True" ';
    ss{20} = '     .SetNumberOfModes "1" ';
    ss{21} = '     .SetStoreResultsInCache "False" ';
    ss{22} = '     .SetCalculateExternalQFactor "False" ';
    ss{23} = '     .SetConsiderStaticModes "True" ';
    ss{24} = '     .SetCalculateThermalLosses "True" ';
    ss{25} = '     .SetModesInFrequencyRange "False" ';
    ss{26} = '     .SetFrequencyTarget "True", "2.99" ';
    ss{27} = '     .SetAccuracy "1e-6" ';
    ss{28} = '     .SetQExternalAccuracy "1e-4" ';
    ss{29} = '     .SetMaterialEvaluationFrequency "True", "" ';
    ss{30} = '     .SetTDCompatibleMaterials "False" ';
    ss{31} = '     .SetOrderTet "2" ';
    ss{32} = '     .SetUseSensitivityAnalysis "False" ';
    ss{33} = '     .SetConsiderLossesInPostprocessingOnly "True" ';
    ss{34} = '     .SetMinimumQ "1.0" ';
    ss{35} = '     .SetUseParallelization "True"';
    ss{36} = '     .SetMaxNumberOfThreads "1024"';
    ss{37} = '     .MaximumNumberOfCPUDevices "24"';
    ss{38} = '     .SetRemoteCalculation "False"';
    ss{39} = 'End With';
    ss{40} = 'UseDistributedComputingForParameters "False"';
    ss{41} = 'MaxNumberOfDistributedComputingParameters "2"';
    ss{42} = 'UseDistributedComputingMemorySetting "False"';
    ss{43} = 'MinDistributedComputingMemoryLimit "0"';
    ss{44} = 'UseDistributedComputingSharedDirectory "False"';
    ss{45} = 'OnlyConsider0D1DResultsForDC "False"';

    sCommand = ss{1};
    for kk=2:length(ss)
        sCommand = [sCommand 10 ss{kk}];
    end
    invoke(mws,'AddToHistory','set eigenmode settings',sCommand);
end

return


%% RETURNING AFTER EXPORTING FIELD ON POINTS LIST

% Field arranger
FieldFile = 'C:\Users\lawroe\cernbox\HTCondor\CST\sim_files\Iteration2_309k\Iteration2_309k\Export\3d\Mode 1_e.txt';
FieldFile = 'C:\Users\lawroe\cernbox\HTCondor\CST\sim_files\SinglePort_300k\Export\3d\Mode 1_e__points.txt';
FieldFile = 'C:\Users\lawroe\cernbox\HTCondor\CST\sim_files\Cancel10_340k\Export\3d\Mode 1_e__points.txt';
%FieldFile = [Path '\Playground\' CSTFile '\Export\3D\Mode 1_e.txt'];

% loop through on-axis
fid = fopen(FieldFile);
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
x_R_test = ones(size(x_R));y_R_test = ones(size(y_R));z_R_test = ones(size(z_R));
Ez_R = ones(size(x_R));
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
%%
% loop to multipolar decompose
V_z = zeros(RPoints,NoCirclePoints);
V_z_t = zeros(RPoints,NoCirclePoints);
Bess_e_n = zeros(RPoints,NoCirclePoints);
Bess_f_n = zeros(RPoints,NoCirclePoints);
Poly_e_n = zeros(RPoints,NoCirclePoints);
Poly_f_n = zeros(RPoints,NoCirclePoints);
t_arr = cos(2*pi*3e9*z_on/1e3/c);
RPoints; NoLPoints; NoCirclePoints;
for ii = 1:RPoints
    R_val = R_arr(ii)/1e3;
    for jj = 1:NoCirclePoints
        Ez_line = squeeze(Ez_R_Norm(ii,jj,:));
        if SymBool_z == 0
            Vz(ii,jj) = trapz(z_on/1e3,Ez_line);
            Vz_t(ii,jj) = trapz(z_on/1e3,Ez_line.*t_arr');
        else
            Vz(ii,jj) = 2*trapz(z_on/1e3,Ez_line);
            Vz_t(ii,jj) = 2*trapz(z_on/1e3,Ez_line.*t_arr');
        end
    end
    FFT = 2*fft(Vz_t(ii,:)); FFT(1) = FFT(1)/2;
    FFT_f = FFT(1:length(FFT)/2)/(length(FFT));

    FFT_Static = 2*fft(Vz(ii,:)); FFT_Static(1) = FFT_Static(1)/2;
    FFT_f_Static = FFT_Static(1:length(FFT_Static)/2)/(length(FFT_Static));

    for kk = 1:length(FFT_f)/2 
        n = kk-1;
        Bess_e_n(ii,kk) = 1./(besselj(n,2*pi*freq_rf/c*R_val))*real(FFT_f(kk));
        Bess_f_n(ii,kk) = 1./(besselj(n,2*pi*freq_rf/c*R_val))*imag(FFT_f(kk));
        Poly_e_n(ii,kk) = 1./(2*pi*freq_rf/c*R_val)^n*real(FFT_f(kk));
        Poly_f_n(ii,kk) = 1./(2*pi*freq_rf/c*R_val)^n*imag(FFT_f(kk));
        Poly_g_n(ii,kk) = sqrt(Poly_e_n(ii,kk)^2+Poly_f_n(ii,kk)^2);

        Bess_e_n_Static(ii,kk) = 1./(besselj(n,2*pi*freq_rf/c*R_val))*real(FFT_f_Static(kk));
        Bess_f_n_Static(ii,kk) = 1./(besselj(n,2*pi*freq_rf/c*R_val))*imag(FFT_f_Static(kk));
        Poly_e_n_Static(ii,kk) = 1./(2*pi*freq_rf/c*R_val)^n*real(FFT_f_Static(kk));
        Poly_f_n_Static(ii,kk) = 1./(2*pi*freq_rf/c*R_val)^n*imag(FFT_f_Static(kk));
    end
end

% figure(); hold all; plot(z_on,Ez_on);plot(z_on,Ez_on.*t_arr)

% Normalises to chosen multipole
NormMulti = 1;
NormToEnd = 0;
if NormToEnd == 1
    NormEndVal = 1;
else
    NormEndVal = 1/besselj(NormMulti-1,2*pi*f_monitor*1e9/c*R_val(end));
end
Bess_e_n_Norm = Bess_e_n./Bess_e_n(end,NormMulti)*NormEndVal;
Bess_f_n_Norm = Bess_f_n./Bess_e_n(end,NormMulti)*NormEndVal;
Poly_e_n_Norm = Poly_e_n./Poly_e_n(end,NormMulti);
Poly_f_n_Norm = Poly_f_n./Poly_e_n(end,NormMulti);
Poly_g_n_Norm = Poly_g_n./Poly_g_n(end,NormMulti);

Bess_e_n_Norm_Static = Bess_e_n_Static./Bess_e_n_Static(end,NormMulti);
Bess_f_n_Norm_Static = Bess_f_n_Static./Bess_e_n_Static(end,NormMulti);
Poly_e_n_Norm_Static = Poly_e_n_Static./Poly_e_n_Static(end,NormMulti);
Poly_f_n_Norm_Static = Poly_f_n_Static./Poly_e_n_Static(end,NormMulti);

%% Analyse the bore field
ii = RPoints;
R_val = R_arr(ii)/1e3;
Ez_Pipe = [];
for jj = 1:NoCirclePoints
    Ez_Pipe = [Ez_Pipe squeeze(Ez_R_Norm(ii,jj,:))];
end 
NoMultipoles = 5;
for jj = 1:NoLPoints+1
    Ez_circle_point = Ez_Pipe(jj,:);
    FFT = 2*fft(Ez_circle_point); FFT(1) = FFT(1)/2;
    FFT_f = FFT(1:length(FFT)/2)/(length(FFT));
    for kk = 1:NoMultipoles
        n = kk-1;
        Gm_FFT_e(jj,kk) = real(FFT_f(kk));
        Gm_FFT_f(jj,kk) = imag(FFT_f(kk));

        Gm_Bess_e(jj,kk) = 1./(besselj(n,2*pi*freq_rf/c*R_val))*real(FFT_f(kk));
        Gm_Bess_f(jj,kk) = 1./(besselj(n,2*pi*freq_rf/c*R_val))*imag(FFT_f(kk));
    end
end
BoreNorm = Gm_FFT_e(end,1);
figure(); subplot(1,2,1);plot(Ez_Pipe/BoreNorm); subplot(1,2,2);plot(Ez_Pipe'/BoreNorm)
figure(); plot(flip(z_0_test-z_0_test(1)),Gm_FFT_e/Gm_FFT_e(end,1),'linewidth',2)
FS = 16;
xlabel('$z$ [mm]','interpreter','latex')
ylabel('$\tilde{G}_m/\tilde{G}_0(0)$','interpreter','latex'); 
xlim([0, 35])
box on; grid on;
set(gcf,'Color','w')
legend({'$\tilde{G}_0$','$\tilde{G}_1$','$\tilde{G}_2$','$\tilde{G}_3$','$\tilde{G}_4$'},'location','NorthEast','interpreter','latex')
set(gca,'FontSize',FS)


%% Analyse the on-axis field
figure(); hold all
plot(z_0_test,Ez_on/BoreNorm)
plot(z_0_test,Ez_on.*t_arr/BoreNorm)
%% TIME
NoMultipoles = 5; yMin = -0.5; yMax = 2;
figure(); 
subplot(1,2,1); plot(R_arr,Poly_e_n_Norm(:,1:NoMultipoles),'-+'); xlabel('r [mm]'); ylabel('a_n'); set(gca,'ylim',[yMin yMax])
subplot(1,2,2); plot(R_arr,Poly_f_n_Norm(:,1:NoMultipoles),'-x'); xlabel('r [mm]'); ylabel('b_n'); set(gca,'ylim',[yMin yMax])
set(gcf,'color','w'); 
LegName = {};
for nn = 0:NoMultipoles-1
    LegName = [LegName num2str(nn)];
end
legend(LegName)

figure(); 
plot(R_arr,Poly_g_n_Norm(:,1:NoMultipoles),'-*'); xlabel('r [mm]'); ylabel('g_n'); set(gca,'ylim',[yMin yMax])
set(gcf,'color','w'); 
LegName = {};
for nn = 0:NoMultipoles-1
    LegName = [LegName num2str(nn)];
end
legend(LegName)

figure(); hold all;
subplot(1,2,1); plot(R_arr,Bess_e_n_Norm(:,1:NoMultipoles),'-+'); xlabel('r [mm]'); ylabel('e_n'); set(gca,'ylim',[yMin yMax])
subplot(1,2,2); plot(R_arr,Bess_f_n_Norm(:,1:NoMultipoles),'-x'); xlabel('r [mm]'); ylabel('f_n'); set(gca,'ylim',[yMin yMax])
set(gcf,'color','w'); set(gca,'ylim',[yMin yMax])
LegName = {};
for nn = 0:NoMultipoles-1
    LegName = [LegName num2str(nn)];
end
legend(LegName)

%% STATIC
% NoMultipoles = 5; yMin = -0.5; yMax = 2;
% figure(); 
% subplot(1,2,1); plot(R_arr,Poly_e_n_Norm_Static(:,1:NoMultipoles),'-+'); xlabel('r [mm]'); ylabel('a_n'); set(gca,'ylim',[yMin yMax])
% subplot(1,2,2); plot(R_arr,Poly_f_n_Norm_Static(:,1:NoMultipoles),'-x'); xlabel('r [mm]'); ylabel('b_n'); set(gca,'ylim',[yMin yMax])
% set(gcf,'color','w'); 
% LegName = {};
% for nn = 0:NoMultipoles-1
%     LegName = [LegName num2str(nn)];
% end
% legend(LegName)
% 
% figure(); hold all;
% subplot(1,2,1); plot(R_arr,Bess_e_n_Norm_Static(:,1:NoMultipoles),'-+'); xlabel('r [mm]'); ylabel('e_n'); set(gca,'ylim',[yMin yMax])
% subplot(1,2,2); plot(R_arr,Bess_f_n_Norm_Static(:,1:NoMultipoles),'-x'); xlabel('r [mm]'); ylabel('f_n'); set(gca,'ylim',[yMin yMax])
% set(gcf,'color','w'); set(gca,'ylim',[yMin yMax])
% LegName = {};
% for nn = 0:NoMultipoles-1
%     LegName = [LegName num2str(nn)];
% end
% legend(LegName)

% %% CYLINDER MAKER
% CurveName = 'cylinder_R_';
% SubCurveName = CurveName;
% xOffset = 0; yOffset = 0;
% points_file = 'points.txt';
% 
% if CylMakerBool == true
% 
%     ss{1} = 'With Polygon3D';
%     ss{2} = '    .Reset';
%     ss{3} = '    .Version 10';
%     ss{4} = ['    .Name "' CurveName '0"'];
%     ss{5} = ['    .Curve "' SubCurveName '0"'];
% 
%     count = 1;
%     z_on = ones(1,NoLPoints); x_on = ones(1,NoLPoints); y_on = ones(1,NoLPoints);
%     for ll = 0:(NoLPoints)
%         z_on(ll+1) = (-L_cav/2-L_pipe)+2*(L_cav/2+L_pipe)/NoLPoints*ll;
%         x_on(ll+1) = xOffset;
%         y_on(ll+1) = yOffset;
%         ss{5+count} = ['    .Point "' num2str(x_on(ll+1)) '", "' num2str(y_on(ll+1)) '", "' num2str(z_on(ll+1)) '"'];
%         count = count + 1;
%     end
%     ss{5+count} = '    .Create';
%     ss{6+count} = 'End With';
%     sCommand = ss{1};
%     for kk=2:length(ss)
%           sCommand = [sCommand 10 ss{kk}];
%     end
%     invoke(mws,'AddToHistory','define curve',sCommand);
% 
% 
%     for nn = RPoints:-1:1
%         clear sCommand ss;   %
%         if nn < RPoints
%             R = Rmin+(nn-1)*(Rmax-Rmin)/(RPoints-1)/((RPoints-nn)^ExpFactor);
%         else
%             R = Rmax;
%         end
%         SaveCurveName = num2str(round(R*10000)/10000);
% 
%         ss{1} = 'With Polygon3D';
%         ss{2} = '    .Reset';
%         ss{3} = '    .Version 10';
%         ss{4} = ['    .Name "' CurveName SaveCurveName '"'];
%         ss{5} = ['    .Curve "' SubCurveName SaveCurveName '"'];
%         count = 1;
%         z_R = ones(NoCirclePoints,NoLPoints); x_R = ones(NoCirclePoints,NoLPoints); y_R = ones(NoCirclePoints,NoLPoints);
%         for ll = 0:(NoLPoints)
%             for mm = 0:(NoCirclePoints-1)
%                 Theta = 2*pi/NoCirclePoints*mm;
%                 x_R(mm+1,ll+1) = R*cos(Theta)+xOffset;
%                 y_R(mm+1,ll+1) = R*sin(Theta)+yOffset;
%                 z_R(mm+1,ll+1) = (-L_cav/2-L_pipe)+2*(L_cav/2+L_pipe)/NoLPoints*ll;
%                 ss{5+count} = ['    .Point "' num2str(x_R(mm+1,ll+1)) '", "' num2str(y_R(mm+1,ll+1)) '", "' num2str(z_R(mm+1,ll+1)) '"'];
%                 count = count + 1;
%             end
%         end
%         ss{5+count} = '    .Create';
%         ss{6+count} = 'End With';
%         sCommand = ss{1};
%         for kk=2:length(ss)
%               sCommand = [sCommand 10 ss{kk}];
%         end
%         invoke(mws,'AddToHistory','define curve',sCommand);
% 
%     end
% 
% end
% 
% PointsMatrix = [x_on' y_on' z_on'; x_R(:) y_R(:) z_R(:)];
% writematrix(PointsMatrix,'points.txt','Delimiter','tab')
% 
% 
% return
% %% FILE EXPORTER
% ResultTree = mws.invoke('Resulttree');
% TreePath = 'Tables\1D Results\AllCurves_e';
% ResultTree.invoke('DoesTreeItemExist',TreePath);
% 
% Child = ResultTree.invoke('GetFirstChildName', TreePath);
% ich = 1;
% while ~isempty(Child)
%     ChildTreeItems{ich,1} = Child; %#ok<AGROW>
%     Child = ResultTree.invoke('GetNextItemName', Child);
%     ich = ich+1;
% end
% GetResultTreeItemChildren(TreePath)
% for ii = 1:ich-1
%     ResultIDs = ResultTree.invoke('GetResultIDsFromTreeItem',ChildTreeItems{ii});
%     if ii ~= 1
%         for jj = 1:length(ResultIDs)
%             res = ResultTree.invoke('GetResultFromTreeItem',ChildTreeItems{ii}, ResultIDs{jj});
%             l = res.invoke('GetArray','x');
%             Ez = res.invoke('GetArray','y');
%         end
%     else
%         for jj = 1:length(ResultIDs)
%             res = ResultTree.invoke('GetResultFromTreeItem',ChildTreeItems{ii}, ResultIDs{jj});
%             z_on =  res.invoke('GetArray','x')/1e3;
%             Ez_on = res.invoke('GetArray','y');
% 
%             T_arr = cos(2*pi*3e9*(z_on-(L_cav/2+L_pipe)/2)/c);
%             Ez_on_t = Ez.*T_arr;
%             Vz_on = trapz(z_on,Ez_on);
%             Vz_on_t = trapz(z_on,Ez_on_t);
%             figure(); plot(z_on,Ez_on_t)
%         end
%     end
% 
% end
return
% %%
% count = 0;
% err_count = 0;
% while count == err_count
%     try
%         Solver = invoke(mws,'FDSolver');
%         pause(2)
%         invoke(Solver,'Start');
%     catch MyErr
%         err_count = err_count + 1;
%     end
%     count = count + 1;
% end
% 
% ResultTree = mws.invoke('Resulttree');
% TreePath = '1D Results\S-Parameters';
% ResultTree.invoke('DoesTreeItemExist',TreePath);
% 
% % Determine all the data files
% Child = ResultTree.invoke('GetFirstChildName', TreePath);
% ich = 1;
% while ~isempty(Child)
%     ChildTreeItems{ich,1} = Child; %#ok<AGROW>
%     Child = ResultTree.invoke('GetNextItemName', Child);
%     ich = ich+1;
% end
% 
% ResultIDs = ResultTree.invoke('GetResultIDsFromTreeItem',ChildTreeItems{ii});
% for jj = 1:length(ResultIDs)
%     res = ResultTree.invoke('GetResultFromTreeItem',ChildTreeItems{ii}, ResultIDs{jj});
%     f = res.invoke('GetArray','x');
%     S11 = res.invoke('GetArray','yre')+1i*res.invoke('GetArray','yim');
% end
% 
% figure(); plot(f,20*log10(abs(S11)))
% 
% 
% count = 0;
% err_count = 0;
% while count == err_count
%     try
%         Solver = invoke(mws,'EigenmodeSolver');
%         pause(2)
%         invoke(Solver,'Start');
%         freq_GHz = importdata([ filename '\Result\Frequency (Mode 1).rd0']);
%     catch MyErr
%         err_count = err_count + 1;
%     end
%     count = count + 1;
% end
% 
% % pause(5)
% 
% %% Close CST file
% if InvokeQuit == true
%     invoke(mws, 'Quit');
% end
% pause(2)


% %% CYLINDER MAKER
% CurveName = 'cylinder_R_';
% SubCurveName = 'curve';
% xOffset = 0; yOffset = 0;
% if CylMakerBool == true
% 
%     ss{1} = 'With Polygon3D';
%     ss{2} = '    .Reset';
%     ss{3} = '    .Version 10';
%     ss{4} = ['    .Name "' SubCurveName '0"'];
%     ss{5} = ['    .Curve "' CurveName '0"'];
% 
%     count = 1;
%     z_on = ones(1,NoLPoints); x_on = ones(1,NoLPoints); y_on = ones(1,NoLPoints);
%     for ll = 0:(NoLPoints)
%         z_on(ll+1) = (-L_cav/2-L_pipe)+2*(L_cav/2+L_pipe)/NoLPoints*ll;
%         x_on(ll+1) = xOffset;
%         y_on(ll+1) = yOffset;
%         ss{5+count} = ['    .Point "' num2str(x_on(ll+1)) '", "' num2str(y_on(ll+1)) '", "' num2str(z_on(ll+1)) '"'];
%         count = count + 1;
%     end
%     ss{5+count} = '    .Create';
%     ss{6+count} = 'End With';
%     sCommand = ss{1};
%     for kk=2:length(ss)
%         sCommand = [sCommand 10 ss{kk}];
%     end
%     invoke(mws,'AddToHistory','define curve',sCommand);
% 
% 
%     for nn = RPoints:-1:1
%         clear sCommand ss;   %
%         if nn < RPoints
%             R = Rmin+(nn-1)*(Rmax-Rmin)/(RPoints-1)/((RPoints-nn)^ExpFactor);
%         else
%             R = Rmax;
%         end
%         SaveCurveName = num2str(round(R*10000)/10000);
% 
%         for mm = 0:(NoCirclePoints-1)
%             Theta = 2*pi/NoCirclePoints*mm;
%             SubCurveName = ['T = ' num2str(round(Theta*10000)/10000)];
%             ss{1} = 'With Polygon3D';
%             ss{2} = '    .Reset';
%             ss{3} = '    .Version 10';
%             ss{4} = ['    .Name "' SubCurveName  '"'];
%             ss{5} = ['    .Curve "' CurveName SaveCurveName '_' SubCurveName '"'];
%             count = 1;
%             for ll = 0:(NoLPoints)
%                 z = (-L_cav/2-L_pipe)+2*(L_cav/2+L_pipe)/NoLPoints*ll;
%                 x = R*cos(Theta)+xOffset;
%                 y = R*sin(Theta)+yOffset;
%                 ss{5+count} = ['    .Point "' num2str(x) '", "' num2str(y) '", "' num2str(z) '"'];
%                 count = count + 1;
%             end
%             ss{5+count} = '    .Create';
%             ss{6+count} = 'End With';
%             sCommand = ss{1};
%             for kk=2:length(ss)
%                 sCommand = [sCommand 10 ss{kk}];
%             end
%             invoke(mws,'AddToHistory','define curve',sCommand);
%         end
% 
%     end
% end


