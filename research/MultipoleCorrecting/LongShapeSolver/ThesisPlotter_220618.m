%% ThesisPlotter.m
% The aim of this code is to plot the Bessel shape and then indicate how
% the Bessel shape varies as theta changes.
c = physconst('lightspeed'); 

% NOTE NOTE NOTE 
% To get conditional solutions, there is a hard coded variable to make true

f = 3e9; k = 2*pi*f/c; yMult = 1;
%k = 1; f = c/(2*pi); 
PointsFactor = 1; ArgRange = 50/k/2;
m = 1; Root = [1];% 4 5 6];
NoBesses = 12; 

Save = false;
SaveFolder = '/Users/wroe/Documents/Thesis/Graphs/TestBed/';

%ShapeColours = [0 0 0.2; 0 0.2 1; 0 0.9 1; 0.5 1 0.83]; % Aquamarine
ShapeColours = [0 0 0.2; 0 0.2 1; 0 0.9 1; 0.196 0.804 0.196]; % Lime

BessVals = zeros(1,NoBesses);
PhiVals = zeros(1,NoBesses);

% MAGNITUDES
BessVals(1) =  1;
BessVals(2) =  1;
BessVals(3) =  1;%0.85;%0.8;
BessVals(4) =  0;
BessVals(5) =  0;
BessVals(6) =  0;
BessVals(7) =  0;%-1.6319;%-3.95;%-2.6;
BessVals(8) =  0;
BessVals(9) =  0;%29.7264;
BessVals(10) = 0;

% BessVals(1) = 1; BessVals(3) = 1.0251; BessVals(5) = 0.1903; BessVals(7)
% = 0.0063; % VALUES FOR ELLIPSE

% ANGLES
% NOTE FIX CONDITIONAL HERE. IF LEFT UNTOUCHED, WILL NOT FIND SOLUTIONS AT ALL ANGLES
% To fix, we rotate the shape initially to find all roots. Then we rotate back so it lines up with potential.
% Example for the TM_{{0,3)} modes:
% Set CondAngle = pi and PhiVals(4) = pi
Spiral = false; 
CondAngle = 0; % <------ NOTE ME!!! Set to same value of PhiVals 
PhiVals(6) = 0; % Set to pi to start with all roots found
PhiVals(4) = 0;

% FUDGEPLOT
% Note, it may be necessary to repeatedly plot roots if the conditional
% fails. To do so, set FudgePlot to be true to activate it. Then set the
% roots to Fudge. You may need to go to the code block to get it to work.
FudgePlot = false; 
FudgeAngles = 2; % This sets how many rotations to do of the shape.
FudgeRoots = [1 2];

% TRIG BOOLEAN. Note this is only true if we want to plot a trigonometric
% shape on top. Set it to true if want it on and move freq up
Trig = false; %f = 2.2920596e9; 

BessColours = F_distinguishable_colors(15);
BessColoursT = [];
for ii = 1:length(BessColours)
    if ii ~= 1 && ii~=4
        BessColoursT = cat(1,BessColoursT,BessColours(ii,:));
    end
end
BessColours = BessColoursT;

M = []; Title_Str = []; Eval_Str = []; Eval_Str_Ind = []; Eval_Str_Max = []; colours = [];
Save_Str = [];
Count = 1;

