function rftrack_init()
% RF-Track must be installed separately; support clean Octave startup.
if ~exist('OCTAVE_VERSION','builtin')
    error('Azimuthal:OctaveRequired','RF-Track workflows use its GNU Octave module.');
end
module_dir = getenv('RF_TRACK_PATH');
if ~isempty(module_dir), addpath(module_dir); end
if isempty(which('RF_Track'))
    error('Azimuthal:MissingRFTrack', ['RF_Track.oct is not on the Octave path. ' ...
          'Install RF-Track separately and set RF_TRACK_PATH to its module directory. See docs/INSTALL.md.']);
end
pkg('load','statistics');
RF_Track;
end
