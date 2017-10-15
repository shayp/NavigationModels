from os import walk
from GetNeuronDataFromMatFile import *
from buildFeatureVector import *
from runNeuralNet import *
from create_dataset import *
import numpy as np
from PlotTuningCurves import *
from buildInitWeightMatrix import *
import matplotlib.pyplot as plt
def LearnAllNeurons(folderPath):
    trainLength = 0.7
    # Get all file names in the directory
    fileNames = []
    for (dirpath, dirnames, filenames) in walk(folderPath):
        fileNames.extend(filenames)
        break

    for fileName in fileNames:
        spikeTrain, headDirection, velocityX, velocityY, posX, posY, border, sampleRate, boxSize, positionFeatures, \
        velocityFeatures, headDirectionFeatures, borderFeatures, posistionXBins, posistionYBins, headDirectionBins, \
        borderBins, velocityXBins, velocityYBins, neuronNumber = GetNeuronDataFromMatFile(folderPath, fileName)

        # Remove nan values
        headDirection[np.argwhere(np.isnan(headDirection))] = 0

        # Set number of params for each tuning curve
        numOfPositionParams = np.size(positionFeatures,1)
        numOfVelocityParams = np.size(velocityFeatures,1)
        numOfHeadDirectionParams = np.size(headDirectionFeatures,1)
        numOfBorderParams = np.size(borderFeatures,1)


        print('************ Running DNN  neuron *******************')
        print(neuronNumber)

        x_Data = buildFeatureVector(positionFeatures, velocityFeatures, headDirectionFeatures, borderFeatures)

        initWeights = buildInitWeightMatrix(spikeTrain, positionFeatures, velocityFeatures, headDirectionFeatures, borderFeatures, trainLength)
        modelWeights = runNeuralNet(x_Data, spikeTrain, neuronNumber, sampleRate, initWeights, trainLength)
        PlotTuningCurves(neuronNumber, modelWeights, numOfPositionParams, numOfVelocityParams, numOfHeadDirectionParams, numOfBorderParams)

