
function B = Load_ConcentricBeam_2(rings,p_per_ring,r_beam,Gamma,time)
    RF_Track;
    macro_part = rings*p_per_ring;
    beta = F_Gam2Beta(Gamma);
    B = zeros(macro_part, 6);

    ring_r_arr = linspace(0,r_beam,rings);

    theta_arr = linspace(0,360,p_per_ring+1);
    theta_arr = theta_arr(1:end-1);

    ### CREATE RING POSITIONS ###
    for ii = 1:rings
        B(1+(ii-1)*p_per_ring:1+(ii)*p_per_ring-1,1) = ring_r_arr(ii).*cosd(theta_arr);
        B(1+(ii-1)*p_per_ring:1+(ii)*p_per_ring-1,3) = ring_r_arr(ii).*sind(theta_arr);
    endfor

    ### CREATE UNIFORM TIME DIST ###
    B(:,5) = unifrnd(-time, time,[macro_part, 1]);

    ### CREATE MOMENTUM DIST ###
    B(:,6) = RF_Track.electronmass * beta .* Gamma;

end

