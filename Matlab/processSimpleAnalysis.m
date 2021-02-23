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
addpath('functionalAnalyses');
addpath('dataTransformFunctions');

try
    clear dcprintfig; % clears persistent figure counter 
    
    % copy DICOM dir from archive
    % system(['cp -R ' fullfile(dicomStorageDir,dicomSessionName) ' ' ...
    %    dicomBaseDir]);
    
    % prepareAnalysis(dicomDir, sesname, useOnlineRecon);
    
    assessSNR(sesname);
    assessVolumeCorrelation(sesname);
    
    %% image based functional analysis
    % time course on 70 percentile
    showFullTimeCourse(sesname);
    
    % event related on 70 percentile
    analyzeEv
        extractROIIntensityPrctile(data,prctileThreshold,normalizeFlag)
    
    % GLM on image
    
    
    % activation on image (from event related)? - normalization?
    % (event related w/o ROI?)
    
    %% layer based functional analysis
    
    % layer definition
    
    % event related on ROI of grid
    
    % event related f(depth)
    
    % event related f(position)
    
    % GLM and activation on layer grid
    
    % GLM and activatio f(position)
    
    % GLM and activatio f(depth)
      
catch ME
    disp(ME)
end