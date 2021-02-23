% Define parameters
dataDir = '/Data/ses/m18150811';

anatFile= 'm18150811_anat';

magFile = 'm18150811_mag';
phaFile = 'm18150811_pha';

swiMagFile = 'm18150811_swimag';
swiPhaFile = 'm18150811_swipha';
swiMagNormFile = 'm18150811_swimagnorm';

scanlist = {'m18150811_func_01';
'm18150811_func_02';
'm18150811_func_03';
'm18150811_func_04';
'm18150811_func_05'};

stimFiles = {'dcm18150811_CohInc_2Dens_1_P1.mat';
'dcm18150811_CohInc_2Dens_2_P2.mat';
'dcm18150811_CohInc_2Dens_3_P3.mat';
'dcm18150811_CohInc_2Dens_4_P4.mat';
'dcm18150811_CohInc_2Dens_5_P5.mat'};

nScans = length(scanlist); 
TR = 2;