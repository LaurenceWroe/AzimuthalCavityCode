
% Preamble
clear; close all; clc;
c = physconst('lightspeed');

%%% Specified parameters
% cav
f_upper = 3.005; 
f_lower = 2.995;
f_monitor = 3;
% waveguide
x_wg = 72.136;
z_wg = 50;%34.036;
L_wg = 100;
r_blend = 10;
r_coupcav = 6;
LocalMeshSize = 5;
r_pipe = 10;

freq_ratio = 3.023484*3.000126/3/3;

% Derived parameters
L_cav = z_wg;
L_pipe = z_wg;
x_coup = 15.645;%16.24;
r_cav = 38.2471*freq_ratio;

TemplateFile = fullfile(pwd,'Multipole_Template_3.cst');
 
FormatSpec = '%.4f';
freq_upper = num2str(f_upper);
freq_lower = num2str(f_lower); 

%%
  
cst = actxserver('CSTStudio.application');
mws = cst.invoke('NewMWS'); % open a new cst template
invoke(mws, 'OpenFile', TemplateFile);
filename = [pwd '\Playground\Test13']; 
fullname = [filename '.cst']; 
% if exist(fullname)
%     error('filename exists')
% end
invoke(mws,'SaveAs',fullname,'True');

InvokeQuit = true; % SET AS FALSE TO KEEP PROJECT OPEN

%%
invoke(mws,'StoreParameter','L_cav',L_cav);
invoke(mws,'StoreParameter','L_pipe',L_cav);
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



%% create beam pipe

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


%% set frequency range 
invoke(mws,'AddToHistory','set freq', 'Solver.FrequencyRange "freq_lower", "freq_upper"');

%% go to freq solver
invoke(mws,'AddToHistory','change solver', 'ChangeSolverType "HF Frequency Domain"');


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

return 

%%
count = 0;
err_count = 0;
while count == err_count
    try
       Solver = invoke(mws,'FDSolver');
       pause(2)
       invoke(Solver,'Start');   
    catch MyErr
        err_count = err_count + 1;
    end
    count = count + 1;
end

ResultTree = mws.invoke('Resulttree');
TreePath = '1D Results\S-Parameters';
ResultTree.invoke('DoesTreeItemExist',TreePath);

% Determine all the data files
Child = ResultTree.invoke('GetFirstChildName', TreePath);
ich = 1;
while ~isempty(Child)
    ChildTreeItems{ich,1} = Child; %#ok<AGROW>
    Child = ResultTree.invoke('GetNextItemName', Child);
    ich = ich+1;
end

ResultIDs = ResultTree.invoke('GetResultIDsFromTreeItem',ChildTreeItems{ii});
for jj = 1:length(ResultIDs)
        res = ResultTree.invoke('GetResultFromTreeItem',ChildTreeItems{ii}, ResultIDs{jj});
        f = res.invoke('GetArray','x');
        S11 = res.invoke('GetArray','yre')+1i*res.invoke('GetArray','yim');
end

figure(); plot(f,20*log10(abs(S11)))


count = 0;
err_count = 0;
while count == err_count
    try
       Solver = invoke(mws,'EigenmodeSolver');
       pause(2)
       invoke(Solver,'Start');   
       freq_GHz = importdata([ filename '\Result\Frequency (Mode 1).rd0']);
    catch MyErr
        err_count = err_count + 1;
    end
    count = count + 1;
end
 
% pause(5)

%% Close CST file
if InvokeQuit == true
    invoke(mws, 'Quit');
end
pause(2)






