function status = check_environment()
root = setup_paths();
status.runtime = version;
status.rftrack = which('RF_Track');
status.findpeaks = which('findpeaks');
status.maps_root = getenv('AZIMUTHAL_MAP_DIR');
if isempty(status.maps_root), status.maps_root = fullfile(root, 'maps'); end
fprintf('Runtime: %s\n', status.runtime);
fprintf('findpeaks: %s\n', status.findpeaks);
fprintf('RF_Track: %s\n', status.rftrack);
fprintf('External map directory: %s\n', status.maps_root);
fprintf('Full CST maps are intentionally not included.\n');
end
