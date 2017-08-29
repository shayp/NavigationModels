function [varExplain, correlation, mse, smooth_fr_exp, smooth_fr_sim] =  estimateModelPerformance(realFiringRate, stimulus, tuningCurves, dt, smoothingFilter)

    smooth_spikes = conv(realFiringRate, smoothingFilter,'same'); %returns vector same size as original
    smooth_fr_exp = smooth_spikes./dt;

    fr_hat = exp(stimulus * tuningCurves')/dt;
    smooth_fr_sim = conv(fr_hat, smoothingFilter,'same'); %returns vector same size as original
    % compare between test fr and model fr
    sse = sum((smooth_fr_sim-smooth_fr_exp).^2);
    sst = sum((smooth_fr_exp-mean(smooth_fr_exp)).^2);
    varExplain = 1-(sse/sst);
    correlation = corr(smooth_fr_exp,smooth_fr_sim,'type','Pearson');
    mse = nanmean((smooth_fr_sim-smooth_fr_exp).^2);
end