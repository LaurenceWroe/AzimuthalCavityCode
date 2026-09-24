# Validation record

Collection checked on 24 September 2026, macOS, GNU Octave 10.3.0,
signal 1.4.7, statistics 1.8.0 and RF-Track 2.5.3. The collection is now versioned in a private GitHub repository.

## Passed

- **Collection integrity:** all 252 research files match the collection-time
  source SHA-256 checksums and lengths. Original source files were left intact.
- **Shape solver:** 361 angular samples for a 3 GHz pillbox, equal-strength
  m=0/1/2 cavity, and iteration-5 corrected cavity. Positive finite radii,
  closure, branch continuity, and field-zero boundary residuals checked.
- **Independent shape checks:** pillbox radius agrees with the first zero of
  J0 within 11 micrometres (the solver samples rather than refines its roots);
  mixed-mode boundary agrees with saved `QuadDip.txt` within 50 micrometres.
  Maximum normalised boundary residuals were 0.000153, 0.000514 and 0.000351.
- **Retained data:** six Mathematica field profiles, 1001 z samples each,
  load and integrate with finite results. The stored beam histograms also load
  and normalise. These are existing results, not recomputed simulations.
- **CST converter:** shuffled E/H coordinates on a 3-by-5-by-2 asymmetric
  grid, complex components, H-to-B units, independent x/y origins, binary
  save/load roundtrip, mismatched/incomplete grids and overwrite protection.
- **RF-Track:** loaded the installed native module and tracked 144 particles
  from the unchanged `Load_ConcentricBeam_2` through a 150 mm drift. Transverse
  coordinates and momenta are conserved; time of flight agrees with 150/beta
  in mm/c. This is a runtime/helper check, not a cavity-field test.
- **Plotting:** all three plotting examples rendered to PNG using Octave's
  gnuplot backend. Generated examples are in `outputs/` and excluded from
  Git tracking. The shapes and distribution plots were visually checked.

The numerical suite exits successfully. This Octave installation prints
`ignoring const execution_exception& while preparing to exit` even after a
successful process (exit 0). RF-Track also reports that its online update check
is unavailable. Neither prevents the measured numerical checks from passing.

## Not validated / unavailable

| Work | Reason |
| --- | --- |
| Full benchmark/coupler/uniformisation tracking | Dense input maps intentionally absent; original scripts also retain changing experimental settings and workstation paths |
| Published CST overlay in Fig. 4 | Required 10 mm CST point-list export is absent |
| CST model generation | Requires Windows MATLAB COM, CST and original templates; current host is macOS |
| Fresh Mathematica integration | Initial kernel check reported an activation/licence error; a retry with normal local access stalled and was stopped |
| MATLAB execution | Installed R2023a startup did not complete; runtime check was stopped. Runnable extraction was tested in Octave |

No claim is made that the collection reproduces every paper figure. The next
reproduction step is to select the publication configurations explicitly and
recover/regenerate their input maps. See `maps/README.md`.

## Relocation check

The checksum check and complete map-free suite also passed from the final
`/Users/wroe/AzimuthalCavityCode` folder while the working directory was `/tmp`.
The runtime examples therefore do not need the original code workspace.
The native RF-Track installation remains an external dependency. The final
run log is `outputs/relocated-checks.log`.

## Maintained workflows (24 September 2026)

Clean Octave startup (`--no-init-file --no-site-file`) with explicit `RF_TRACK_PATH` passed both suites. New checks cover the monopole/dipole analytical limits, an independent finite-difference Panofsky–Wenzel derivative, named configurations, the explicit factor-of-two convention, actionable missing-map errors, analytic transit-time voltage and ring Fourier decomposition.

Native RF-Track 2.5.3 passed the ideal-map demo: predicted and tracked on-axis gains both 0.0031808949 MeV/c (linear interpolation, 10000 MeV/c input). Small generated order-4/6 fields also exercised normalisation, the uniformisation beamline and a two-momentum scan. These tests check software integration and finite transport; they do not validate the publication's missing CST maps or optimised distributions. The research default remains cubic interpolation; the coarse fixture shows why interpolation/grid convergence matters.

All 252 archived files still match their hashes. The two input-only notebook copies are checked against a structural extraction of the originals (2 and 24 Input/Code cells); no fresh Mathematica evaluation is claimed. The gallery was rendered and inspected. Ubuntu CI checks archive integrity, extraction, map-free numerical tests and rendering without proprietary dependencies; see the repository Actions log for the actual run status.
