import numpy as np
def buildFeatureVector(posX, posY, velX, velY, headDirection, distanceFromBorder):
    x = np.concatenate((posX, posY, velX, velY, headDirection, distanceFromBorder), axis=1)
    return x