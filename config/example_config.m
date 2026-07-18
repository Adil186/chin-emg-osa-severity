function cfg = example_config()
%EXAMPLE_CONFIG Configuration template for all public workflows.

repoRoot = fileparts(fileparts(mfilename('fullpath')));

cfg.seed = 1;
cfg.outputDir = fullfile(repoRoot, "outputs");
cfg.featureTable = fullfile(cfg.outputDir, "ACPN_MU_features.csv");
cfg.modelName = "AdaBoost";
cfg.firstFeatureColumn = 8; % fallback only; canonical names are preferred
cfg.innerFolds = 10;

cfg.features.thresholdMode = "fixed"; % preserves submitted constants
cfg.features.generalThreshold = 0.01;
cfg.features.myopThreshold = 0.016;

cfg.decomposition.extensionParameter = 16;
cfg.decomposition.maxSources = 300;
cfg.decomposition.whitenFlag = 1;
cfg.decomposition.snr = Inf;
cfg.decomposition.silhouetteThreshold = 0.6;
cfg.decomposition.pcaVariance = 95;
cfg.decomposition.usePCA = true;

cfg.preprocessing.targetFs = 200;
cfg.preprocessing.notchHz = 50;
cfg.preprocessing.notchHalfWidthHz = 1;
cfg.preprocessing.bandpassHz = [20 50];
cfg.preprocessing.standardizeEpoch = true;

cfg.apnea.shortestDurationSec = 10;
cfg.apnea.longestDurationSec = 120;
cfg.apnea.initialThreshold = 0.10;
cfg.apnea.thresholdStep = 0.0005;
cfg.apnea.maxIterations = 1000;

cfg.acpn.manifestFile = fullfile(repoRoot, "config", "example_acpn_subject_manifest.csv");
cfg.acpn.emgAliases = ["EMG Middle", "Chin EMG", "EMG"];
cfg.acpn.airflowAliases = ["Airflow", "Flow", "Thermistor"];

cfg.ucddb.manifestFile = fullfile(repoRoot, "config", "example_ucddb_subject_manifest.csv");
cfg.ucddb.emgAliases = ["EMG", "Chin EMG", "EMG Middle"];
cfg.ucddb.epochDurationSec = 30;
cfg.ucddb.eventTimeColumn = "Time";
cfg.ucddb.eventTypeColumn = "Type";
cfg.ucddb.eventDurationColumn = "Duration";
cfg.ucddb.eventTypePatterns = ["APNEA-O", "HYP-O", "Obstructive apnea", "Hypopnea"];
cfg.ucddb.includeNormalEpochs = false;

cfg.deepLearning.windowDurationSec = 30;
cfg.deepLearning.maxEpochs = 50;
cfg.deepLearning.miniBatchSize = 64;
cfg.deepLearning.initialLearnRate = 1e-3;
cfg.deepLearning.l2Regularization = 1e-4;
cfg.deepLearning.dropout = 0.5;
end
