function paths = resolve_study_maps(cfg)
% Report all required missing maps before loading RF-Track or allocating beams.
paths = cell(size(cfg.map_files)); missing = {};
for n = 1:numel(paths)
    file = cfg.map_files{n};
    if isempty(file), error('Azimuthal:MissingMap', 'An empty map filename was supplied.'); end
    if file(1) == '/' || ~isempty(regexp(file, '^[A-Za-z]:[\\/]', 'once'))
        paths{n} = file;
    else
        paths{n} = fullfile(cfg.map_root, file);
    end
    if ~exist(paths{n}, 'file'), missing{end+1} = paths{n}; end
end
if ~isempty(missing)
    error('Azimuthal:MissingMap', ['Required field maps are absent:\n  %s\n' ...
          'Set cfg.map_root (or AZIMUTHAL_MAP_DIR), and supply the files named in cfg.map_files.\n' ...
          'See docs/MAPS.md for CST export instructions. The bundled demo is not a paper map.'], ...
          strjoin(missing, '\n  '));
end
end
