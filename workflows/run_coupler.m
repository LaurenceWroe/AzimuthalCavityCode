function result=run_coupler(mode,cfg)
switch mode
    case 'analytic'
        k=2*pi*cfg.frequency_Hz/299792458;
        [r,t]=F_AziShapeCalc_Fast(cfg.frequency_Hz,1,32/k,cfg.orders, ...
                               cfg.shape_amplitudes,cfg.shape_phase_rad,1);
        result.radius_m=r; result.theta_rad=t;
        result.description='Iteration-5 unscaled boundary from archived coefficients; no CST tuning or coupler-field prediction.';
        if cfg.make_plot
            figure; plot(r.*cos(t)*1000,r.*sin(t)*1000);
            xlabel('x [mm]'); ylabel('y [mm]'); axis equal; grid on;
            title('Correcting boundary before CST frequency/coupling tuning');
        end
    case 'analyse'
        paths=resolve_study_maps(cfg);
        if cfg.radii_mm(1)~=0, error('Azimuthal:InvalidConfig','First integration ring must be on axis.'); end
        if numel(paths)~=numel(cfg.labels), error('Azimuthal:InvalidConfig','Provide a label for each map.'); end
        for j=1:numel(paths)
            map=load_field_map(paths{j}); v=map_voltage(map,cfg);
            reference=mean(v.voltage_V(1,:));
            if abs(reference)<1e-12, error('Azimuthal:ZeroVoltage','Cannot normalise a map with zero on-axis voltage.'); end
            entry.label=cfg.labels{j}; entry.map_file=paths{j};
            entry.on_axis_voltage_V=reference;
            entry.normalised_voltage=real(v.voltage_V/reference);
            spectrum=fft(entry.normalised_voltage,[],2)/cfg.theta_samples;
            entry.cos_coeff=2*real(spectrum(:,1:max(cfg.orders)+1));
            entry.sin_coeff=-2*imag(spectrum(:,1:max(cfg.orders)+1));
            entry.cos_coeff(:,1)=entry.cos_coeff(:,1)/2;
            entry.sin_coeff(:,1)=0;
            entry.relative_peak_variation=max(abs(bsxfun(@minus,entry.normalised_voltage,mean(entry.normalised_voltage,2))),[],2);
            result.cavities(j)=entry;
        end
        result.theta_rad=v.theta_rad; result.radii_mm=v.radii_mm;
        result.description='Rigid v=c voltage integration and Fourier coefficients on each ring, normalised to the on-axis voltage.';
        if cfg.make_plot
            figure; hold on;
            for j=1:numel(paths)
                plot(v.theta_rad*180/pi,result.cavities(j).normalised_voltage(end,:),'DisplayName',cfg.labels{j});
            end
            key=legend('show'); set(key,'interpreter','none'); grid on;
            xlabel('theta [deg]'); ylabel('V_z / V_z(0)');
        end
    otherwise
        error('Azimuthal:UnknownMode','Coupler modes: analytic (boundary), analyse (maps).');
end
end
