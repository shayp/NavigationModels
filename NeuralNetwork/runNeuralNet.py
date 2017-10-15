import keras
from keras.models import Sequential
from keras.utils import plot_model
from keras.layers import Dense, Dropout, Activation
from keras import regularizers
import matplotlib.pyplot as plt
import numpy as np
import scipy as sp
from scipy import signal
from scipy import stats
from keras.layers import LSTM
from math import *
from keras import backend as K
import metrics as metrics
from keras import optimizers

def runNeuralNet(xVecotr, yVector, neuronNumber, sampleRate, initWeights, trainLength):

    testLength = 1 - trainLength
    numOfTimeBins = yVector.size
    numberOfInputFeatures = np.size(xVecotr, 1)

    # define gaussian window for smoothing
    gausLength = 15
    gaus = sp.signal.gaussian(gausLength,2)
    gaus = gaus / sum(gaus)
    gaus = gaus.reshape((gausLength,1))

    # Set Train data
    yVector = np.reshape(yVector, (len(yVector), 1))
    testFirstTimeBin = ceil(trainLength * numOfTimeBins)
    x_train = xVecotr
    y_train = yVector

    # Set test data
    y_test = yVector[testFirstTimeBin:numOfTimeBins - 1, :]
    y_test = np.convolve(np.reshape(y_test, len(y_test)),np.reshape(gaus, len(gaus)), 'same')
    y_test = np.reshape(y_test, (len(y_test), 1))
    x_test = xVecotr[testFirstTimeBin:numOfTimeBins - 1, :]

    batchSize = y_train.size

    # config the network
    model = Sequential()
    model.add(Dense(1, activation='sigmoid', input_dim = numberOfInputFeatures,  kernel_regularizer=regularizers.l1_l2(0.01,0.01)))
    model.layers[0].set_weights(initWeights)

    tbCallBack = keras.callbacks.TensorBoard(log_dir='./Graphs/Graph', histogram_freq=1, write_graph=True, write_images=True)
    model.compile(loss='poisson',
                  optimizer= 'Adam',
                  metrics=[metrics.cc, metrics.rmse, metrics.fev])

    # Run learning
    history =  model.fit(x_train, y_train,
              epochs=500, shuffle=True,validation_split = testLength,
              batch_size=batchSize, verbose = 1)

    # Predict the result for test set
    yhat_test = model.predict_on_batch(x_test)
    yhat_test[np.where(yhat_test < 0)] = 0

    model.summary()
    modelWeights = sp.special.expit(model.layers[0].get_weights()[0])
    print('============ Pearson Correlation =============')
    cc = sp.stats.pearsonr(y_test, yhat_test)[0][0]
    print(cc)

    plt.figure(neuronNumber)

    plt.subplot(311)
    plt.plot(history.history['correlation_coefficient'])
    plt.plot(history.history['val_correlation_coefficient'])
    plt.title('Learned Pearson Correlation')
    plt.ylabel('Pearson Correlation')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper right')

    # summarize history for loss

    plt.subplot(312)
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('Loss')
    plt.ylabel('Loss')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper right')

    plt.subplot(313)
    dt = 1 / sampleRate
    # summarize history for accuracy
    plt.plot(y_test * sampleRate)
    plt.plot(yhat_test * sampleRate)
    plt.title('Firing rate - Neuron ' + str(neuronNumber) + ' R = ' +str(cc))
    plt.ylabel('spikes(s)')
    plt.xlabel('time')
    plt.legend(['experiment', 'simulated'], loc='upper right')
    plt.savefig('./Graphs/firingrate_' + str(neuronNumber) + '.pdf')

    return modelWeights
