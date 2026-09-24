function result = demo_rftrack_drift()
% Exercise the original concentric-beam helper and RF-Track without maps.
% This is a runtime check, NOT validation of the paper's RF cavity results.
if ~exist('OCTAVE_VERSION', 'builtin')
    error('Azimuthal:OctaveRequired', 'This RF-Track interface uses GNU Octave.');
end
rftrack_init(); RF_Track;
mass = RF_Track.electronmass;
pz = 10; gamma = sqrt(1+(pz/mass)^2);
phase = Load_ConcentricBeam_2(6, 24, 8, gamma, 0);
b0 = Bunch6d(mass, 1, -1, phase);
lattice = Lattice();
lattice.append(Drift(0.15));
b1 = lattice.track(b0);
result.initial = b0.get_phase_space('%x %Px %y %Py %t %Pz');
result.final = b1.get_phase_space('%x %Px %y %Py %t %Pz');
result.expected_time_mm_c = 150/sqrt(1-1/gamma^2);
fprintf('Tracked %d concentric-ring particles through a 150 mm drift.\n', rows(phase));
end
