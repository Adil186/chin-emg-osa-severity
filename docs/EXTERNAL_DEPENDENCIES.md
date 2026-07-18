# External dependencies

## hdEMG-Decomposition

- GitHub: https://github.com/neuromechanist/hdEMG-Decomposition
- MATLAB File Exchange: https://www.mathworks.com/matlabcentral/fileexchange/117970-hdemg-decomposition
- Reference release: v0.1
- License: MIT
- Citation: Shirazi, S. Y. (2022), *hdEMG-Decomposition*, DOI: 10.5281/zenodo.7106379.

The repository calls `run_decomposition` through the documented name-value interface and includes a legacy positional-call fallback for compatibility with the originally submitted environment.

## EMG Feature Extraction Toolbox (Jx-EMGT)

- GitHub: https://github.com/JingweiToo/EMG-Feature-Extraction-Toolbox
- MATLAB File Exchange: https://www.mathworks.com/matlabcentral/fileexchange/71514-emg-feature-extraction-toolbox
- Reference release: 1.4
- License: BSD-3-Clause

The repository calls `jfemg`. Thirty-seven scalar descriptors are used directly and the fourth-order AR method is expanded to four coefficient columns, yielding 41 classifier features.

## Installation

Clone or download each project outside this repository. Add its root folder recursively to the MATLAB path through `config/local_paths.m`.
