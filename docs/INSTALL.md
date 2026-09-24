# Installation and checks

The maintained workflows target GNU Octave. Local validation used Octave 10.3.0, signal 1.4.7, statistics 1.8.0 and RF-Track 2.5.3 on macOS. MATLAB execution is not validated.

On Ubuntu:

```sh
sudo apt-get update
sudo apt-get install octave octave-signal octave-statistics gnuplot-nox fonts-freefont-otf python3
```

On other platforms install Octave, then install the signal and statistics packages through your platform's package manager or Octave package manager. Signal is needed for shape finding; statistics is needed for native RF tracking. Python uses only its standard library. Headless plotting needs a graphics backend and fonts.

Run from the repository root:

```sh
python3 tests/verify_collection.py
python3 tools/extract_notebook_inputs.py --check
octave --no-init-file --no-site-file --no-gui --quiet --eval 'setup_paths; run_checks(false); run_workflow_checks(false);'
```

The `false` arguments explicitly skip native RF-Track. CI runs these checks on a fresh Ubuntu runner and renders the gallery, recording installed package versions in its log.

## RF-Track

Obtain RF-Track separately from its [CERN project](https://gitlab.cern.ch/rf-track), following its installation and licence terms. Its native module must match your Octave/platform ABI. It is not redistributed here.

```sh
export RF_TRACK_PATH=/path/to/directory/containing/RF_Track.oct
octave --no-init-file --no-site-file --no-gui --quiet --eval 'setup_paths; run_checks(true); run_workflow_checks(true);'
```

These checks use a drift and small synthetic fields, including uniformisation beamline transport. They establish runtime compatibility and selected numerical limits, not publication reproduction. Full runs need the external CST maps described in [MAPS](MAPS.md).

CST automation in the archive requires Windows, MATLAB COM (`actxserver`), a licensed CST installation and the original project templates. Mathematica notebooks require an activated Wolfram kernel. Neither tool is required for the Octave examples, retained-data plots or CI.
