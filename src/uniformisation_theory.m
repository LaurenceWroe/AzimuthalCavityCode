function result=uniformisation_theory(cfg)
% Published Eq. 5.1 is deliberately distinct from the later script's factor 2.
factor=1;
switch cfg.k4_convention
    case 'paper_equation'
    case 'legacy_script', factor=2;
    otherwise, error('Azimuthal:InvalidConvention','k4_convention: paper_equation or legacy_script.');
end
orders=4:2:12; strengths=zeros(size(orders)); g=strengths;
epsilon=cfg.emittance_m_rad; beta=cfg.beta_m; phi=cfg.reference_phase_advance_rad;
k=2*pi*cfg.frequency_Hz/299792458; L=cfg.cell_length_m; a=cfg.bore_radius_m;
strengths(1)=factor/(2*epsilon*beta^2*tan(phi));
for j=1:numel(orders)
    m=orders(j);
    if j>1, strengths(j)=-(m-3)/(epsilon*beta)*strengths(j-1); end
    % Magnitudes/convention as in Eq. 5.7 at sin(psi)=1, Pref in MeV/c.
    g(j)=cfg.initial_momentum_MeV_c/299792458*(2*pi*cfg.frequency_Hz/L)* ...
         (k*L/2)/sin(k*L/2)*a^m/(besselj(m,k*a)*factorial(m))*strengths(j);
end
result.orders=orders; result.K=strengths; result.g_MV_per_m=g;
result.target_radius_mm=sqrt(pi/2)*sqrt(epsilon*cfg.reference_target_beta_m)*abs(cos(phi))*1000;
result.x_mm=linspace(-a*1000,a*1000,501);
result.delta_px_MeV_c=zeros(numel(orders),numel(result.x_mm));
kick=zeros(size(result.x_mm));
for j=1:numel(orders)
    kick=kick-cfg.initial_momentum_MeV_c*strengths(j)*(result.x_mm/1000).^(orders(j)-1)/factorial(orders(j)-1);
    result.delta_px_MeV_c(j,:)=kick;
end
result.description=['Thin-element theory, ' cfg.k4_convention '; finite-cavity fitted strengths are separate configuration values.'];
end
