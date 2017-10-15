import scipy.io as sio

def GetNeuronDataFromMatFile(path, fileName):

    spikeTrainParam = 'spiketrain'
    headDirectionParam = 'headDirection'
    velocityXParam = 'velx'
    velocityYParam = 'vely'
    posXParam = 'posx'
    posYParam = 'posy'
    borderParam = 'border'
    sampleRateParam = 'sampleRate'
    boxSizeParam = 'boxSize'
    posGridParam = 'posgrid'
    velGridParam = 'velgrid'
    headDirectionGridParam = 'hdgrid'
    bordergridParam = 'bordergrid'
    posXBinsParam = 'xBins'
    posYBinsParam = 'yBins'
    headDirectionBinsParam = 'hdVec'
    borderBinsParam = 'borderBins'
    velXBinsParam = 'velXVec'
    velYBinsParam = 'velYVec'
    neuronNumberParam = 'neuronNumber'

    mat_contents = sio.loadmat(path + fileName)
    spikeTrain = mat_contents[spikeTrainParam]
    headDirection = mat_contents[headDirectionParam]
    velocityX = mat_contents[velocityXParam]
    velocityY = mat_contents[velocityYParam]
    posX = mat_contents[posXParam]
    posY = mat_contents[posYParam]
    border = mat_contents[borderParam]
    sampleRate = mat_contents[sampleRateParam]
    boxSize = mat_contents[boxSizeParam]
    positionFeatures = mat_contents[posGridParam]
    velocityFeatures = mat_contents[velGridParam]
    headDirectionFeatures = mat_contents[headDirectionGridParam]
    borderFeatures = mat_contents[bordergridParam]
    posistionXBins = mat_contents[posXBinsParam]
    posistionYBins = mat_contents[posYBinsParam]
    headDirectionBins = mat_contents[headDirectionBinsParam]
    borderBins = mat_contents[borderBinsParam]
    velocityXBins = mat_contents[velXBinsParam]
    velocityYBins = mat_contents[velYBinsParam]
    neuronNumber = mat_contents[neuronNumberParam][0][0]
    return spikeTrain, headDirection, velocityX, velocityY, posX, posY, border, sampleRate, boxSize,\
           positionFeatures, velocityFeatures, headDirectionFeatures, borderFeatures, posistionXBins, posistionYBins,\
           headDirectionBins, borderBins, velocityXBins, velocityYBins, neuronNumber