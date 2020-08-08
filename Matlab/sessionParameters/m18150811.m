% Define parameters
dataDir = '/Data/ses/m18150811';

anatFile= '/Data/ses/nifti/m18150811_anat.nii';

magFile = '/Data/ses/nifti/m18150811_mag.nii';
phaFile = '/Data/ses/nifti/m18150811_pha.nii';

swiMagFile = '/Data/ses/nifti/m18150811_swimag.nii';
swiPhaFile = '/Data/ses/nifti/m18150811_swipha.nii';
swiMagNormFile = '/Data/ses/nifti/m18150811_swimagnorm.nii';

scanlist = {'/Data/ses/nifti/m18150811_func_01.nii';
'/Data/ses/nifti/m18150811_func_02.nii';
'/Data/ses/nifti/m18150811_func_03.nii';
'/Data/ses/nifti/m18150811_func_04.nii';
'/Data/ses/nifti/m18150811_func_05.nii';
'/Data/ses/nifti/m18150811_func_06.nii'};

stimFiles = {'dcm18150811_CohInc_2Dens_1_P1.mat';
'dcm18150811_CohInc_2Dens_2_P2.mat';
'dcm18150811_CohInc_2Dens_3_P3.mat';
'dcm18150811_CohInc_2Dens_4_P4.mat';
'dcm18150811_CohInc_2Dens_5_P5.mat';
'dcm18150811_CohInc_2Dens_6_P6.mat'};

nScans = length(scanlist); 
TR = 2;