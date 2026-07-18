# Reproducibility and validation plan

## What has been checked

- every submitted MATLAB file was reviewed statically;
- hard-coded clinical identifiers and labels were removed from the release candidate;
- the 41-feature schema was centralized;
- obvious dimension, PCA, event-boundary, and normalization issues were corrected;
- tests were added for pure helper functions.

## What must still be checked in MATLAB

This environment did not include MATLAB, the ACPN data, or the two external dependencies. Therefore, numerical equivalence with the submitted results has not been established here.

Before public release:

1. Run `tests/run_all_tests.m`.
2. Run one authorized ACPN subject through feature extraction and verify:
   - event count;
   - number of retained MU components;
   - exactly 41 ordered columns;
   - finite feature values.
3. Run the full private ACPN extraction and compare the generated feature matrix against the submitted analysis.
4. Run LOSO with seed 1 and compare subject-level predictions and the 80% aggregate subject-level accuracy reported in the article.
5. Run the SHAP workflow and compare the dominant features.
6. Run the CNN–BiLSTM split and compare validation/test summaries.
7. Run at least one UCDDB recording and verify the generated features and explicit Nyquist warning.

Differences should be investigated and documented before tagging `v1.0.0`.
