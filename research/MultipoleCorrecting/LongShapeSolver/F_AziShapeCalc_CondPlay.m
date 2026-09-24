%% AziShapeCalc(freq,PointsFactor,FigNo,Bess0,Bess1,...)
% This code works by using a find peaks function to determine positions of
% maxima. In order to try and find the continuous solutions, the code
% starts by taking the roots at zero angle and then trying to follow the
% values as theta varies from 0 to 2pi. In order to try and follow the
% solutions, a short Taylor expansion is used to guess subsequent solutions

% This shape is based on the ShapeCalc code used in
% UltimateEvalBesselSolver_211005.m

% UPGRADE - Add in second order differential
% Determine if unconditional by analysing the gradient/guess?


function [Shape_r_0, Theta, Roots] = F_AziShapeCalc_CondPlay(f,PointsFactor,ArgRange,BessVals,PhiVals,Root) 
% Note output this placeholder as it was messing up in GUI without

c = physconst('lightspeed');
omega = 2*pi*f;
xSize = ArgRange; 

NoTheta = 360*PointsFactor+1;
theta = linspace(0,2*pi,NoTheta);
DeltaTheta = theta(2)-theta(1);

% This for loop allows us to take in any number of bessel values. Note it
% requires the use of eval.
for ii = 1:length(BessVals)
    m = ii-1;
    if ii == 1
        eval_string = ['BessVals(' num2str(ii) ')*besselj(0,omega/c*xAr)'];
        diff_eval_string1 = '0';
        diff_eval_string2 = '-BessVals(1)*besselj(1,omega/c*r_0)';
    else
        eval_string = ['BessVals(' num2str(ii) ')*besselj(' num2str(m) ',omega/c*xAr)*cos(' num2str(m)   '*thetaVal-PhiVals(' num2str(ii) '))+' eval_string];
        diff_eval_string1 =  ['BessVals(' num2str(ii) ')*besselj(' num2str(m) ',omega/c*r_0)*' num2str(m) '*sin(' num2str(m)   '*thetaVal-PhiVals(' num2str(ii) '))+' diff_eval_string1];
        diff_eval_string2 =  ['BessVals(' num2str(ii) ')*(' num2str(m) './(omega/c*r_0).*besselj(' num2str(m) ',omega/c*r_0)-besselj(' num2str(m+1) ',omega/c*r_0)).*'...
            'cos(' num2str(m)   '*thetaVal-PhiVals(' num2str(ii) '))+' diff_eval_string2];
    end
end

  
RangeChecker = 1; % 1.5 = default POTENTIALLY CHANGE 
xAr = linspace(-xSize*RangeChecker,xSize*RangeChecker,5001); % NOTE factor of RangeChecker included to track solutions better
xAr = linspace(0,xSize*RangeChecker,15001); % NOTE factor of RangeChecker included to track solutions better
% This 5001 is fixed but could be increased to look for a greater accuracy
% of solutions (will be slower however)
RootLim = 1e-1;  % 1e-1 = default POTENTIALLY CHANGE 
% The peak finding code does not only find solutions that cross the x-axis.
% In an ideal code, we would say that the roots that equal zero are the
% peaks, but due to the size of xAr not being infinite, choose RootLim to
% be large enough to find them (but small enough to exclude other peaks)
Roots = struct;
% Shape finding code. 

for ii = 1:length(theta)
    
    % This block of code is the peak finding code. Finds all solutions in
    % the range
    thetaVal = theta(ii);
    y = eval(eval_string);
    absy = abs(y); flipy = max(absy)-absy; [pks,locs] = findpeaks(flipy-max(flipy));
    ylocs = y(locs); xlocs = xAr(locs);
    Sols = xlocs(pks>-RootLim);
    Roots(ii).RawSolutions = Sols; 
    r_0 = Sols;
    Roots(ii).AllGradients = 1/(omega/c)*eval(diff_eval_string1)./eval(diff_eval_string2);
    % Store all solutions in range, these are plotted at the end.
    
    % Here is the block where we are trying to find the continuous
    % solutions
    if ii == 1 % Some special considerations for first block
        % Note here that the n=1 solution of a m!=0 TM_{mnp} mode is r_0 =
        % 0. Thus may want to use the seconded commented line for plotting
        % purposes in this case
%%%%%%%%%%%%%%%% EDIT 
        Roots(ii).TrackedSolutions = Sols(Sols>=0 & Sols<xSize); % Store solutions we will track. We assume solution will not exceed three times radius at theta = 0.
