# AzimuthalCavityCode

Collected code associated with **Controlling the transverse multipole components
in rf cavity modes using the azimuthal modulation method**, L. M. Wroe,
W. Wuensch and R. J. Apsimon, *Physical Review Accelerators and Beams* **28**,
082002 (2025). DOI: https://doi.org/10.1103/tjgp-gjq7

This is a collection of the surviving working code, not a frozen publication
release. Some scripts were subsequently reused for other configurations.
Dense electromagnetic maps are intentionally excluded. No Git repository has
been initialized.

## Start here

The runnable examples use paths relative to this folder. In GNU Octave:

```matlab
cd('/Users/wroe/AzimuthalCavityCode')
setup_paths
check_environment
demo_shapes;                 % original root-tracking algorithm, with fixes
demo_saved_fields;           % retained Mathematica output; no CST overlay
demo_saved_distributions;    % saved results, not a fresh tracking simulation
demo_rftrack_drift;           % original beam helper + RF-Track, no RF maps
```

From a terminal, run the numerical checks:

```sh
cd /Users/wroe/AzimuthalCavityCode
python3 tests/verify_collection.py
octave --no-gui --quiet --eval 'setup_paths; run_checks;'
```

Octave needs the `signal` package for shape finding. The RF-Track check also
needs `statistics` and an installed RF-Track Octave module on the Octave path.
`run_checks(false)` explicitly skips the RF-Track check; it does not report that
part as passed. RF-Track and commercial applications are external dependencies,
not bundled here. Do not add the whole collection recursively to the path:
historical duplicate function names could shadow the tested copies.

## Folder layout

| Folder/file | Purpose |
| --- | --- |
| `research/MultipoleCorrecting/` | Original shape solver, correction iterations, CST automation and exported shapes |
| `research/Mathematica/` | Original integration notebooks, plotting scripts and selected compact numerical outputs |
| `research/RF_Track/Scripts/MultipoleCorrecting/` | Original momentum benchmark, momentum scan and coupler comparisons |
| `research/RF_Track/Scripts/uniform_beam/` | Original uniformisation studies and saved distributions |
| `research/RF_Track/Components/`, `Functions/` | Required original beam generators, converters and supporting functions |
| `src/`, `examples/` | Small runnable extraction; modifications are documented separately |
| `tests/` | Numerical, conversion, runtime and collection-integrity checks |
| `maps/` | Optional local dense maps; ignored by the supplied future Git rules |
| `outputs/` | Generated figures/results; ignored by the supplied future Git rules |
| `SOURCE_MANIFEST.json` | Original relative paths, byte counts and SHA-256 checksums |

See [CODE_MAP.md](docs/CODE_MAP.md) for paper-to-script mapping,
[CHANGES.md](docs/CHANGES.md) for the fixes, [VALIDATION.md](docs/VALIDATION.md)
for actual test results, and [maps/README.md](maps/README.md) for data requirements.

## What runs, and what remains to reproduce

The map-free checks exercise shape generation, load the retained numerical
results, convert a small synthetic CST grid, and track the original ring-shaped
test bunch through a drift. They do **not** establish reproduction of the
paper's full RF simulations or recompute the saved Mathematica results.

The files under `research/` are byte-for-byte copies. They retain original
absolute paths, repeated parameter assignments, interactive plotting blocks,
and later experimental settings. Do not run them blindly as publication cases.
The last active assignment wins. Full RF runs require recovering/regenerating
maps and explicitly selecting the intended case, then updating the historical
input/helper paths. The snapshots are kept intact so those changes can be made
against a known baseline.

CST automation uses Windows MATLAB COM (`actxserver`) and local CST templates.
It cannot execute on macOS. Mathematica notebooks need an activated kernel;
their saved outputs can be read by Octave without Mathematica.

## Collection scope

252 original files, about 33 MB, were collected from the existing code workspace.
Included: directly related scripts and helper dependencies, historical variants
in the relevant study folders, shape coordinate files, Mathematica notebooks,
selected small MAT outputs, saved beam histograms, and mode-frequency metadata.
The large notebook files retain their original cached outputs to preserve them.
Not copied: dense CST field exports, simulation caches, application binaries,
autosaves, workstation snapshots, and unrelated accelerator projects.

Source code comments and any existing third-party notices have been preserved.
No new software licence has been assigned by this collection step.
