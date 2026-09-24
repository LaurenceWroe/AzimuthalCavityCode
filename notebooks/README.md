# Input-only Mathematica reading copies

The two notebooks here contain only Input/Code cells extracted from the primary archived notebooks. Cached output, graphics and cell-history metadata are removed. The unmodified originals remain under `research/Mathematica/` with manifest checksums.

These are reading and editing starting points, not newly validated executable publication notebooks. They retain original input expressions and historical settings. Review directory/export statements, choose a working output directory and use the archived `research/Mathematica/Data` inputs where required before evaluating. An activated Mathematica kernel is required; fresh kernel evaluation has not been validated.

Rebuild with `python3 tools/extract_notebook_inputs.py`; verify extraction with `--check`. The parser balances Mathematica expressions, strings and nested comments rather than deleting output cells with a regular expression.
