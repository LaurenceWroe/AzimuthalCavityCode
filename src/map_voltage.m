function result = map_voltage(map, cfg)
% Eq. 2.1: rigid v=c longitudinal integration, using the paper's +i omega t.
theta = (0:cfg.theta_samples-1)*2*pi/cfg.theta_samples;
z = linspace(map.axes_mm{3}(1),map.axes_mm{3}(end),cfg.integration_samples);
time_factor = exp(1i*2*pi*cfg.frequency_Hz/299792458*(z-mean(z))/1000);
voltage = zeros(numel(cfg.radii_mm), numel(theta));
for j = 1:numel(cfg.radii_mm)
    [tgrid,zgrid] = ndgrid(theta,z);
    x = cfg.radii_mm(j)*cos(tgrid); y = cfg.radii_mm(j)*sin(tgrid);
    ez = interpn(map.axes_mm{1},map.axes_mm{2},map.axes_mm{3},map.E3_Mat,x,y,zgrid,'linear');
    if any(~isfinite(ez(:)))
        error('Azimuthal:MapDomain', 'Requested integration ring leaves the map or intersects a wall.');
    end
    voltage(j,:) = trapz(z/1000,bsxfun(@times,ez,time_factor),2).';
end
result.theta_rad = theta;
result.radii_mm = cfg.radii_mm;
result.voltage_V = voltage;
end
