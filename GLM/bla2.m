clear all;
load('../MoserData/Sargolini 2006/all_data/11265-06020601/11265-06020601_T1C1');

spike1 = cellTS;

load('../MoserData/Sargolini 2006/all_data/11265-06020601/11265-06020601_T2C2');
spike2 = cellTS;

[cor,Tout] = MyCrossCorr(spike1,spike2);

figure();
plot(Tout, cor);
title('11265-06020601-T1C1 vs 11265-06020601-T2C2');

load('../MoserData/Sargolini 2006/all_data/11265-16030601+02/11265-16030601+02_T1C4');

spike1 = cellTS;

load('../MoserData/Sargolini 2006/all_data/11265-16030601+02/11265-16030601+02_T2C2');
spike2 = cellTS;

[cor,Tout] = MyCrossCorr(spike1,spike2);

figure();
plot(Tout, cor);
title('11265-16030601+02-T1C4 vs 11265-16030601+02-T2C2');
