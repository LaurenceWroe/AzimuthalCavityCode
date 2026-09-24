# Changes relative to the collected research snapshot

`research/` is unchanged. `SOURCE_MANIFEST.json` records the source path, length
and checksum for every copied file. The original workspace was not edited.

## Runnable extraction

- `src/F_AziShapeCalc_Fast.m` derives from
  `research/MultipoleCorrecting/F_AziShapeCalc_Fast.m`.
  - Replaced toolbox `physconst('lightspeed')` with the exact SI value 299792458.
  - Shifted the peak-finder input to be nonnegative for Octave's `signal`
    implementation and shifted returned heights back before the original
    threshold. A constant shift preserves peak positions.
  - Fixed a reproduced dimension error: gradients were computed at all raw
    root candidates while the next-angle predictor uses only tracked roots.
    When the raw root count changed, addition of vectors of different lengths
    failed. Gradients are now evaluated at the tracked roots themselves.
  - Cached the angle-independent Bessel samples. The radial sampling grid and
    original branch-following method remain the same. This is still an
    approximate sampled root finder; it has not been certified for arbitrary
    conditional multipole configurations.
- `src/F_besselzero.m`, `F_Gam2Beta.m`, and `Load_ConcentricBeam_2.m` are exact
  copies of the original helpers. Existing author/copyright comments remain.
- `convert_cst_fields.m` extracts the converter into a callable function with
  explicit input/output paths. It sorts/checks Cartesian grids, preserves
  complex fields, corrects `loc_y` to use the y-axis minimum, writes binary MAT
  format, and prevents overwriting an existing map. The original converter
  remains in `research` unchanged.
- `demo_saved_fields.m` extracts the retained-data plotting part of
  `plot_E2.m`. It omits the unavailable CST overlay and uses repository-relative
  paths. Stored field amplitudes use the original numerical normalisation;
  they are not newly calibrated CST voltages.
- `demo_saved_distributions.m` loads the saved histograms and applies the
  original central-bin normalisation. It does not execute the optimiser.
- `demo_rftrack_drift.m` uses the original ring generator and a simple drift
  to check that the RF-Track installation actually loads and tracks a bunch.

No dense maps, CST simulations or synthetic substitutes for the paper's maps
were generated. The synthetic grid used in the converter test is tiny and
temporary; it is strictly a software-format test.

## Reproducibility cleanup

- Added named benchmark, coupler and three uniformisation configurations and `run_study` dispatch. These are maintained extractions, not literal execution of overwritten historical settings.
- Added external-map resolution, grid validation, complex phasor preservation, ring voltage/Fourier analysis, fixed-strength native tracking and analytical theory. Full optimisers and CST tuning remain archival. Formula and phase differences are explicit in PARAMETERS.md.
- Added clean-start native module setup, a small analytic fixture, independent analytical checks, missing-input checks, native integration tests and Ubuntu CI. Native constructors must be initialized in each calling function's scope.
- CST conversion preserves conductor NaNs while rejecting infinite fields/nonfinite coordinates.
- Added structural input-only notebook extraction and a captioned gallery. Original files retain their checksums; `research/README.md` is new navigation guidance.
- No licence was assigned; external binaries and dense maps remain excluded.
