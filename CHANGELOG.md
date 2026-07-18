# Changelog

## v1.0.0-rc1 — 2026-07-18

- Reorganized the submitted Supplementary Code SC1 archive into a documented GitHub-ready structure.
- Removed hard-coded ACPN subject identifiers, severity labels, MDD labels, and local paths.
- Added manifest-driven configuration for ACPN and UCDDB.
- Established one canonical ordered 41-feature schema: 37 scalar Jx-EMGT features plus four AR coefficients.
- Corrected PCA handling to use PCA scores rather than indexing the original source matrix.
- Updated hdEMG decomposition calls to the documented name-value API with a legacy fallback.
- Added robust EDF channel loading using `edfinfo`/`edfread`.
- Added boundary-safe event and non-event epoch construction without Image Processing Toolbox morphology calls.
- Corrected inner-CV normalization so each inner training fold supplies its own statistics.
- Replaced hard-coded analysis scripts with callable functions and explicit inputs.
- Added UCDDB Nyquist-limit warning and one-row-per-MU output.
- Added documentation, tests, public-release safeguards, citation metadata, and GitHub Desktop instructions.

This release candidate still requires execution in MATLAB with the authorized data and external dependencies before public release.