% Create plotting array
for ii = 1:NoBesses
    if BessVals(ii) ~= 0
        m = ii-1;
        
        colours = [colours; BessColours(ii+1,:)];
        
        if ~isempty(Title_Str)
            Title_Str = [Title_Str ' + '];
            Eval_Str = [Eval_Str ' + '];
            Save_Str = [Save_Str '_'];
        end
        
        M = cat(1,M,m);
        
        Eval_Str = [Eval_Str 'BessVals(' num2str(ii) ')*besselj(' num2str(m) ',k*r_p)'...
            '.*cos(' num2str(m) '*theta_p-PhiVals(' num2str(ii) '))'];
        
        Eval_Str_Ind{Count} = ['BessVals(' num2str(ii) ')*besselj(' num2str(m) ',k*r_p)'...
            '.*cos(' num2str(m) '*theta_p-PhiVals(' num2str(ii) '))'];
        
        Eval_Str_Max{Count} = ['BessVals(' num2str(ii) ')*besselj(' num2str(m) ',k*r_p)'...
            '.*cos(' num2str(m) '*theta_p)'];
        
        
        if PhiVals(ii) ~= 0 && CondAngle == 0
            if ii == 1
                Title_Str = [Title_Str num2str(BessVals(ii)) '*J_' num2str(m) '(kr_0(\theta))}'];
                Save_Str = [Save_Str 'g' num2str(m)  '_' num2str(BessVals(ii))];
                DisplayString{Count} = [num2str(BessVals(ii)) '*J_' num2str(m) '(kr)'];
                DisplayString2{Count} = ['f_' num2str(m) '(kr)'];
            else
                Title_Str = [Title_Str num2str(BessVals(ii)) '*J_' num2str(m) '(kr_0(\theta))*\cos(' num2str(m) '\theta-' num2str(PhiVals(ii)/pi) '\pi)'];
                Save_Str = [Save_Str 'g' num2str(m) '_' num2str(BessVals(ii))  '_' num2str(PhiVals(ii)/pi) 'pi'];
                DisplayString{Count} = [num2str(BessVals(ii)) '*J_' num2str(m) '(kr)'];
                DisplayString2{Count} = ['f_' num2str(m) '(kr)'];
            end
            
        else
            if ii == 1
                Title_Str = [Title_Str num2str(BessVals(ii)) '*J_' num2str(m) '(kr_0(\theta))'];
                Save_Str = [Save_Str 'g' num2str(m)  '_' num2str(BessVals(ii))];
                DisplayString{Count} = [num2str(BessVals(ii)) '*J_' num2str(m) '(kr)'];
                DisplayString2{Count} = ['f_' num2str(m) '(kr)'];
            else
                Title_Str = [Title_Str num2str(BessVals(ii)) '*J_' num2str(m) '(kr_0(\theta))*\cos{' num2str(m) '\theta}'];
                Save_Str = [Save_Str 'g' num2str(m) '_' num2str(BessVals(ii))];
                DisplayString{Count} = [num2str(BessVals(ii)) '*J_' num2str(m) '(kr)*\cos' num2str(m) '\theta'];
                DisplayString2{Count} = ['f_' num2str(m) '(kr)'];
            end
        end
        Count = Count+1;
    end
end
Title_Str = [Title_Str ' = 0'];
%% Solve for the Shape
[r_0, theta, RootStruct] = F_AziShapeCalc_CondPlay(f,PointsFactor,ArgRange,BessVals,PhiVals,Root);

theta_0 = repmat(theta,length(Root),1);

% for ii = 1:length(Root)
%    r_0(ii,631) = r_0(ii,630); 
%    r_0(ii,91) = r_0(ii,90);
%    r_0(ii,271) = r_0(ii,270);
%    r_0(ii,451) = r_0(ii,450);
%    
% end
% r_0(1,631:721)=r_0(1,271:361);
%% Code for Saving the Shape
Saver = false;
r_Save = r_0(1,:); theta_Save = theta_0(1,:);
if Saver == true
    ScaleFactor = 1000; % Puts into mm
    SaveFolder = 'C:\Users\lawroe\cernbox\Code\MultipoleCorrecting\Shapes\';
    SaveName = ['QuadDip'];
    MatrixToSave = ScaleFactor*[(r_Save.*cos(theta_Save)); (r_Save.*sin(theta_Save))];
    fileID = fopen([SaveFolder SaveName '.txt'],'w');
    %fileID = fopen(['40cmCirc.txt'],'w');
    fprintf(fileID,'%8.5f, %8.5f\n',MatrixToSave);
    fclose(fileID);
end

figure(); plot(r_Save.*cos(theta_Save),r_Save.*sin(theta_Save))

% % r_0 = r_0_b; theta = theta_t;