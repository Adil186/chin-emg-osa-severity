%EXAMPLE_LOSO_FROM_FEATURE_TABLE Configure and run the public LOSO function.
startup
cfg=example_config;
cfg.featureTable=fullfile(pwd,'outputs','ACPN_MU_features.csv');
cfg.modelName="AdaBoost";
metrics=run_acpn_loso(cfg);
disp(metrics)
