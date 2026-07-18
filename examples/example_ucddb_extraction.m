%EXAMPLE_UCDDB_EXTRACTION Edit a private manifest before running.
startup
cfg=example_config;
cfg.ucddb.manifestFile=fullfile(pwd,'config','example_ucddb_subject_manifest.csv');
T=run_ucddb_feature_extraction(cfg);
disp(T(1:min(5,height(T)),:))
