% runs most basic analysis
dicomStorageDir = '/Volumes/data/MRIData/CMRRDATA/';
dicomBaseDir = '/Data/DICOM/';

sesname = 'm18150811';
dicomSessionName = '20110815-ST001-dcm18150811';
dicomDir = fullfile(dicomBaseDir,dicomSessionName);
useOnlineRecon = true;

addpath('prepareAnalysis');
addpath('sessionParameters');
addpath('assessData');
addpath('tools');

try
    clear dcprintfig; % clears persistent figure counter 
    
    % copy DICOM dir from archive
    % system(['cp -R ' fullfile(dicomStorageDir,dicomSessionName) ' ' ...
    %    dicomBaseDir]);
    
    prepareAnalysis(dicomDir, sesname, useOnlineRecon);
    
   
    
    
catch ME
    disp(ME)
end