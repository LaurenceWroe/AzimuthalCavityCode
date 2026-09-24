%% ThesisPlotter.m
% The aim of this code is to plot the Bessel shape and then indicate how
% the Bessel shape varies as theta changes.
c = physconst('lightspeed'); 

% NOTE NOTE NOTE 
% To get conditional solutions, there is a hard coded variable to make true

f = 3e9; k = 2*pi*f/c; yMult = 1;
k = 1; f = c/(2*pi); 
PointsFactor = 3; ArgRange = 50/k/2;
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
    SaveFolder = '/Users/wroe/Documents/Oxford DPhil (HardDrive Files)/CST Shapes/';
    SaveName = [Title_Str];
    MatrixToSave = ScaleFactor*[(r_Save.*cos(theta_Save)); (r_Save.*sin(theta_Save))];
    fileID = fopen([SaveFolder SaveName '.txt'],'w');
    %fileID = fopen(['40cmCirc.txt'],'w');
    fprintf(fileID,'%8.5f, %8.5f\n',MatrixToSave);
    fclose(fileID);
end

figure(); plot(r_Save.*cos(theta_Save),r_Save.*sin(theta_Save))
%% Block for Setting Plotting Parameters 

% Plotting settings
LW = 2.5; TFS = 20; LS = 24; TS = 18; MS = 10;
MaxR = max(max(r_0));

r_p = linspace(0,MaxR*1.5,101);
theta_p = 0;
MaxLim = 0;
MinLim = 0;
temp_r_0 = [];
theta_original = theta; theta = theta_original;
if Spiral == true
    TestExSols = 5;
    ExSols = ones(TestExSols,length(theta_original))*NaN;
    NTests = 0;
    for ii = 1:length(RootStruct)
        Tests = RootStruct(ii).RawSolutions(RootStruct(ii).RawSolutions>0 & RootStruct(ii).RawSolutions<r_0(1,ii));
        if ~isempty(Tests)
            Tests = sort(Tests,'descend');
            for jj = 1:length(Tests)
                ExSols(jj,ii) = Tests(jj);
                if length(Tests)>NTests
                    ExSols(length(Tests),ii-1) = 0;
                    NTests = NTests+1;
                end
            end
        end
    end
    
    RootS = Root(1:length(Root)/2);
    for ii = 1:length(RootS)
        temp_r_0(ii,:) = [r_0(ii,:) r_0(ii+length(RootS)-1,:)];
    end
    r_0_t = temp_r_0;
    theta = [theta theta+theta(end)];
    SpirColours = [0 0 0; 0 0 0; 0 0 0];
    
else
    theta = theta_original;
    r_0_t = r_0;
    RootS = Root;
end

for ii = 1:Count-1
    if ii == 2
        yVals = -eval(Eval_Str_Max{ii});
    else
        yVals = eval(Eval_Str_Max{ii});
    end
    %plot(r_p,yVals,'linewidth',LW)
    MaxVal = max(yVals);
    MinVal = min(yVals);
    if MaxVal > MaxLim
        MaxLim = MaxVal;
    end
    if MinVal < MinLim
        MinLim = MinVal;
    end
end

if abs(MaxLim)>abs(MinLim)
    PlotLim = MaxLim;
else
    PlotLim = abs(MinLim);
end

%%
% figure();
% clf; hold all;
% for ii = 1:6
%     r = r_0(ii,:);
%     if Spiral == true
%         plot(k*r.*cos(theta_original+CondAngle),k*r.*sin(theta_original+CondAngle),'linewidth',LW,'DisplayName', ['$\eta$ = ' num2str(ii)])
%     else
%         plot(k*r.*cos(theta_original+CondAngle),k*r.*sin(theta_original+CondAngle),'Color',ShapeColours(ii,:),'linewidth',LW,'DisplayName', ['$\eta$ = ' num2str(ii)])
%     end
% end


%% Block for Plotting Cross-Sections
figure(); hold all;
counter = 1;

for ii = 1:length(RootS)
    r = r_0_t(ii,:);
    if Spiral == true
        plot(r.*cos(theta+CondAngle)*yMult,r.*sin(theta+CondAngle)*yMult,'Color',SpirColours(ii,:),'linewidth',LW,'DisplayName', ['$\eta$ = ' num2str(ii)])
    else
        plot(r.*cos(theta+CondAngle)*yMult,r.*sin(theta+CondAngle)*yMult,'Color',ShapeColours(ii,:),'linewidth',LW,'DisplayName', ['$\eta$ = ' num2str(ii)])
    end
end
legend('show','location','northeastoutside','interpreter','latex')
axis equal;
%set(gca,'TickLabelInterpreter','latex')
set(gca,'FontSize',TS)
if k == 1
    xlabel('$kx$', 'FontSize', LS,'interpreter','latex');
    ylabel('$ky$', 'FontSize', LS,'interpreter','latex');
