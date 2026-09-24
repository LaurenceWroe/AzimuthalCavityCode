Dense field maps are intentionally excluded from this collection.

Store regenerated/recovered maps here, or outside this folder. Set
`AZIMUTHAL_MAP_DIR` to an external location if desired; `check_environment`
reports it. Historical scripts do not automatically use this variable: their
`RF_Folder`/`RF_File` selections must be set explicitly before a map-based run.

The converter is callable after `setup_paths`:

```matlab
convert_cst_fields('/path/Mode 1_e__subvol.txt', ...
                   '/path/Mode 1_h__subvol.txt', ...
                   '/path/my_field.dat');
```

Inputs: Cartesian CST exports with two header lines and nine columns:
`x y z Re(Fx) Im(Fx) Re(Fy) Im(Fy) Re(Fz) Im(Fz)`.
Coordinates are mm; E is V/m; H is A/m. The converter preserves complex phase,
converts H to B in tesla, orders coordinates with x fastest, and checks for
matching, complete, uniform grids. Output is a binary MAT file with a `.dat`
extension that Octave/MATLAB `load` can read. It refuses to overwrite a file.

The historical schema contains `a1/a2/a3`, `E1_Mat/E2_Mat/E3_Mat`,
`B1_Mat/B2_Mat/B3_Mat`, `d1/d2/d3`, `loc_x`, `loc_y`.
Coordinates/spacing remain in mm; tracking scripts convert them to metres.

Required studies:

| Study | Historical dataset names | Sampling |
| --- | --- | --- |
| Mixed 0/1/2 benchmark | `260216_Azi` | `0_25_Steps.dat` |
| Coupler comparison | `260216_SinglePort`, `260216_DualPort`, `260216_QuadPort`, `260216_Cancel5`, `260216_Cancel10` | `0_25_Steps.dat` |
| Uniformisation | `250226_TM_410_Pill`, `250310_TM_610_Pill`, `250608_TM4610_6.7` | Current scripts commonly select `0_5_Steps.dat`; paper reports 0.3 mm for the pillbox study |
| Mathematica/CST comparison | `Mathematica/Data/CSTFile_10mm_2/Mode 1_e.txt` | Ordered cylindrical point-list export, NOT this Cartesian converter |

Names are preserved from the working source, not asserted to be publication
versions. Some `260...` paths may refer to later work. Confirm geometry, solver,
phase, normalisation and sampling before comparing with the published figures.
The small mode-frequency files in `research` are metadata, not field maps.
