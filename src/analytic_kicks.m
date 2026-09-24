function result = analytic_kicks(r_mm, theta, phase_deg, cfg, voltage_MV)
% Eqs. 2.20/2.22, normal multipoles. Voltages use the unsigned field convention.
% Returned momentum components are MeV/c. charge_e is explicit.
if nargin < 5, voltage_MV = cfg.analytic_voltage_MV; end
[t,r] = meshgrid(theta,r_mm/(cfg.bore_radius_m*1000));
pz = zeros(size(r)); px = pz; py = pz;
for j = 1:numel(cfg.orders)
    m = cfg.orders(j); g = cfg.bore_ratios(j);
    pz = pz + g*r.^m.*cos(m*t);
    if m>0
        px = px + m*g*r.^(m-1).*cos((m-1)*t);
        py = py - m*g*r.^(m-1).*sin((m-1)*t);
    end
end
result.pz = cfg.charge_e*voltage_MV*cosd(phase_deg)*pz;
factor = cfg.charge_e*voltage_MV*299792458/(2*pi*cfg.frequency_Hz*cfg.bore_radius_m)*sind(phase_deg);
result.px = factor*px; result.py = factor*py;
end
