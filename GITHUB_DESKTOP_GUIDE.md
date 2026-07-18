# GitHub Desktop guide for first-time repository creation

## 1. Prepare the folder

1. Extract this package to a simple local path, for example:
   `Documents\GitHub\chin-emg-osa-severity`.
2. Do not copy ACPN data, feature matrices, or private manifests into this folder.
3. Open the folder and confirm that `README.md`, `src`, `docs`, `config`, and `tests` are visible.

## 2. Create the local repository

1. Open GitHub Desktop.
2. Select **File → Add local repository**.
3. Browse to the extracted folder.
4. If GitHub Desktop reports that it is not a Git repository, select **Create a repository here**.
5. Repository name: `chin-emg-osa-severity`.
6. Description: `MATLAB implementation for chin EMG-based OSA severity assessment`.
7. Keep the default branch name `main`.
8. Do not add another README, `.gitignore`, or license—the package already contains them.

## 3. First commit

1. Review the file list in GitHub Desktop.
2. Confirm that no EDF, MAT, XLSX, real subject manifest, or private path file is listed.
3. Commit summary: `Initial de-identified release candidate`.
4. Click **Commit to main**.

## 4. Publish privately first

1. Click **Publish repository**.
2. Keep **Keep this code private** selected.
3. Publish.
4. Open the repository on github.com and verify the README rendering.

## 5. Test before making it public

1. Install dependencies and configure `config/local_paths.m`.
2. Run `startup` and `run_all_tests` in MATLAB.
3. Run a private ACPN smoke test and compare outputs with the submitted analysis.
4. Run the public UCDDB example.
5. Clone the private repository into a second empty folder and repeat the setup to confirm the documentation is sufficient.
6. Complete `PUBLIC_RELEASE_CHECKLIST.md`.

## 6. Make public and create a release

1. On github.com, go to **Settings → General → Danger Zone → Change repository visibility**.
2. Select **Public** only after all validation checks pass.
3. Create a release:
   - tag: `v1.0.0`
   - title: `Initial release accompanying the ESWA article`
4. Include the article DOI, MATLAB version, dependency versions, data restrictions, and known limitations in the release notes.

## 7. Permanent archive

Connect the public repository to Zenodo and archive the `v1.0.0` release. Add the Zenodo DOI to the README and `CITATION.cff`.
