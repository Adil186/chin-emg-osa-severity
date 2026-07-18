function signals = load_acpn_signals_from_edf(edfFile, cfg)
%LOAD_ACPN_SIGNALS_FROM_EDF Load and align ACPN chin EMG and airflow.

[emg,fsEmg,emgLabel] = read_edf_channel(edfFile,cfg.acpn.emgAliases);
[airflow,fsFlow,flowLabel] = read_edf_channel(edfFile,cfg.acpn.airflowAliases);

if abs(fsEmg-cfg.preprocessing.targetFs)>eps
    emg = resample_signal(emg,fsEmg,cfg.preprocessing.targetFs,"polyphase");
    fsEmg = cfg.preprocessing.targetFs;
end
if abs(fsFlow-fsEmg)>eps
    airflow = resample_signal(airflow,fsFlow,fsEmg,"polyphase");
end

n = min(numel(emg),numel(airflow));
emg = apply_chin_emg_filter(emg(1:n),fsEmg,cfg);
airflow = airflow(1:n);

signals = struct('emg',emg,'airflow',airflow,'fs',fsEmg, ...
    'emgLabel',emgLabel,'airflowLabel',flowLabel);
end
