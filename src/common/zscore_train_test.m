function [XTrainZ, XTestZ, mu, sigma] = zscore_train_test(XTrain, XTest)
%ZSCORE_TRAIN_TEST Standardize test data using training statistics only.
mu = mean(XTrain,1,'omitnan');
sigma = std(XTrain,0,1,'omitnan');
sigma(~isfinite(sigma) | sigma==0) = 1;
XTrainZ = (XTrain-mu)./sigma;
XTestZ = (XTest-mu)./sigma;
end
