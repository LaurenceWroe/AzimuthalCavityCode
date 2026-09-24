function result = run_benchmark(mode,cfg)
theta=(0:cfg.theta_samples-1)*2*pi/cfg.theta_samples;
result.theta_rad=theta; result.radii_mm=cfg.radii_mm;
switch mode
    case 'analytic'
        for n=1:numel(cfg.phase_deg)
            result.kicks(n)=analytic_kicks(cfg.radii_mm,theta,cfg.phase_deg(n),cfg);
        end
        result.description='Eqs. 2.20/2.22 under rigid, parallel, ultrarelativistic assumptions; no tracking.';
    case {'track','scan'}
        paths=resolve_study_maps(cfg); map=load_field_map(paths{1});
        rftrack_init(); RF_Track;
        momenta=cfg.initial_momentum_MeV_c;
        if strcmp(mode,'scan'), momenta=cfg.scan_momentum_MeV_c; end
        mass=RF_Track.electronmass;
        [t,r]=ndgrid(theta,cfg.radii_mm);
        initial=zeros(numel(r),6);
        initial(:,1)=r(:).*cos(t(:)); initial(:,3)=r(:).*sin(t(:));
        if cfg.radii_mm(1)~=0
            error('Azimuthal:InvalidConfig','Benchmark requires an on-axis first ring for voltage calibration.');
        end
        if cfg.phase_deg(1)~=0
            error('Azimuthal:InvalidConfig','Benchmark phase list must start with 0 degrees.');
        end
        for p=1:numel(momenta)
            initial(:,6)=momenta(p);
            bunch=Bunch6d(mass,size(initial,1),cfg.charge_e,initial);
            lattice=Lattice(); lattice.append(make_rf_cavity(map,cfg));
            reference=Bunch6d(mass,1,cfg.charge_e,[0 0 0 0 0 momenta(p)]);
            lattice.autophase(reference);
            for j=1:numel(cfg.phase_deg)
                lattice{1}.set_phid(cfg.phase_deg(j));
                final=lattice.track(bunch);
                out=final.get_phase_space('%x %Px %y %Py %t %Pz %id');
                if size(out,1)~=size(initial,1)
                    error('Azimuthal:ParticleLoss','Benchmark lost %d particles; inspect aperture, map and momentum.',size(initial,1)-size(out,1));
                end
                [~,order]=sort(out(:,7)); out=out(order,:);
                entry.momentum_MeV_c=momenta(p); entry.phase_deg=cfg.phase_deg(j);
                entry.delta.pz=reshape(out(:,6)-momenta(p),numel(theta),[]).';
                entry.delta.px=reshape(out(:,2),numel(theta),[]).';
                entry.delta.py=reshape(out(:,4),numel(theta),[]).';
                if j==1, gain=mean(entry.delta.pz(1,:)); end
                % Native autophasing convention of main_Feb25_Lattice.m:
                % positive crest gain, and negative transverse sine coefficient.
                prediction_cfg=cfg; prediction_cfg.charge_e=1;
                entry.prediction=analytic_kicks(cfg.radii_mm,theta,-cfg.phase_deg(j),prediction_cfg,gain);
                for component={'pz','px','py'}
                    key=component{1}; difference=entry.delta.(key)-entry.prediction.(key);
                    entry.rmse.(key)=sqrt(mean(difference.^2,2));
                end
                result.runs(p,j)=entry;
            end
        end
        result.map_file=paths{1};
        result.description='RF-Track versus analytical kicks; native RF phase aligned to the archived benchmark.';
    otherwise
        error('Azimuthal:UnknownMode','Benchmark modes: analytic, track, scan.');
end
if cfg.make_plot
    figure;
    if strcmp(mode,'analytic')
        plot(theta*180/pi,result.kicks(1).pz.');
        title('Analytical longitudinal kicks (no RF tracking)');
    else
        plot(theta*180/pi,result.runs(1,1).delta.pz.');
        title('Tracked longitudinal kicks, first momentum');
    end
    xlabel('theta [deg]'); ylabel('Delta p_z [MeV/c]'); grid on;
end
end
