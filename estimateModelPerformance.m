function [varExplain, correlation, mse] =  estimateModelPerformance(realFiringRate, stimulus, tuningCurves, dt, smoothingFilter)

    smooth_spikes = conv(realFiringRate, smoothingFilter,'same'); %returns vector same size as original
    smooth_fr = smooth_spikes./dt;

    fr_hat = exp(stimulus * tuningCurves')/dt;
    smooth_fr_hat = conv(fr_hat, smoothingFilter,'same'); %returns vector same size as original
    % compare between test fr and model fr
    sse = sum((smooth_fr_hat-smooth_fr).^2);
    sst = sum((smooth_fr-mean(smooth_fr)).^2);
    varExplain = 1-(sse/sst);
    correlation = corr(smooth_fr,smooth_fr_hat,'type','Pearson');
    mse = nanmean((smooth_fr_hat-smooth_fr).^2);
end