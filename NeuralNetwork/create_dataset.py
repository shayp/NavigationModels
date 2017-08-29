import numpy as np
def create_dataset(dataset, look_back=1):
    numOfFeatures = np.size(dataset,1)
    sequenceSize = np.size(dataset,0)-look_back-1

    dataX = np.zeros((sequenceSize, look_back, numOfFeatures))
    for i in range(sequenceSize):
        a = dataset[i:(i+look_back), :]
        dataX[i,:,:] = np.reshape(a, (1,look_back, numOfFeatures))
    return dataX