%         Roots(ii).TrackedSolutions = Sols(Sols>0 & Sols<xSize); % Store solutions we will track. We assume solution will not exceed three times radius at theta = 0.
        r_0 = Roots(ii).TrackedSolutions; % This is for the eval to work
        rSolve = zeros(length(r_0),length(theta)); 
        Roots(ii).Guess = 0; % As first sol, no guess
        Roots(ii).Gradient = 1/(omega/c)*eval(diff_eval_string1)./eval(diff_eval_string2); % Determine the gradient
        Roots(ii).CorrectionTerm = 0; % As first sol, no guess
        ForbiddenArray = zeros(1,length(r_0));
        
    else % To track solutions
        
        
        Roots(ii).Guess = Roots(ii-1).TrackedSolutions + DeltaTheta*Roots(ii-1).Gradient; % Guess the next solution, CAN EXPAND
        Roots(ii).CorrectionTerm = DeltaTheta*Roots(ii-1).Gradient; % Helps with debugging
        
        
        for jj = 1:length(Roots(1).TrackedSolutions)
            % Now three potential issues tracking solutions: 
            % 1) Root is lost due to conditional
            
            
            % 2) Root goes negative as forbidden
                % This has been allowed. Correct for by just not plotting a
                % negative r.
                
            % 3) Guess is mental because the gradient becomes undefined
            
            
            % 4) Root is lost because it exceeds the range of r
                % Partial solution - allow the range of checking to be
                % RangeFactor times bigger than radius at theta = 0.
            Tolerance = 0.05;
            
                
            
            [~,MinPos] = min(abs(Roots(ii).RawSolutions - Roots(ii).Guess(jj)));
            Roots(ii).TrackedSolutions(jj) = Roots(ii).RawSolutions(MinPos);
            
        end
        
        for jj = 1:length(Roots(1).TrackedSolutions) % Conditional array check
            if length(Roots(ii-1).ForbiddenOrds) == 2
                if jj == 1 || jj == 2
                    x = Roots(ii).RawSolutions<Roots(ii).TrackedSolutions(3) & Roots(ii).RawSolutions>0;
                    y = Roots(ii).RawSolutions(x);
                    if sum(x) == 2
                        Roots(ii).TrackedSolutions(jj) = y(jj);
                        [~,MinPos] = min(abs(Roots(ii-1).RawSolutions - y(jj)));
                        rSolve(jj,ii-1) = Roots(ii-1).RawSolutions(MinPos);
                        
                    else
                        [~,MinPos] = min(abs(Roots(ii).RawSolutions - Roots(ii).Guess(jj)));
                        Roots(ii).TrackedSolutions(jj) = Roots(ii).RawSolutions(MinPos);
                    end
                end
            end
        end
    
        
        r_0 = Roots(ii).TrackedSolutions; % don't delete, used in below line
        Roots(ii).Gradient = 1/(omega/c)*eval(diff_eval_string1)./eval(diff_eval_string2);
        
        
    end
    
    % This is an attempt to stop the error arising from undefined
    % gradients 
    % UPGRADE: Fix with second order differential? Check individually
    if abs(Roots(ii).Gradient) > 1e6
        if ii == 1
            Roots(ii).Gradient = 0;
        else
            Roots(ii).Gradient = Roots(ii-1).Gradient;
        end
    end
    
    % This here determines if roots are forbidden or conditional
    Roots(ii).ForbiddenOrds = [];
    Roots(ii).ForbiddenVals = [];
    for jj = 1:length(Roots(ii).TrackedSolutions)
        if Roots(ii).TrackedSolutions(jj) < 0
            %rSolve(jj,ii) = 0;
            rSolve(jj,ii) = NaN;
            Roots(ii).ForbiddenOrds = [Roots(ii).ForbiddenOrds jj];
            Roots(ii).ForbiddenVals = [Roots(ii).ForbiddenVals rSolve(jj,ii-1)];
            if ForbiddenArray(jj) == 0
                ForbiddenArray(jj) = rSolve(jj,ii-1);
            end
            %ForbiddenArray(jj) = 0;
        else
            rSolve(jj,ii) = Roots(ii).TrackedSolutions(jj);
        end
        
    end
    
    % This block of code tries to pick fix up forbidden solutions
    if ii ~= 1 && BessVals(1) == 0 % Run only if no monopolar
        if ~isempty(Roots(ii-1).ForbiddenOrds)
            for jj = length(Roots(ii-1).ForbiddenOrds):-1:1
               ForRoot = Roots(ii).ForbiddenOrds(jj);
               if ~isempty(Roots(ii).RawSolutions(0<Roots(ii).RawSolutions & Roots(ii).RawSolutions<Roots(ii).TrackedSolutions(ForRoot+1)))
                   Roots(ii-1).TrackedSolutions(jj) = 0;
                   PosGrad = find(Roots(ii).AllGradients==Roots(ii).Gradient(ForRoot+1));
                   Roots(ii).Gradient(jj) = Roots(ii).AllGradients(PosGrad-1);
                   Roots(ii).TrackedSolutions(jj) = Roots(ii).RawSolutions(PosGrad-1);
                   Roots(ii).ForbiddenVals = Roots(ii).ForbiddenVals(Roots(ii).ForbiddenOrds ~= ForRoot);
                   Roots(ii).ForbiddenOrds = Roots(ii).ForbiddenOrds(Roots(ii).ForbiddenOrds ~= ForRoot);
                   rSolve(jj,ii-1) = Roots(ii-1).TrackedSolutions(jj);
                   rSolve(jj,ii) = Roots(ii).TrackedSolutions(jj);
                   break
               end 
            end 
        end
    end
    
end

Shape_r_0 = rSolve(Root,:);
Theta = theta;

end
