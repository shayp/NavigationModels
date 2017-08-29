import keras
from keras.models import Sequential
from keras.utils import plot_model
from keras.layers import Dense, Dropout, Activation
from keras.optimizers import SGD
import matplotlib.pyplot as plt
import numpy as np
import scipy as sp
from scipy import signal
from scipy import stats
from keras.layers import LSTM
from sklearn import preprocessing
from keras import regularizers

def runNeuralNet(xVecotr, yVector):

    # Generate dummy data
    x_train = xVecotr
    y_train = yVector

    batchSize = y_train.size
    #batchSize = 128
    model = Sequential()

    model.add(LSTM(32, input_dim = 6))
    model.add(Dense(64, activation='tanh', init='uniform'))
    model.add(Dense(1, activation='tanh', init='uniform'))
    model.compile(loss='mean_squared_error',
                  optimizer='adam',
                  metrics=['accuracy'])

    history =  model.fit(x_train, y_train,
              epochs=1000,shuffle=True,validation_split = 0.3,
              batch_size=batchSize, verbose = 1)

    yhat = model.predict_on_batch(xVecotr)

    gaus = sp.signal.gaussian(7,1)
    gaus = gaus / sum(gaus)
    gaus = gaus.reshape((7,1))
    y = np.convolve(np.reshape(yVector, len(yVector)),np.reshape(gaus, len(gaus)), 'same')
    y = np.reshape(y,(len(y), 1))
    print('============ Pearson Correlation =============')

    cc = sp.stats.pearsonr(yhat, y)[0]
    print(cc)
    plot_model(model, to_file='model.png')

    plt.figure(1)

    # summarize history for accuracy

    plt.subplot(311)
    plt.plot(history.history['acc'])
    plt.plot(history.history['val_acc'])
    plt.title('model accuracy')
    plt.ylabel('accuracy')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper right')

    # summarize history for loss

    plt.subplot(312)
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('model loss')
    plt.ylabel('loss')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper right')

    plt.subplot(313)
    plt.plot(y)
    plt.plot(yhat)
    plt.title('Firing rate - R = ' +str(cc))
    plt.ylabel('spikes')
    plt.xlabel('time')
    plt.legend(['experiment', 'simulated'], loc='upper right')
    plt.show()