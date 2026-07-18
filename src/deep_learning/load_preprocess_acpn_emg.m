function [emg,fs,label] = load_preprocess_acpn_emg(edfFile,cfg)
%LOAD_PREPROCESS_ACPN_EMG Load, resample, and filter one chin EMG channel.
[emg,fs,label]=read_edf_channel(edfFile,cfg.acpn.emgAliases);
if abs(fs-cfg.preprocessing.targetFs)>eps
    emg=resample_signal(emg,fs,cfg.preprocessing.targetFs,"polyphase");
    fs=cfg.preprocessing.targetFs;
end
emg=apply_chin_emg_filter(emg,fs,cfg);
end
