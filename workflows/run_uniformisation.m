function result=run_uniformisation(mode,cfg)
switch mode
    case 'analytic'
        result=uniformisation_theory(cfg);
        if cfg.make_plot
            figure; plot(result.x_mm,result.delta_px_MeV_c.'); grid on;
            xlabel('x [mm]'); ylabel('Delta p_x [MeV/c]');
            title(['Thin-element theory: ' strrep(cfg.k4_convention,'_',' ')]);
        end
    case 'track'
        paths=resolve_study_maps(cfg);
        maps=cellfun(@load_field_map,paths,'UniformOutput',false);
        [map,scales,measured]=normalise_uniform_maps(maps,cfg);
        rftrack_init(); RF_Track;
        if cfg.particle_count<2 || cfg.particle_count~=fix(cfg.particle_count)
            error('Azimuthal:InvalidConfig','particle_count must be an integer >=2.');
        end
        mass=RF_Track.electronmass; p=cfg.initial_momentum_MeV_c;
        T=Bunch6d_twiss();
        T.emitt_x=cfg.emittance_m_rad*1e6*p/mass;
        T.beta_x=cfg.beta_m; T.alpha_x=cfg.alpha;
        T.emitt_y=0; T.beta_y=0; T.alpha_y=0;
        bunch=Bunch6d_QR(mass,cfg.population,cfg.charge_e,p,T,cfg.particle_count,0);
        cavity=make_rf_cavity(map,cfg,1);
        drift1=cfg.quadrupole_start_m-cavity.get_length();
        drift2=cfg.target_m-cfg.quadrupole_start_m-cfg.quadrupole_length_m;
        if min(drift1,drift2)<0
            error('Azimuthal:InvalidGeometry','RF map or quadrupole overlaps the next beamline element.');
        end
        lattice=Lattice(); lattice.append(cavity); lattice.append(Drift(drift1));
        q=Quadrupole(cfg.quadrupole_length_m,-cfg.quadrupole_k2_per_m*p);
        q.set_nsteps(max(1,ceil(cfg.quadrupole_length_m/cfg.step_m)));
        lattice.append(q); lattice.append(Drift(drift2));
        reference=Bunch6d(mass,1,cfg.charge_e,[cfg.bore_radius_m*1000 0 0 0 0 p]);
        lattice.autophase(reference); lattice{1}.set_phid(cfg.phase_deg);
        lattice{1}.set_aperture(cfg.bore_radius_m,cfg.bore_radius_m);
        final=lattice.track(bunch); out=final.get_phase_space('%x %Px %y %Py %t %Pz');
        if isempty(out), error('Azimuthal:ParticleLoss','No particles survived the uniformisation line.'); end
        theory=uniformisation_theory(cfg); rt=theory.target_radius_mm;
        bins=linspace(-2*rt,2*rt,cfg.bins);
        counts=hist(out(:,1),bins);
        central=abs(bins)<=cfg.uniform_region_mm;
        if ~any(central) || mean(counts(central))==0
            error('Azimuthal:EmptyRegion','No sampled intensity in the requested uniform region.');
        end
        result.x_mm=bins; result.counts=counts;
        result.relative_density=counts/mean(counts(central));
        result.max_relative_deviation=max(abs(result.relative_density(central)-1));
        result.fraction_in_region=sum(abs(out(:,1))<=cfg.uniform_region_mm)/cfg.particle_count;
        result.survival_fraction=size(out,1)/cfg.particle_count;
        result.field_scales=scales; result.measured_input_g_MV_per_m=measured;
        result.map_files=paths;
        result.description='Fresh RF-Track transport at explicit configured strengths; no optimiser is run.';
        if cfg.make_plot
            figure; plot(bins,result.relative_density); grid on;
            xlabel('x [mm]'); ylabel('Relative density'); title(['Tracked uniformisation: ' cfg.variant]);
        end
    otherwise
        error('Azimuthal:UnknownMode','Uniformisation modes: analytic, track.');
end
end
