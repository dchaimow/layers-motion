% Define parameters
dataDir = '~/Data/layers-motion/ses/m46300811';

anatFile= 'm46300811_anat';

magFile = 'm46300811_mag';
phaFile = 'm46300811_pha';

swiMagFile = 'm46300811_swimag';
swiPhaFile = 'm46300811_swipha';
swiMagNormFile = 'm46300811_swimagnorm';

scanlist = {'m46300811_func_01';
'm46300811_func_02';
'm46300811_func_03';
'm46300811_func_04';
'm46300811_func_05';
'm46300811_func_06';
'm46300811_func_07'};

stimFiles = {'dcm46300811_CohInc_V12Dens_1_P1.mat';
'dcm46300811_CohInc_V12Dens_2_P2.mat';
'dcm46300811_CohInc_V12Dens_3_P3.mat';
'dcm46300811_CohInc_V12Dens_4_P4.mat';
'dcm46300811_CohInc_V12Dens_5_P5.mat';
'dcm46300811_CohInc_V12Dens_6_P6.mat';
'dcm46300811_CohInc_V12Dens_7_P7.mat'};

nScans = length(scanlist); 
TR = 2;