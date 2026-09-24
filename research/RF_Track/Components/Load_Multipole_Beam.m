function B = Load_Multipole_Beam(B_macro_particles,B_time,Gamma,std_r)

RF_Track;

% Calculate relativistic beta
rel_beta = sqrt(1 - 1/Gamma.^2); %

% Prep Gaussian bunch
r_norm = randn(B_macro_particles, 1);
theta = unifrnd(0,360, [B_macro_particles, 1]);
B = zeros(B_macro_particles, 6);

% Create bunch
B(:,1) = std_r.*r_norm.*cos(theta);
B(:,3) = std_r.*r_norm.*sin(theta);
B(:,2) = 0.*cos(theta);
B(:,4) = 0.*sin(theta);
B(:,5) = unifrnd(-B_time, B_time,[B_macro_particles, 1]); % Uniform time

B_beta = sqrt(1 - 1 ./ Gamma.^2);
B_Pc = RF_Track.electronmass * B_beta .* Gamma;
B(:,6) = B_Pc;

% create a reference particle
B(1,:) = [ 0 0 0 0 0 RF_Track.electronmass * (rel_beta * Gamma) ];

