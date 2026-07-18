# Static code audit and implemented corrections

All 18 files in the submitted Supplementary Code SC1 archive were reviewed individually.

## High-impact corrections implemented

1. **Canonical feature count** — the original scripts mixed 40 toolbox method calls with a claimed 41-column feature vector. The AR method returns four coefficients. The public implementation now defines one exact 41-column schema and uses it in both ACPN and UCDDB.
2. **PCA output** — the original ACPN helper computed PCA but selected columns from the untransformed source matrix. The corrected function uses PCA scores.
3. **Decomposition API** — the corrected helper uses the documented name-value `run_decomposition` API and retains a legacy fallback.
4. **Clinical de-identification** — real subject IDs, severity maps, and MDD status values are no longer embedded in source code; private manifests are supplied locally.
5. **Inner cross-validation** — normalization and subject-balanced weights are recomputed within each inner training fold.
6. **Event detection** — low-amplitude runs are detected without Image Processing Toolbox morphology calls, and empty expected-event input is supported.
7. **Epoch boundaries** — event, pre-event, post-event, and event-free segments are boundary-safe and event-free segments cannot cross excluded regions.
8. **EDF loading** — channel loading uses `edfinfo`/`edfread`, alias matching, explicit sampling-rate calculation, and safe signal-length alignment.
9. **UCDDB output granularity** — output is one row per retained MU rather than an undocumented component mean.
10. **UCDDB spectral caveat** — code warns that resampling 64 Hz recordings cannot restore content above 32 Hz.
11. **Statistical wording** — the confounding-analysis helper reports Mann–Whitney U calculated from the MATLAB rank-sum statistic rather than labeling the rank sum itself as U.
12. **Workspace independence** — error and confounding analyses are callable functions with explicit input files/tables.

## Validation limitation

The corrections are based on static analysis. MATLAB execution with authorized data and installed dependencies is required before the repository is made public. See `docs/REPRODUCIBILITY.md`.
