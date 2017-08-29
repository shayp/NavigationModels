from GetNeuronDataFromMatFile import *
from buildFeatureVector import *
from runNeuralNet import *
from create_dataset import *
import numpy
def main():

    path = './rawDataForLearning/'
    fileName = 'params_for_cell_1.mat'
    spikeTrainParam = 'spiketrain'
    headDirectionParam = 'headDirection'
    velocityXParam = 'velx'
    velocityYParam = 'vely'
    posXParam = 'posx'
    posYParam = 'posy'
    borderParam = 'border'
    sampleRateParam = 'sampleRate'
    boxSizeParan = 'boxSize'

    spikeTrain, headDirection, velocityX, velocityY, posX, posY, border, sampleRate, boxSize = \
        GetNeuronDataFromMatFile(path, fileName, spikeTrainParam, headDirectionParam, velocityXParam, velocityYParam,
        posXParam, posYParam, borderParam, sampleRateParam, boxSizeParan)
    headDirection[np.argwhere(np.isnan(headDirection))] = 0
    paramsVector = buildFeatureVector(posX, posY, velocityX, velocityY, headDirection, border)
    memory_window = 5
    x_Data = create_dataset(paramsVector, memory_window)
    spikeTrain = spikeTrain[memory_window + 1:len(spikeTrain)]
    runNeuralNet(x_Data, spikeTrain)

if __name__ == "__main__":
    main()