# External maps and regeneration

Dense publication maps were intentionally removed. Recover the original exports if possible; regenerating them requires the original CST models/templates and tuning choices as well as the source code. No unavailable template is supplied by this repository.

Set `AZIMUTHAL_MAP_DIR` before constructing a configuration, or assign `cfg.map_root`. Expected paths relative to that directory are:

```
benchmark/mixed_012.dat
coupler/single_port.dat
coupler/dual_port.dat
coupler/quad_port.dat
coupler/corrected.dat
uniformisation/tm410.dat
uniformisation/tm610.dat
uniformisation/tm4610.dat
```

These are new descriptive filenames, not claims about historical export names. Override `cfg.map_files` with recovered filenames (absolute paths also work). Missing files produce a list before RF-Track initialization.

## Recovery / regeneration procedure

1. Select the named case and reconcile the uncertainties in [PARAMETERS](PARAMETERS.md). Consult [CODE_MAP](CODE_MAP.md) for the corresponding original scripts, shape coordinates and frequency metadata.
2. On a licensed Windows CST/MATLAB workstation, restore the project templates referenced by `research/MultipoleCorrecting`. Adapt paths in a working copy. Use the corresponding exported boundary or shape routine to construct the cell, pipes and coupler geometry. The analytic boundary alone does not specify every 3D coupler detail.
3. Reproduce the mode selection, resonance tuning, mesh convergence, excitation/coupling and field normalisation in the relevant source/paper. Record changes. Typical historical exports use .25 mm grids (some uniformisation exports .3 mm); refine and establish convergence for the actual model rather than treating these as universal tolerances.
4. Export E and H on the **same complete uniform Cartesian grid**, including the propagation region/pipes required by that model. Preserve both real and imaginary components and the phase convention. ASCII input expects two header lines followed by nine columns: x y z ReX ImX ReY ImY ReZ ImZ. Coordinates are mm, E V/m, H A/m.
5. Convert from Octave: `setup_paths; convert_cst_fields('E.txt','H.txt','mixed_012.dat');`. Move the result to the configured external map directory. The converter refuses overwrites and rejects mismatched/incomplete/uneven grids. NaN field values marking conductors are preserved; infinite fields and nonfinite coordinates are rejected.
6. Record project/export versions, mesh, frequency, mode, field units, amplitude and phase reference, converter commit, and SHA-256 hashes beside the maps. Verify symmetry, on-axis voltage, multipole content, transit-time factors and integration-step/grid convergence before comparing paper figures. Small runtime tests alone do not validate recovered physics.

## Converted schema

The MAT-format `.dat`/`.mat` file contains `a1,a2,a3` coordinate arrays (mm), `E1_Mat,E2_Mat,E3_Mat` (complex V/m), `B1_Mat,B2_Mat,B3_Mat` (complex tesla), spacings `d1,d2,d3` (mm), and `loc_x,loc_y` (mm). Arrays follow `ndgrid(x,y,z)` ordering. Each dimension has at least two points. The loader validates grid geometry and dimensions. Native tracking translates z to an element whose length is max(z)-min(z); this must represent the intended complete field region.

Uniformisation normalisation samples the middle z slice at bore radius a and extracts the configured normal harmonic. It rejects a significant skew component rather than guessing an angular rotation. This assumes an appropriate standing-wave central slice. Combined maps must share grids. Sampling into conductor NaNs is an error in voltage/normalisation analysis; choose valid paths.

## Small software fixture

`examples/data/tm010_demo.mat` is an analytic ideal pillbox field, not a CST export or paper result. `demo_rf_map` exercises the field-loading and native tracking path, with a check against the analytic on-axis transit-time voltage. [Fixture provenance](../examples/data/README.md) gives its scope. `generate_example_map` can also create small order-4/6 fields for software tests; those are not physical replacements for the removed uniformisation maps.
