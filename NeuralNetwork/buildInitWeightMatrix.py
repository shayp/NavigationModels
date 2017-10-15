import numpy as np
def buildInitWeightMatrix(spikeTrain, positionFeatures, velocityFeatures, headDirectionFeatures, borderFeatures, trainFrac):
    numOfPositionFeatures = np. size(positionFeatures, 1)
    numOfVelocityFeatures = np. size(velocityFeatures, 1)
    numOfHeadDirectionFeatures = np.size(headDirectionFeatures, 1)
    numOfBorderFeatures = np.size(borderFeatures, 1)
    trainSize = int(np.ceil(trainFrac * len(spikeTrain)))

    spikeTrain_test = spikeTrain[0:trainSize - 1]
    positionFeatures_test = positionFeatures[0:trainSize - 1,:]
    velocityFeaturs_test = velocityFeatures[0:trainSize - 1,:]

    poisitionInitWeights = (np.matmul(np.transpose(positionFeatures_test), spikeTrain_test)) / np.sum(spikeTrain_test)
    velocityInitWeights =  (np.matmul(np.transpose(velocityFeaturs_test), spikeTrain_test)) / np.sum(spikeTrain_test)

    velocityInitWeights[np.where(velocityInitWeights == 0)[0]] = -6
    #poisitionInitWeights[np.where(poisitionInitWeights == 0)[0]] = -6
    poisitionInitWeights[:] = -6
    headDirectionInitWeights = -6 * np.ones((numOfHeadDirectionFeatures, 1))
    borderInitWeights = -6 * np.ones((numOfBorderFeatures, 1))

    initWeights = np.concatenate((poisitionInitWeights, velocityInitWeights, headDirectionInitWeights, borderInitWeights), axis=0)
    initWeights = [initWeights, np.asarray([0])]
    return initWeights

