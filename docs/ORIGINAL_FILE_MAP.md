# Mapping from submitted Supplementary Code SC1 files

| Submitted file | Public repository replacement |
|---|---|
| `ACPN LOSO Pipeline/Supplementary Code S1.m` | `src/acpn/run_acpn_loso.m` |
| `ACPN LOSO Pipeline/macroMetrics.m` | `src/common/macro_metrics.m` |
| `ACPN LOSO Pipeline/trainBaseModel.m` | `src/common/train_base_model.m` |
| `Comorbidity and Confounding Analysis/Confounding analysis.m` | `src/analyses/run_mdd_confounding_analysis.m` |
| `Deep Learning (CNN+RNN) Baseline/cnn_bilstm_osa_severity_stratified.m` | `src/deep_learning/run_cnn_bilstm_baseline.m` |
| `Deep Learning (CNN+RNN) Baseline/loadPreprocessEMG.m` | `src/deep_learning/load_preprocess_acpn_emg.m` |
| `Deep Learning (CNN+RNN) Baseline/multiClassMetrics.m` | `src/common/multiclass_metrics.m` |
| `Error Analysis and Misclassification Cost/Error_Analysis_Code.m` | `src/analyses/run_subject_error_analysis.m` |
| `Original Pipeline/ACPN_ExtractFeatures_Main.m` | `src/acpn/run_acpn_feature_extraction.m` |
| `Original Pipeline/ACPN_SubjectSplit_Models_SHAP_rep.m` | `src/acpn/run_acpn_subject_split_models.m` |
| `Original Pipeline/buildEMGEpochs.m` | `src/acpn/build_emg_epochs.m` |
| `Original Pipeline/detectApnea.m` | `src/acpn/detect_apnea.m` |
| `Original Pipeline/extractMUFeatures.m` | `src/common/decompose_and_extract_mu_features.m` |
| `Original Pipeline/loadACPNSignalsFromEDF.m` | `src/acpn/load_acpn_signals_from_edf.m` |
| `Original Pipeline/stratifiedSubjectSplit.m` | `src/common/stratified_subject_split.m` |
| `SHAP Analysis/ACPN LOSO – subject-level SHAP analysis.m` | `src/acpn/run_acpn_loso_shap.m` |
| `UCDDB_Dataset_Harmonization/extractMotorUnitFeatures.m` | `src/common/decompose_and_extract_mu_features.m` |
| `UCDDB_Dataset_Harmonization/extractUCDDB_features_harmonized.m` | `src/ucddb/run_ucddb_feature_extraction.m` |

The replacement files preserve the analysis intent while removing hard-coded clinical identifiers and correcting implementation inconsistencies documented in `CODE_AUDIT.md`.
