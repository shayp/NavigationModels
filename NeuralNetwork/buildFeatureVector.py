import numpy as np
def buildFeatureVector(positionFeatures, velocityFeatures, headDirectionFeatures,borderFeatures):
    x = np.concatenate((positionFeatures, velocityFeatures, headDirectionFeatures,borderFeatures), axis=1)
    return x