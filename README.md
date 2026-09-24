# AzimuthalCavityCode

Code associated with **Controlling the transverse multipole components in rf cavity modes using the azimuthal modulation method**, L. M. Wroe, W. Wuensch and R. J. Apsimon, PRAB **28**, 082002 (2025). [Paper](https://doi.org/10.1103/tjgp-gjq7).

This repository preserves the surviving research code and provides maintained GNU Octave entry points. It is not a frozen publication release: some original scripts contain later experiments. Dense CST maps were removed and are not bundled. A small analytical field map exercises the software without replacing the missing research data.

## Quick start

From the repository root, with Octave and its signal package installed:

```sh
python3 tests/verify_collection.py
octave --no-init-file --no-site-file --no-gui --quiet --eval 'setup_paths; run_checks(false); run_workflow_checks(false);'
```

In Octave:

```matlab
setup_paths
cfg = study_config('benchmark');
r = run_study('benchmark', 'analytic', cfg);
cfg = study_config('coupler');
r = run_study('coupler', 'analytic', cfg); % corrected shape
cfg = uniformisation_config('tm4610');
r = run_study('uniformisation', 'analytic', cfg);
demo_shapes;                 % freshly computed boundaries
demo_saved_fields;           % retained numerical profiles
demo_saved_distributions;    % retained histograms
```

For native tracking, install RF-Track separately and set `RF_TRACK_PATH` to the directory containing `RF_Track.oct`. `demo_rf_map` tracks through the bundled ideal pillbox fixture. Full studies additionally need external maps:

```matlab
cfg = study_config('benchmark');
cfg.map_root = '/path/to/recovered/maps'; % or set AZIMUTHAL_MAP_DIR
r = run_study('benchmark', 'track', cfg); % 'scan' for momentum scan
cfg = study_config('coupler');
r = run_study('coupler', 'analyse', cfg);
cfg = uniformisation_config('superposed'); % tm410 or tm4610 also available
r = run_study('uniformisation', 'track', cfg);
```

Set `cfg.output_dir` to save results; existing result files are protected from overwrite. Set `cfg.make_plot=true` for plots. See [installation](docs/INSTALL.md), [map recovery](docs/MAPS.md), [parameter provenance and unresolved conventions](docs/PARAMETERS.md), [validation limits](docs/VALIDATION.md) and [gallery](docs/GALLERY.md).

## Organisation

| Location | Purpose |
| --- | --- |
| `configs/`, `workflows/`, `src/` | Explicit configurations, maintained entry points and helpers |
| `examples/` | Map-free examples and a small analytic map fixture |
| `tests/`, `.github/workflows/` | Integrity, numerical and automated Linux checks |
| `notebooks/` | Input-only reading copies of the two main Mathematica notebooks |
| `research/` | 252 original files preserved byte-for-byte; historical paths/settings remain |
| `SOURCE_MANIFEST.json` | Archived file paths, lengths and SHA-256 hashes |
| `maps/`, `outputs/` | Local inputs/results, ignored by Git |

Use `setup_paths`, not `addpath(genpath(...))`: archived duplicate function names can shadow maintained copies. [CODE_MAP](docs/CODE_MAP.md) links paper topics to originals; [CHANGES](docs/CHANGES.md) records modifications. No new software licence has been selected. Existing notices are preserved; RF-Track and commercial tools are separate dependencies.
