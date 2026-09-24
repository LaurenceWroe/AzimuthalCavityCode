
r_points = 3;
theta_points = 5;
r = linspace(0,2,r_points);
theta = linspace(0,2*pi,theta_points);
theta = theta(1:end-1);

r_mat = repmat(r(:)',length(theta),1)';
theta_mat = repmat(theta(:)',length(r),1);

X_mat = r_mat.*cos(theta_mat);
Y_mat = r_mat.*sin(theta_mat);

k = -2;
F = k*r_mat;

[dFr dFt] = gradient(F',r,theta);
dFt = dFt./(repmat(r(:)',length(theta),1));
dFr = dFr'; dFt = dFt';

dFx = dFr .*cos(theta_mat)-dFt.*sin(theta_mat);
dFy = dFr .*sin(theta_mat)+dFt.*sin(theta_mat);



figure();
surf(X_mat,Y_mat,F)
return
