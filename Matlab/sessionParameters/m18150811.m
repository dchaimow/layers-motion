% Define parameters
dataDir = '/Data/ses/m18150811';

anatFile= 'm18150811_anat.nii';

magFile = 'm18150811_mag.nii';
phaFile = 'm18150811_pha.nii';

swiMagFile = 'm18150811_swimag.nii';
swiPhaFile = 'm18150811_swipha.nii';
swiMagNormFile = 'm18150811_swimagnorm.nii';

scanlist = {'m18150811_func_01.nii';
'm18150811_func_02.nii';
'm18150811_func_03.nii';
'm18150811_func_04.nii';
'm18150811_func_05.nii';
'm18150811_func_06.nii'};

stimFiles = {'dcm18150811_CohInc_2Dens_1_P1.mat';
'dcm18150811_CohInc_2Dens_2_P2.mat';
'dcm18150811_CohInc_2Dens_3_P3.mat';
'dcm18150811_CohInc_2Dens_4_P4.mat';
'dcm18150811_CohInc_2Dens_5_P5.mat';
'dcm18150811_CohInc_2Dens_6_P6.mat'};

nScans = length(scanlist); 
TR = 2;