else
    xlabel('$x$ [cm]', 'FontSize', LS,'interpreter','latex');
    ylabel('$y$ [cm]', 'FontSize', LS,'interpreter','latex');
end
set(gcf,'color',[1 1 1])
xL = xlim*1.1; yL = ylim*1.1;
set(gca,'xlim',xL,'ylim',yL);
axis equal
xL = xlim; yL = ylim;
plot([0 0], yL,'k','linewidth',LW/3, 'HandleVisibility','off');  %x-axis
plot(xL, [0 0],'k','linewidth',LW/3, 'HandleVisibility','off');  %y-axis
set(gca,'xlim',xL,'ylim',yL);
set(gcf,'color','w'); box on;

if Save == true
    exportgraphics(gca,[SaveFolder Save_Str '.png'],'Resolution',300)
    saveas(gcf,[SaveFolder Save_Str '.fig'])
end

%% Block for Plotting Intersections

figure(); hold all;
counter = 1;

MaxDim = 0;
for ii = 1:length(Eval_Str_Ind)
    r_p = linspace(0,ArgRange,501); 
    theta_p = 0;
%     if CondAngle == 0 || M(ii) == 0
%         theta_p = 0;
%     else
%        theta_p = -pi/2/M(ii);
%     end
    
    if BessVals(M(ii)+1) == 1
        LegVal = ' ';
    else
        LegVal = num2str(BessVals(M(ii)+1));
    end
    
    if M(ii) ~= 0
        y = eval(Eval_Str_Max{ii});
        plot(r_p*yMult,y,'color',BessColoursT(M(ii)+1,:),'linewidth',LW,'displayname',['$f(kr) = \pm' LegVal  'J_' num2str(M(ii)) '(kr)$'])
        plot(r_p*yMult,-y,'color',BessColoursT(M(ii)+1,:),'linewidth',LW,'handlevisibility','off')
        if max(abs(y))>MaxDim
            MaxDim = max(abs(y));
        end
        %disp(MaxDim)
    else
        y = eval(Eval_Str_Max{ii});
        plot(r_p*yMult,y,'color',BessColoursT(M(ii)+1,:),'linewidth',LW,'displayname',['$f(kr) = ' LegVal  'J_0(kr)$'])
        if max(abs(y))>MaxDim
            MaxDim = max(abs(y));
        end
    end
    
end

for ii = 1:length(Root)
    r_p = r_0(ii,:);
    theta_p = theta_original;
    if Spiral == true
        plot(r_p*yMult,eval(Eval_Str_Ind{1}),'Color','k','linewidth',LW,'handlevisibility','off')
    else
        plot(r_p*yMult,eval(Eval_Str_Ind{1}),'Color',ShapeColours(ii,:),'linewidth',LW,'handlevisibility','off')
        if FudgePlot == true
            if sum(ii==FudgeRoots)== 1
                for kk = 1:FudgeAngles
                    theta_p = theta+CondAngle+2*pi/FudgeAngles*kk;
                    plot(r_p*yMult,eval(Eval_Str_Ind{1}),'Color',ShapeColours(ii,:),'linewidth',LW,'handlevisibility','off') 
                    theta_p = -theta+CondAngle+2*pi/FudgeAngles*kk;
                    plot(r_p*yMult,eval(Eval_Str_Ind{1}),'Color',ShapeColours(ii,:),'linewidth',LW,'handlevisibility','off') 
                end
            end
        end
    end
end

legend('show','location','northeast','interpreter','latex','fontsize',TS)
%set(gca,'TickLabelInterpreter','latex')
set(gca,'FontSize',TS)
if k == 1
    xlabel('$kr$', 'FontSize', LS,'interpreter','latex');
else
    xlabel('$r$ [cm]', 'FontSize', LS,'interpreter','latex');
end
ylabel('$f(kr)$', 'FontSize', LS,'interpreter','latex');
% xL = xlim; yL = ylim;
% set(gca,'ylim',yL*1.1)
set(gca,'ylim',[-MaxDim*1.1,MaxDim*1.1])
xL = xlim; yL = ylim;
plot([0 0], yL,'k','linewidth',LW/3, 'HandleVisibility','off');  %x-axis
plot(xL, [0 0],'k','linewidth',LW/3, 'HandleVisibility','off');  %y-axis
set(gca,'xlim',xL,'ylim',yL);
set(gcf,'color','w'); box on;


