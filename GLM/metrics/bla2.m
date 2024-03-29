clear all;
networkName = '11265-01020602';
load(['../rawDataForLearning/' networkName '/data_for_cell_5']);
real1 = spiketrain;
spike1 = find(spiketrain);  

load(['../rawDataForLearning/' networkName '/data_for_cell_8']);
spike2 = find(spiketrain);
real2 = spiketrain;
T = -505.5:10:505.5;
Tout = -500:10:500;
[cor] = MyCrossCorrMS(spike1,spike2, T);
[autocorr1] = MyCrossCorrMS(spike1,spike1, T);
[autocorr2] = MyCrossCorrMS(spike2,spike2, T);

figure();
xlabel('time (ms)');
plot(Tout, cor);

figure();
xlabel('time (ms)');
plot(Tout, autocorr1);

figure();
xlabel('time (ms)');
plot(Tout, autocorr2);


% clear all;
% load('../MoserData/Sargolini 2006/all_data/11265-06020601/11265-06020601_T1C1');
% 
% spike1 = cellTS;
% 
% load('../MoserData/Sargolini 2006/all_data/11265-06020601/11265-06020601_T2C2');
% spike2 = cellTS;
% 
% [cor,Tout] = MyCrossCorr(spike1,spike2);
% 
% figure();
% plot(Tout, cor);
% title('11265-06020601-T1C1 vs 11265-06020601-T2C2');
% 
% load('../MoserData/Sargolini 2006/all_data/11265-16030601+02/11265-16030601+02_T1C4');
% 
% spike1 = cellTS;
% 
% load('../MoserData/Sargolini 2006/all_data/11265-16030601+02/11265-16030601+02_T2C2');
% spike2 = cellTS;
% 
% [cor,Tout] = MyCrossCorr(spike1,spike2);
% 
% figure();
% plot(Tout, cor);
% title('11265-16030601+02-T1C4 vs 11265-16030601+02-T2C2');
