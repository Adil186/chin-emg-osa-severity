# Package validation report

Generated: 2026-07-18

- MATLAB files: 39
- Function/file-name mismatches: 0
- Sensitive-pattern hits in the static scan: 0
- Submitted files represented in migration map: 18/18
- Canonical feature assertions present: yes
- Third-party source bundled: no
- Git staging smoke test: 61 repository files staged successfully
- Example ACPN/UCDDB manifests included despite the general CSV ignore rule: yes
- Runtime MATLAB validation: **not performed in this environment**

## Function/file mismatches

None detected by the static check.

## Sensitive-pattern scan

No embedded clinical subject lists, private data files, or local dependency paths were detected by the automated scan. A manual inspection is still required before public release.

## Required next validation

Run `startup` and `run_all_tests` in MATLAB with the external dependencies installed, then complete the private ACPN and public UCDDB smoke tests in `docs/REPRODUCIBILITY.md`. Numerical equivalence with the submitted analysis has not been established in this environment.
