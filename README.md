# Chin EMG OSA Severity Assessment — MATLAB Code

MATLAB implementation accompanying:

> A. Rehman, H. Saleh, A. Khandoker, and M. Al-Qutayri, “Chin electromyography-based explainable machine learning framework for obstructive sleep apnea severity assessment,” *Expert Systems with Applications*, 2026. DOI: [10.1016/j.eswa.2026.133654](https://doi.org/10.1016/j.eswa.2026.133654).

This repository is a de-identified, version-controlled release of the analysis code described as **Supplementary Code SC1**. It covers:

- chin EMG preprocessing and respiratory-event segmentation;
- motor-unit decomposition;
- the canonical 41-feature sEMG representation;
- subject-wise split and leave-one-subject-out (LOSO) evaluation;
- subject-level SHAP analysis;
- the 1D CNN–BiLSTM baseline;
- error/confounding analyses; and
- an external UCDDB feature-extraction example.

## Important release status
This package is a public research-code release candidate (`v1.0.0-rc1`) prepared from the submitted supplementary archive. The code has been statically reviewed and de-identified, and all five included automated tests passed in the author's local MATLAB environment. Some raw-data workflows depend on external MATLAB packages and may require local path configuration or version-specific interface adaptation. See `PACKAGE_VALIDATION_REPORT.md` and `docs/REPRODUCIBILITY.md` for the validation scope and known limitations.

## Data availability

The ACPN recordings and ACPN-derived feature matrices are **not included**. They contain identifiable clinical information and are governed by institutional and national data-protection requirements. Users with authorized access supply their own local paths through private manifest files. See `docs/DATA_ACCESS.md`.

The UCDDB dataset is publicly available separately. This repository does not redistribute it.

## External dependencies

The repository does not redistribute third-party code. Install these dependencies and add them to the MATLAB path:

1. **hdEMG-Decomposition**, version 0.1 or a compatible commit  
   https://github.com/neuromechanist/hdEMG-Decomposition  
   https://www.mathworks.com/matlabcentral/fileexchange/117970-hdemg-decomposition
2. **EMG Feature Extraction Toolbox (Jx-EMGT)**, version 1.4  
   https://github.com/JingweiToo/EMG-Feature-Extraction-Toolbox  
   https://www.mathworks.com/matlabcentral/fileexchange/71514-emg-feature-extraction-toolbox

See `docs/EXTERNAL_DEPENDENCIES.md` for citations and licenses.

## MATLAB requirements

Recommended: MATLAB R2024a, matching the manuscript-era implementation. The code also uses functions from:

- Signal Processing Toolbox;
- Statistics and Machine Learning Toolbox;
- Deep Learning Toolbox (CNN–BiLSTM only);
- Communications Toolbox if required by the installed hdEMG dependency.

The hdEMG-Decomposition release itself lists MATLAB R2021b or later and additional toolbox requirements.

## Repository setup

1. Clone or download this repository.
2. Install the two external dependencies above.
3. Copy `config/local_paths.example.txt` to `config/local_paths.m`.
4. Edit `config/local_paths.m` so the two dependency paths point to your local installations.
5. In MATLAB, change directory to the repository root and run:

```matlab
startup
require_dependencies
```

## Quick verification

Run the tests that do not require clinical data:

```matlab
startup
results = run_all_tests;
disp(results)
```

A test requiring `jfemg` is skipped automatically when the feature toolbox is absent.

## Typical workflows

### A. Extract ACPN features (authorized users only)

Create a private manifest based on `config/example_acpn_subject_manifest.csv`, then:

```matlab
cfg = example_config;
cfg.acpn.manifestFile = "C:\\private\\acpn_manifest.csv";
cfg.outputDir = fullfile(pwd, "outputs");
run_acpn_feature_extraction(cfg);
```

### B. Run subject-wise LOSO AdaBoost

```matlab
cfg = example_config;
cfg.featureTable = fullfile(pwd, "outputs", "ACPN_MU_features.csv");
cfg.modelName = "AdaBoost";
run_acpn_loso(cfg);
```

### C. Run subject-level LOSO SHAP

```matlab
cfg = example_config;
cfg.featureTable = fullfile(pwd, "outputs", "ACPN_MU_features.csv");
run_acpn_loso_shap(cfg);
```

### D. Run the CNN–BiLSTM baseline

```matlab
cfg = example_config;
cfg.acpn.manifestFile = "C:\\private\\acpn_manifest.csv";
run_cnn_bilstm_baseline(cfg);
```

### E. Extract UCDDB features

Create a manifest based on `config/example_ucddb_subject_manifest.csv`, then:

```matlab
cfg = example_config;
cfg.ucddb.manifestFile = "C:\\data\\ucddb_manifest.csv";
run_ucddb_feature_extraction(cfg);
```

The original UCDDB recordings are sampled at 64 Hz. Resampling standardizes downstream implementation and epoch length but does not recover frequency content above the original 32 Hz Nyquist limit. The code emits a warning to make this explicit.

## Canonical 41-feature schema

The model input comprises 37 scalar features from Jx-EMGT plus four coefficients from the fourth-order autoregressive feature, for a total of 41 columns. The exact order is defined centrally in:

```text
src/common/canonical_feature_definition.m
```

This corrects the ambiguous 40-versus-41 handling in the submitted archive and ensures that ACPN and UCDDB workflows use the same ordered schema. See `docs/FEATURE_SCHEMA.md`.

## Public-release safeguards

Before publishing:

- do not commit ACPN recordings, derived matrices, subject IDs, MDD labels, or private paths;
- use only pseudonymous subject labels in private manifests;
- inspect `git status` before every push;
- verify the repository from a fresh clone; and
- create a tagged release only after MATLAB validation.

See `PUBLIC_RELEASE_CHECKLIST.md` and `GITHUB_DESKTOP_GUIDE.md`.

## Citation

Citation metadata are available in `CITATION.cff`.

## License

Repository-authored code is provided under the MIT License. External dependencies remain under their own licenses and are not included here.
