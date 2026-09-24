# Paper and code map

## Maintained entry points

| Task | Entry |
| --- | --- |
| Benchmark / momentum scan | `study_config('benchmark')`, `run_study('benchmark','analytic'/'track'/'scan',cfg)` |
| Corrected shape / coupler map comparison | `study_config('coupler')`, `run_study('coupler','analytic'/'analyse',cfg)` |
| Uniformisation | `uniformisation_config('tm410'/'superposed'/'tm4610')`, `run_study('uniformisation','analytic'/'track',cfg)` |
| CST conversion | `convert_cst_fields(e_file,h_file,output_file)` |
| Small native example | `demo_rf_map` |
| Notebook reading copies | `notebooks/` |

The slash-separated mode names in this table denote alternatives, not executable Octave syntax. See the README for executable examples and PARAMETERS.md for provenance and limits.

## Archived sources

All paths below are relative to `research/`. Associations are based on the code
contents, equations, parameter values and stored data; they are not a claim that
each file's current settings exactly reproduce a published figure.

| Paper | Primary code | Evidence / supporting files |
| --- | --- | --- |
| II–III: field integration | `Mathematica/250211_CavityIntegration.nb`, `250211_IPAC_7.nb` | Ordinary/modified Bessel integrals; 10 mm bore; coefficients 0.3464, 0.0546; integration cutoff 5000 |
| Fig. 4: static/time-dependent field | `Mathematica/plot_E2.m` | Reads `Data/E_m_0_1_2` and the absent `CSTFile_10mm_2/Mode 1_e.txt` |
| Fig. 5: momentum kicks | `RF_Track/Scripts/MultipoleCorrecting/main_Feb25_Lattice.m` | Ring bunch; 3 GHz; fitted coefficients 0.354579 and 0.055528; direct Lorentz, PW and analytic calculations |
| Fig. 6: momentum scan | `RF_Track/Scripts/MultipoleCorrecting/main_Feb25_Lattice_Loop.m` | `logspace(0,4,101)` momentum scan and RMS errors |
| IV: coupler cancellation | `MultipoleCorrecting/main_Dec24.m`, `main_Nov24.m`, `FastShapeSolver.m`, `F_AziShapeCalc_Fast.m` | CST automation, Fourier decomposition, iterative correction coefficients and exported `Shapes/IterationOct_Feb*.txt` |
| IV: tracking/integration comparisons | `RF_Track/Scripts/MultipoleCorrecting/main_Feb25_Tracker.m`, `main_Feb25_Lattice.m` | Single/dual/quad-port and corrected map selections |
| V: beam uniformisation | `RF_Track/Scripts/uniform_beam/main_250312.m` | beta=15 m, alpha=15, emittance=21 mm mrad; quadrupole at 0.2 m; target at 1.7 m; TM410/TM610/TM4610 cases |
| V: earlier variants / saved results | `uniform_beam/main.m`, `main_250226.m`, `main_250311.m`, `Dist/` | Exploratory alternatives and exported histograms |
| Map preprocessing | `RF_Track/Functions/F_CSTFieldConvert2.m` | Complex E/H exports to Cartesian arrays and metadata |

## Configuration cautions found during collection

- `main_Feb25_Lattice.m` finally selects `260216_Cancel10`, not the mixed
  monopole/dipole/quadrupole map, despite retaining the benchmark formulas.
- `main_Feb25_Lattice_Loop.m` selects `260216_Azi`.
- `main_250312.m` finally selects `250608_TM46810`, beyond the paper's
  demonstrated TM4610 case. Earlier lines retain the TM4610 alternatives.
- `FastShapeSolver.m` retains the correction iterations but finally selects
  an m=4, 1.3 GHz case. The new `demo_shapes` selects three explicit 3 GHz cases.
- Beam particle counts, map spacing, signs, normalisations and reference
  momenta in the current source must be checked against the paper before a
  reproduction run. They have not been silently changed to guessed values.
- Files such as `Dist/TwoPill.m` contain Octave saved data, not executable code.
- A few older plotting scripts reference additional historical outputs not
  included in this focused collection; the runnable examples use bundled data.

The earlier broad `Azimuthal/` and `Scripts/Azimuthally/` explorations were not
copied wholesale. The required `customcolormap.m` helper was retained.
