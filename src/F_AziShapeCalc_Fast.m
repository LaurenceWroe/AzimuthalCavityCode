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


function [Shape_r_0, Theta, Roots] = F_AziShapeCalc_Fast(f,PointsFactor,ArgRange,m,BessVals,PhiVals,Root) 
% Note output this placeholder as it was messing up in GUI without

c = 299792458; % exact SI speed of light; no toolbox required
omega = 2*pi*f; k = omega/c;


xSize = ArgRange; 
NoTheta = 360*PointsFactor+1;
theta = linspace(0,2*pi,NoTheta);
DeltaTheta = theta(2)-theta(1);

  
RangeChecker = 1; % 1.5 = default POTENTIALLY CHANGE 
xAr = linspace(0,xSize*RangeChecker,25001); % NOTE factor of RangeChecker included to track solutions better
% This 5001 is fixed but could be increased to look for a greater accuracy
% of solutions (will be slower however)
RootLim = 1e-1;  % 1e-1 = default POTENTIALLY CHANGE 
% The peak finding code does not only find solutions that cross the x-axis.
% In an ideal code, we would say that the roots that equal zero are the
% peaks, but due to the size of xAr not being infinite, choose RootLim to
% be large enough to find them (but small enough to exclude other peaks)
Roots = struct;
% Shape finding code. 
% Cache angle-independent Bessel samples; values and sampling are unchanged.
bessel_samples = zeros(length(m), length(xAr));
for jj = 1:length(m)
    bessel_samples(jj,:) = besselj(m(jj),k*xAr);
end

for ii = 1:length(theta)
    
    % This block of code is the peak finding code. Finds all solutions in
    % the range
    thetaVal = theta(ii);
    y = 0; 
    for jj = 1:length(m)
        y = y+BessVals(jj)*bessel_samples(jj,:)*cos(m(jj)*thetaVal+PhiVals(jj));
    end
    absy = abs(y); flipy = max(absy)-absy;
    % A constant shift leaves peak locations unchanged. Octave signal's
    % findpeaks requires nonnegative input, unlike MATLAB's implementation.
    [pks,locs] = findpeaks(flipy);
    pks = pks-max(flipy);
    ylocs = y(locs); xlocs = xAr(locs);
    Sols = xlocs(pks>-RootLim);
    Roots(ii).RawSolutions = Sols; 
    r_0 = Sols;
    
    y_prime_num = 0; y_prime_dom = 0;
    for jj = 1:length(m)
        if m(jj) == 0
            y_prime_dom = y_prime_dom-BessVals(jj)*besselj(1,k*r_0);
        else
            y_prime_num = y_prime_num + BessVals(jj)*besselj(m(jj),k*r_0)*m(jj)*sin(m(jj)*thetaVal+PhiVals(jj));
            y_prime_dom = y_prime_dom + BessVals(jj)*(m(jj)./(k*r_0).*besselj(m(jj),k*r_0)-besselj(m(jj)+1,k*r_0))*cos(m(jj)*thetaVal+PhiVals(jj));
        end
    end
    Roots(ii).AllGradients = 1/k*y_prime_num./y_prime_dom;
    % Store all solutions in range, these are plotted at the end.
    
    % Here is the block where we are trying to find the continuous
    % solutions
    if ii == 1 % Some special considerations for first block
       
        Roots(ii).TrackedSolutions = Sols(Sols>0 & Sols<xSize); % Store solutions we will track. We assume solution will not exceed three times radius at theta = 0.
        r_0 = Roots(ii).TrackedSolutions; % This is for the eval to work
        rSolve = zeros(length(r_0),length(theta)); 
        Roots(ii).Guess = 0; % As first sol, no guess
        Roots(ii).Gradient = tracked_gradient(r_0,k,m,BessVals,PhiVals,thetaVal);
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
        Roots(ii).Gradient = tracked_gradient(r_0,k,m,BessVals,PhiVals,thetaVal);
        
        
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
end

Shape_r_0 = rSolve(Root,:);
Theta = theta;

end

function gradient = tracked_gradient(r,k,m,amplitudes,phases,theta)
% Evaluate derivatives at the tracked roots, rather than every raw candidate.
% Raw root count can change with angle; it need not equal tracked root count.
num = zeros(size(r)); den = zeros(size(r));
for j = 1:numel(m)
    phase = m(j)*theta+phases(j);
    num = num + amplitudes(j)*besselj(m(j),k*r)*m(j)*sin(phase);
    derivative = (besselj(m(j)-1,k*r)-besselj(m(j)+1,k*r))/2;
    den = den + amplitudes(j)*derivative*cos(phase);
end
gradient = num./den/k;
end
