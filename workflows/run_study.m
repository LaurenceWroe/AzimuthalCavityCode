function result = run_study(name, mode, cfg)
% Unified, explicit entry point. Never invokes the historical scripts.
% run_study('benchmark','analytic') or run_study('benchmark','track',cfg)
if nargin<2, mode='analytic'; end
if nargin<3, cfg=study_config(name); end
if ~strcmp(name,cfg.name), error('Azimuthal:ConfigMismatch','Configuration belongs to a different study.'); end
if ~isscalar(cfg.frequency_Hz) || cfg.frequency_Hz<=0 || ~isfinite(cfg.frequency_Hz)
    error('Azimuthal:InvalidConfig','frequency_Hz must be positive and finite.');
end
if ~isscalar(cfg.step_m) || ~isfinite(cfg.step_m) || cfg.step_m<=0
    error('Azimuthal:InvalidConfig','step_m must be positive and finite.');
end
if ~isempty(cfg.output_dir)
    file=fullfile(cfg.output_dir,[name '_' mode '.mat']);
    if exist(file,'file'), error('Azimuthal:OutputExists','Choose a fresh output directory: %s',file); end
end
switch name
    case 'benchmark', result=run_benchmark(mode,cfg);
    case 'coupler', result=run_coupler(mode,cfg);
    case 'uniformisation', result=run_uniformisation(mode,cfg);
    otherwise, error('Azimuthal:UnknownStudy','Choose benchmark, coupler, or uniformisation.');
end
result.config=cfg;
result.mode=mode;
if ~isempty(cfg.output_dir)
    if ~exist(cfg.output_dir,'dir'), mkdir(cfg.output_dir); end
    file=fullfile(cfg.output_dir,[name '_' mode '.mat']);
    if exist(file,'file'), error('Azimuthal:OutputExists','Choose a fresh output directory: %s',file); end
    save(file,'result','-v7');
end
end
