function cavity = make_rf_cavity(map, cfg, scale)
RF_Track; % Native module installs constructors in the calling scope.
if nargin < 3, scale = cfg.field_scale; end
if ~isscalar(scale) || ~isfinite(scale), error('Azimuthal:InvalidScale','Field scale must be finite and scalar.'); end
constructor=RF_FieldMap_CINT;
if isfield(cfg,'interpolation')
    switch cfg.interpolation
        case 'linear', constructor=RF_FieldMap;
        case 'cubic'
        otherwise, error('Azimuthal:InvalidInterpolation','Choose linear or cubic.');
    end
end
% Preserve the full complex phasors, unlike the old real(E)/imag(B) projection.
cavity = constructor(map.E1_Mat*scale,map.E2_Mat*scale,map.E3_Mat*scale, ...
                         map.B1_Mat*scale,map.B2_Mat*scale,map.B3_Mat*scale, ...
                         map.loc_x*1e-3,map.loc_y*1e-3, ...
                         map.d1*1e-3,map.d2*1e-3,map.d3*1e-3,-1,cfg.frequency_Hz,+1);
cavity.set_odeint_algorithm('rk2');
cavity.set_nsteps(max(1,ceil(cavity.get_length()/cfg.step_m)));
cavity.set_tt_nsteps(max(1,ceil(cavity.get_length()*1000)));
end
