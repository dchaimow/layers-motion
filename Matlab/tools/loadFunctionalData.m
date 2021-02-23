function [data, hdr] = loadFunctionalData(sesname,scanNumber)
config;
eval(sesname);

addpath(genpath(mrToolsPath));

% get file names and number of volumes
dims = zeros(nScans,4);
for zScans=1:nScans
    basename = fullfile(dataDir,'func',scanlist{zScans});
    if exist([basename '_uw_mc_reg.hdr'],'file')
        basename = [basename '_uw_mc_reg'];
    end
    if exist([basename '_uw.hdr'],'file')
        basename = [basename '_uw'];
    end
    if exist([basename '_mc_reg.hdr'],'file')
        basename = [basename '_mc_reg'];
    end
    dataFName{zScans} = basename;
    hdr = cbiReadNiftiHeader([dataFName{zScans} '.hdr']);
    dims(zScans,:) = hdr.dim(2:5);
end

% load data
if exist('scanNumber','var')
    data = cbiReadNifti(dataFName{scanNumber});
    data(:,:,:,1) = nan;
else
    % NOTE: what if nT differs between scans?
    nT = dims(1,4);
    data = zeros([dims(1,1:3) nT*nScans]);
    for zScans=1:nScans
        data(:,:,:,(1:nT)+(zScans-1)*nT) = ...
            cbiReadNifti(dataFName{zScans});
        data(:,:,:,1+(zScans-1)*nT) = nan;
    end
end
end