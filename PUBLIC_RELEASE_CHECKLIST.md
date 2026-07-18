# Public release checklist

- [ ] No ACPN recordings are present.
- [ ] No derived ACPN feature matrices are present.
- [ ] No real subject identifiers, severity mappings, MDD labels, or patient filenames are present.
- [ ] No private absolute paths, credentials, tokens, or email exports are present.
- [ ] `config/local_paths.m` is not tracked.
- [ ] Canonical feature count is exactly 41 in every workflow.
- [ ] `tests/run_all_tests.m` passes in the target MATLAB release.
- [ ] ACPN private smoke test reproduces expected row counts and selected summary metrics.
- [ ] UCDDB example completes and emits the Nyquist warning.
- [ ] External dependency versions and licenses are documented.
- [ ] README commands work from a fresh clone.
- [ ] Repository is reviewed with `git status` before publication.
- [ ] Tagged release created.
- [ ] Zenodo archive/DOI created.
- [ ] Article Data and Code Availability statement updated with working links.
