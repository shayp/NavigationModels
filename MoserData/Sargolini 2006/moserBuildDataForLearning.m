function moserBuildDataForLearning(neuronSpikesPath, poitionPath, sessionName, neuronNumber, neuronName, eegPath)

load(neuronSpikesPath);
load(poitionPath);
load(eegPath);
boxSize = [100 100];

dtStimulus = 0.02;
dtEEG = 1/Fs;
sampleRate = 1000;
dtSpike = 1 / sampleRate;
totlalLengthOfExp =  length(posx) * dtStimulus;

poisiotnNans = [find(isnan(posx)); find(isnan(posy)); find(isnan(posx2)); find(isnan(posy2));];
posx(poisiotnNans) = [];
posx2(poisiotnNans) = [];
posy(poisiotnNans) = [];
posy2(poisiotnNans) = [];

lengthOfStimulusMs = length(posx) * dtStimulus;


posx = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, posx, dtSpike:dtSpike:lengthOfStimulusMs);
posx2 = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, posx2, dtSpike:dtSpike:lengthOfStimulusMs);
posy = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, posy, dtSpike:dtSpike:lengthOfStimulusMs);
posy2 = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, posy2, dtSpike:dtSpike:lengthOfStimulusMs);

scaledEEG = interp1(dtEEG:dtEEG:totlalLengthOfExp, EEG, dtSpike:dtSpike:totlalLengthOfExp)';
posx = posx' + 50;
posx2 = posx2' + 50;
posy = posy' + 50;
posy2 = posy2' + 50;
headDirection = atan2(posy2-posy,posx2-posx)+pi/2;
headDirection(headDirection < 0) = headDirection(headDirection<0)+2*pi; % go from 0 to 2*pi, without any negative numbers
poisiotnNans = poisiotnNans * 20;
scaledPosNans = [];
poisiotnNans = unique(poisiotnNans);

for i = 1:length(poisiotnNans);
    scaledPosNans = [scaledPosNans (poisiotnNans(i) - 19):poisiotnNans(i)];
end
scaledPosNans(scaledPosNans > totlalLengthOfExp * 1000) = [];

spikeTimes = floor(cellTS * 1000);
spiketrain = double(ismember(1:totlalLengthOfExp / dtSpike, spikeTimes))';


spiketrain(scaledPosNans) = []; scaledEEG(scaledPosNans) = [];

hdNan = find(isnan(headDirection));

spiketrain(hdNan) = []; posx(hdNan) = []; posy(hdNan) = []; headDirection(hdNan) = []; scaledEEG(hdNan) = [];
phaseNan = find(isnan(scaledEEG));
scaledEEG(phaseNan) = [];
hilb_eeg = hilbert(scaledEEG); % compute hilbert transform
filt_eeg = atan2(imag(hilb_eeg),real(hilb_eeg))'; %inverse tangent (-pi to pi)
ind = filt_eeg <0; filt_eeg(ind) = filt_eeg(ind)+2*pi; % from 0 to 2*pi
phase = filt_eeg';
phaseNan2 = find(isnan(phase));
if length(phaseNan2) > 0
    'error'
end
spiketrain(phaseNan) = []; posx(phaseNan) = []; posy(phaseNan) = []; headDirection(phaseNan) = [];

% add the extra just to make the vectors the same size
% velx = diff([posx(1); posx]);
% vely = diff([posy(1); posy]); 
% 
% speed = sqrt(velx.^2+vely.^2) * sampleRate;
% speedInd = speed < 5;
% spiketrain(speedInd) = []; posx(speedInd) = []; posy(speedInd) = []; headDirection(speedInd) = []; phase(speedInd) = [];

mkdir(['../../GLM/rawDataForLearning/'  sessionName]);
save(['../../GLM/rawDataForLearning/'  sessionName '/data_for_cell_'  num2str(neuronNumber)], 'boxSize', 'post', 'posx', 'posy', 'sampleRate', 'headDirection', 'spiketrain', 'phase');
save(['../../GLM/rawDataForLearning/'  sessionName '/'  num2str(neuronNumber) '_' neuronName], 'boxSize', 'post', 'posx', 'posy', 'sampleRate', 'headDirection', 'spiketrain', 'phase');

end