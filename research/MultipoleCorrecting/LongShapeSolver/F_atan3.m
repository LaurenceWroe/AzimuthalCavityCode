%% F_atan3.m - L Wroe
% This functions returns the tan argument between two data arrays between
% the limits of 0 and 2 pi
function theta = F_atan3(x,y)
    theta = atan(y./x);
    for ii = 1:numel(theta)
        if x(ii) >= 0 && y(ii) < 0
            theta(ii) = theta(ii) + 2*pi;
        elseif x(ii) < 0 && y(ii) <= 0
            theta(ii) = theta(ii) + pi;
        elseif x(ii) < 0 && y(ii) > 0
            theta(ii) = theta(ii) + pi;
        end
        
        if theta(ii) < 0.0000000001 % Correct for some slight floating point issue
            theta(ii) = 0;
        end
        if theta(ii) == 2*pi
           theta(ii) = 0; 
        end
        
        if isnan(theta(ii))
           theta(ii) = 0; 
        end
    end
end

