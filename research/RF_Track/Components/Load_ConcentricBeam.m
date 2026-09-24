
function B = Load_ConcentricBeam(rings,p_per_ring,r_beam,Gamma,time)
    RF_Track;
    macro_part = (rings-1)*p_per_ring+1;
    beta = F_Gam2Beta(Gamma);
    B = zeros(macro_part, 6);

    ring_r_temp = linspace(0,r_beam,rings);
    ring_r_arr = ring_r_temp(2:end);

    theta_arr = linspace(0,360,p_per_ring+1);
    theta_arr = theta_arr(1:end-1);

    ### DEFINE A REFERENCE PARTICLE ###
    B(1,:) = [ 0 0 0 0 0 RF_Track.electronmass*(beta*Gamma) ];

    ### CREATE RING POSITIONS ###
    for ii = 1:rings-1
        B(2+(ii-1)*p_per_ring:2+(ii)*p_per_ring-1,1) = ring_r_arr(ii).*cosd(theta_arr);
        B(2+(ii-1)*p_per_ring:2+(ii)*p_per_ring-1,3) = ring_r_arr(ii).*sind(theta_arr);
    endfor

    ### CREATE UNIFORM TIME DIST ###
    B(:,5) = unifrnd(-time, time,[macro_part, 1]);

    ### CREATE MOMENTUM DIST ###
    B(:,6) = RF_Track.electronmass * beta .* Gamma;

end

