import matplotlib.pyplot as plt
import numpy as np
def PlotTuningCurves(neuronNumber, modelWeights, numOfPositionParams, numOfVelocityParams, numOfHeadDirectionParams, numOfBorderParams):
    positionTuningCurve = modelWeights[0:numOfPositionParams ]
    velocityTuningCurve = np.asarray(modelWeights[numOfPositionParams:numOfVelocityParams + numOfPositionParams ])
    headDirectionTuningCurve = np.asarray(modelWeights[numOfPositionParams + numOfVelocityParams:numOfHeadDirectionParams + numOfVelocityParams + numOfPositionParams ])
    borderTuningCurve = np.asarray(modelWeights[numOfPositionParams + numOfVelocityParams + numOfHeadDirectionParams:numOfBorderParams + numOfHeadDirectionParams + numOfVelocityParams + numOfPositionParams])

    plt.figure(100 + neuronNumber)
    plt.subplot(411)
    plt.imshow(np.reshape(positionTuningCurve,(int(np.sqrt(numOfPositionParams)), int(np.sqrt(numOfPositionParams)))), extent = [0,140, 0, 20])
    plt.colorbar()
    plt.title('Position tuning curve')
    plt.subplot(412)
    plt.imshow(np.reshape(velocityTuningCurve,(int(np.sqrt(numOfVelocityParams)), int(np.sqrt(numOfVelocityParams)))), extent = [-40,40, -20, 20])
    plt.colorbar()
    plt.title('Velocity tuning curve')

    plt.subplot(413)
    plt.plot(headDirectionTuningCurve)
    plt.title('Head direction tuning curve')

    plt.subplot(414)
    plt.plot(borderTuningCurve)
    plt.title('Border tuning curve')
    plt.savefig('./Graphs/tuningcurves' + str(neuronNumber) + '.pdf')
    plt.show()

