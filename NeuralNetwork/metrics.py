"""
Metrics comparing predicted and recorded firing rates
All metrics in this module are computed separately for each cell, but averaged
across the sample dimension (axis=0).
"""
from functools import wraps

import tensorflow as tf
import keras.backend as K

__all__ = ['cc', 'rmse', 'fev', 'CC', 'RMSE', 'FEV',
           'root_mean_squared_error', 'correlation_coefficient',
           'fraction_of_explained_variance']


def correlation_coefficient(obs_rate, est_rate):
    """Pearson correlation coefficient"""
    x_mu = obs_rate - K.mean(obs_rate, axis=0, keepdims=True)
    x_std = K.std(obs_rate, axis=0, keepdims=True)
    y_mu = est_rate - K.mean(est_rate, axis=0, keepdims=True)
    y_std = K.std(est_rate, axis=0, keepdims=True)
    return K.mean(x_mu * y_mu, axis=0, keepdims=True) / (x_std * y_std)


def mean_squared_error(obs_rate, est_rate):
    """Mean squared error across samples"""
    return K.mean(K.square(est_rate - obs_rate), axis=0, keepdims=True)


def root_mean_squared_error(obs_rate, est_rate):
    """Root mean squared error"""
    return K.sqrt(mean_squared_error(obs_rate, est_rate))


def fraction_of_explained_variance(obs_rate, est_rate):
    """Fraction of explained variance
    https://wikipedia.org/en/Fraction_of_variance_unexplained
    """
    return 1.0 - mean_squared_error(obs_rate, est_rate) / K.var(obs_rate, axis=0, keepdims=True)



# aliases
cc = CC = correlation_coefficient
rmse = RMSE = root_mean_squared_error
fev = FEV = fraction_of_explained_variance