% if Save == true
%     exportgraphics(gca,[SaveFolder Save_Str '_Bess.png'],'Resolution',300)
%     saveas(gcf,[SaveFolder Save_Str '_Bess.fig'])
%     MaxDim = max(r_0(Root(end),:));
%     MaxDim = 13.5/1.1
%     set(gca,'xlim',[0 MaxDim*1.1*yMult])
%     exportgraphics(gca,[SaveFolder Save_Str '_BessZoom.png'],'Resolution',300)
%     saveas(gcf,[SaveFolder Save_Str '_BessZoom.fig'])
% end

%% Block for Plotting Fields

figure(); hold all;

r_Root = r_0(length(Root),:);
NoLevels = 21;

ArrRange = ArgRange;
x =  linspace(-ArrRange,ArrRange,1001);
y =  linspace(-ArrRange,ArrRange,1001);
t = linspace(0,2*pi,11);
MaxDim = max(r_Root);

CountorCount = 0;

[X,Y] = meshgrid(unique(x),unique(y));
R = sqrt(X.^2+Y.^2); Angle = F_atan3(X,Y);

r_p = R; theta_p = Angle;
% if CondAngle ~= 0 
%     PhiVals(4) = pi/2;
% end

EzPred = eval(Eval_Str);

% Here we normalise data for the colorbar
MaxE = max(max(EzPred)); MinE = min(min(EzPred));
if abs(MaxE)>(MinE)
    EzPred = EzPred./MaxE;
else
    EzPred = EzPred./abs(MinE);
end

% Here we set any values outside to be zero
if Spiral ~= true
    for ii = 1:length(x)*length(y)
        [~,AngPos] = min(abs(theta-Angle(ii)));

        if R(ii)>=r_Root(AngPos)
            EzPred(ii) = NaN;
        end
    end
end
nanpos = isnan(EzPred);

% These two lines are somewhat cheats to fix the edges of the colorbar
%EzPred(1) = 1;
EzPred(end) = -1;

if CondAngle ~= 0
    XY = [X(:) Y(:)];  % Create Matrix Of Vectors
    theta_R=CondAngle; %TO ROTATE CLOCKWISE BY X DEGREES
    R=[cos(theta_R) -sin(theta_R); sin(theta_R) cos(theta_R)]; %CREATE THE MATRIX
    rotXY=XY*R';       %MULTIPLY VECTORS BY THE ROT MATRIX 
    Xq = reshape(rotXY(:,1), size(X,1), []);
    Yq = reshape(rotXY(:,2), size(Y,1), []);
else 
    Xq = X; Yq = Y;
end

Xq = Xq*yMult; Yq = Yq*yMult;
contourf(Xq,Yq,EzPred,NoLevels,'handlevisibility','off')
mycolormap = customcolormap(linspace(0,1,11), {'#7f3c0a','#b35807','#e28212','#f9b967','#ffe0b2','#f7f7f5','#d7d9ee','#b3abd2','#8073a9','#562689','#2f004d'});
colormap(mycolormap);
% colorbar('southoutside','XTickLabel',{'-1','-0.5','0','0.5','1'}, ...
%                'XTick', [-1, -0.5,0,0.5,1]);
colorbar('eastoutside','XTickLabel',{'-E_0','-E_0/2','0','E_0/2','E_0'}, ...
   'XTick', [-1, -0.5,0,0.5,1]);
caxis([-1,1])


for ii = 1:length(Root)
    
    if Spiral == true
        theta = theta_original;
        plot(r_0(ii,:).*cos(theta+CondAngle)*yMult,r_0(ii,:).*sin(theta+CondAngle)*yMult,'Color','k','linewidth',3,'handlevisibility', 'off')      
    else
        plot(r_0(ii,:).*cos(theta+CondAngle)*yMult,r_0(ii,:).*sin(theta+CondAngle)*yMult,'Color',ShapeColours(ii,:),'linewidth',3,'DisplayName', ['$\eta$ = ' num2str(Root(ii))])     
    end

    if FudgePlot == true
        if sum(ii==FudgeRoots)== 1
            for jj = 1:length(FudgeRoots)
                FR = FudgeRoots(1);
                for kk = 1:FudgeAngles-1
                   plot(r_0(ii,:).*cos(theta+CondAngle+2*pi/FudgeAngles*kk),r_0(ii,:).*sin(theta+CondAngle+2*pi/FudgeAngles*kk),'Color',ShapeColours(ii,:),'linewidth',3,'handlevisibility', 'off')
                end

                for kk = 1:FudgeAngles
                    plot(r_0(ii,:).*cos(-theta+CondAngle+2*pi/FudgeAngles*kk),r_0(ii,:).*sin(-theta+CondAngle+2*pi/FudgeAngles*kk),'Color',ShapeColours(ii,:),'linewidth',3,'handlevisibility', 'off')
                end
            end
        end
    end
    
