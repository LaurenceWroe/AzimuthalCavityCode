# Named cases and provenance

The starting configurations are explicit selections from the published paper and surviving scripts. They do not certify that every setting is the original publication setting. Numerical validation of the full cases awaits the missing maps.

| Case | Explicit settings | Evidence / qualification |
| --- | --- | --- |
| Mixed-mode benchmark | 3 GHz; cell c/(2f); 50 mm pipes, 10 mm bore; shape amplitudes (1,1,1); six rings 0–8 mm; initial momenta 10000,10,1 MeV/c; phases 0,90 degrees | Section III; archived `main_Feb25_Lattice.m`. Bore ratios 0.354579,0.055528 and 1.24 MV analytical voltage come from working code. |
| Momentum scan | 101 logarithmic momenta from 1 to 10000 MeV/c | Same benchmark configuration; original scan workflow |
| Coupler comparison | Single, dual, quad and corrected maps; corrected shape amplitudes (1,.0304,.0363,-.0802,-.257), phases (0,pi/2,0,pi/2,0) | Iteration-5 source shape. Shape generation alone does not tune resonance or external coupling. |
| Uniformisation beamline | 3 GHz, 50 mm cell/pipes/bore; p=10 MeV/c; 200000 particles; emittance 21 micrometre rad, beta=15 m, alpha=15; quadrupole starts .2 m, length .3 m, K2=4.25/m; target 1.7 m | Section V. Surviving script also sets p=20 electron masses (~10.22 MeV/c), later reduces particles and selects TM46810. These later settings are not silently inherited. |
| TM410 | g4=108 MV/m | Reported single-mode strength |
| Superposed TM410+TM610 | g4=151, g6=-1006 MV/m | Reported optimised strengths; both maps must use the same grid |
| Hybrid TM4610 | g4=135 MV/m; expected measured g6/g4=-7.10 | Reported fitted hybrid ratio; design ratio -6.68 differs. The workflow scales g4, leaving the map's actual other harmonics intact. |

Reference target beta=223 m and phase advance=.0678 rad give the thin-theory target half-width ~85.570 mm. They are supplied reference optics, not recalculated from the tracked lattice. Tracking uses fixed configured strengths; it does not rerun the historical optimiser.

## Unresolved factor of two

Published Eq. (5.1) states K4 = 1/(2 epsilon beta^2 tan(Phi)). The surviving uniformisation code uses **2** in the numerator. `cfg.k4_convention='paper_equation'` follows the displayed equation; `'legacy_script'` exposes the factor-of-two alternative.

At p=10 MeV/c with the documented optics, the displayed equation gives g4~52.869 and g6~-436.092 MV/m through Eq. (5.7). Doubling K4 and using the source momentum ~10.22 MeV/c gives g4~108 MV/m. This discrepancy needs scientific review before claiming complete reproduction. Configured tracking strengths above are separately selected reported values and are not silently derived from one convention.

## Units, phase and analysis

Tracking coordinates use mm and momenta MeV/c; lattice lengths use m. CST E/H complex phasors are preserved; H is converted to B with mu0. `map_voltage` integrates Ez exp(+i k z) with z centred on the map, under a rigid v=c trajectory.

Analytical benchmark kicks use a signed charge and the phase in Eqs. (2.20)/(2.22). Native benchmark tracking autophases on axis, treats phase 0 as positive crest gain and compares transverse kicks with the negative-sine convention in the archived script. Each momentum is independently autophased/calibrated. Numerical phase labels across the two modes therefore need this convention, not direct equality.

Uniformisation preserves the surviving source's charge +1, off-axis reference at x=a, RF phase 270 degrees and quadrupole constructor strength -K2*p. These are implementation conventions requiring review with the recovered field phase; they are not a new assertion about particle species. The hybrid's expected ratio is documentation, not a substitute for measuring its actual map harmonics.

Coupler `analyse` returns Fourier coefficients on sampled rings after on-axis voltage normalisation. These are not a radial fit of all gamma coefficients and do not reconstruct the absent CST optimisation. `analytic` returns the configured boundary only.
