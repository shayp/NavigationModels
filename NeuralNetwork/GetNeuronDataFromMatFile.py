import scipy.io as sio

def GetNeuronDataFromMatFile(path, fileName, spikeTrainParam, headDirectionParam, velocityXParam, velocityYParam, posXParam,posYParam, borderParam, sampleRateParam, boxSizeParan):
    mat_contents = sio.loadmat(path + fileName)
    spikeTrain = mat_contents[spikeTrainParam]
    headDirection = mat_contents[headDirectionParam]
    velocityX = mat_contents[velocityXParam]
    velocityY = mat_contents[velocityYParam]
    posX = mat_contents[posXParam]
    posY = mat_contents[posYParam]
    border = mat_contents[borderParam]
    sampleRate = mat_contents[sampleRateParam]
    boxSize = mat_contents[boxSizeParan]
    return spikeTrain, headDirection, velocityX, velocityY, posX, posY, border, sampleRate, boxSize