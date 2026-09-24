function F = F_Constraint(X, a, b)
    F = a + (b-a) .* (atand(X)/180 + 0.5);

##    figure(1); clf; hold on;
##    plot(X,F)
end