end
% plot(r_0(1,91:181).*cos(theta(271:361))*yMult,r_0(1,91:181).*sin(theta(271:361))*yMult,'Color','k','linewidth',3,'handlevisibility', 'off')      
axis equal
plot(xlim*1.1,[0 0], 'k', 'LineWidth',LW/5,'handlevisibility','off')
plot([0 0], ylim*1.1, 'k', 'LineWidth',LW/5,'handlevisibility','off')
if Spiral == true
    SpirLim = 13.5;
    set(gca,'xlim',[-SpirLim*yMult SpirLim*yMult],'ylim',[-SpirLim*yMult SpirLim*yMult])
else
    set(gca,'xlim',[-MaxDim*1.1*yMult MaxDim*1.1*yMult],'ylim',[-MaxDim*1.1*yMult MaxDim*1.1*yMult])
end

%legend('show','location','northeastoutside','interpreter','latex')
set(gca,'FontSize',TS)
if Trig == true
    b = 0.038247509278403356;
    theta_ell = linspace(0,2*pi,201);
    ecc = 0.9;
    r_ell = b./sqrt(1-(ecc*cos(theta_ell)).^2);
    %plot(r_ell.*cos(theta_ell),r_ell.*sin(theta_ell),'g')
    r_circ = 19e-3;
    plot(r_circ.*cos(theta_ell),r_circ.*sin(theta_ell),'g--','LineWidth',LW)
    ax = gca;
    tick_scale_factor = 1000;
    ax.XTickLabel = ax.XTick * tick_scale_factor;
    ax.YTickLabel = ax.YTick * tick_scale_factor;
    ax.ZTickLabel = ax.ZTick * tick_scale_factor;
    xlabel('$x$ [mm]', 'FontSize', LS,'interpreter','latex');
    ylabel('$y$ [mm]', 'FontSize', LS,'interpreter','latex');
elseif k == 1
%     xlabel('$\kappa_0x$', 'FontSize', LS,'interpreter','latex');
%     ylabel('$\kappa_0y$', 'FontSize', LS,'interpreter','latex');
    xlabel('$kx$', 'FontSize', LS,'interpreter','latex');
    ylabel('$ky$', 'FontSize', LS,'interpreter','latex');
else
    xlabel('$x$ [m]', 'FontSize', LS,'interpreter','latex');
    ylabel('$y$ [m]', 'FontSize', LS,'interpreter','latex');
end
set(gcf,'color',[1 1 1])
set(gcf,'color','w'); box on;
% LIM = 21.0210;
% set(gca,'xlim',[-LIM LIM],'ylim',[-LIM LIM])

if Save == true
    exportgraphics(gca,[SaveFolder Save_Str '_Field.png'],'Resolution',300)
    saveas(gcf,[SaveFolder Save_Str '_Field.fig'])
end

%%  PLOTS ALL SOLUTIONS
% figure(); hold all
% for ii = 1:length(RootStruct)
%     
%     plot(RootStruct(ii).RawSolutions*cos(theta(ii)),RootStruct(ii).RawSolutions*sin(theta(ii)),'x')
%     
% end

%% SORTS OUT BESSEL ZOOM PLOTS IF LOADING OLD FIELD AND BESSEL FIGURES
% %%
% lims = get(gca,'xlim')
% %%
% Save_Str = '';
% MaxDim = lims(2);
% set(gca,'xlim',[0 MaxDim])
% exportgraphics(gca,[SaveFolder Save_Str '_BessZoom.png'],'Resolution',300)
% saveas(gcf,[SaveFolder Save_Str '_BessZoom.fig'])


%% CODE THAT PLOTS THE NON-DEGENERATE

% clear r_0_a r_0_b theta_t
% 
% r_0_a = r_0;
% 
% r_0_a(3,182:541) = r_0(2,182:541);
% r_0_a(2,182:541) = r_0(1,182:541);
% r_0_a(1,182:541) = 0;
% 
% 
% 
% r_0_b(1,:) = [r_0_a(1,1:181) r_0_a(1,181) r_0_a(1,182:541) r_0_a(1,542) r_0_a(1,542:end)];
% r_0_b(2,:) = [r_0_a(2,1:181) r_0_a(2,181) r_0_a(2,182:541) r_0_a(2,542) r_0_a(2,542:end)];
% r_0_b(3,:) = [r_0_a(3,1:181) r_0_a(3,181) r_0_a(3,182:541) r_0_a(3,542) r_0_a(3,542:end)];
% 
% r_0_b(3,182) = r_0(2,1);
% r_0_b(2,182) = r_0(1,1);
% r_0_b(1,182) = 0;
% 
% theta_t = [theta(1:181) theta(181) theta(182:540) theta(541) theta(541:end)];
% 
% % r_0 = r_0_b; theta = theta_t;