load('config');
boxSize = [100, 100];
maxDistanceFromBorder = 10;
maxVelocityXAxis = 40;
maxVelocityYAxis = 40;
numOfDistanceFromBorderParams =  10;
numOfHeadDirectionParams = 20;
numOfPositionAxisParams = 30;
numOfVelocityAxisParams = 30;
sampleRate = 1000;
save('config','boxSize', 'maxDistanceFromBorder', 'maxVelocityXAxis', 'maxVelocityYAxis', 'numOfDistanceFromBorderParams',...
    'numOfHeadDirectionParams', 'numOfPositionAxisParams', 'numOfVelocityAxisParams', 'sampleRate');