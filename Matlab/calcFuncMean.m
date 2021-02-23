function calcFuncMean(sesname)
config;
eval(sesname);

addpath(genpath(mrToolsPath));


nScans = length(scanlist);
funcMeans = cell(nScans,1);
nVolumes = cell(nScans,1);
for zScan=1:nScans
    [data,hdr] = loadFunctionalData(sesname,zScan);
    funcMean = nanmean(data,4);
    hdrFuncMean = cbiSetNiftiQform(...
        cbiCreateNiftiHeader(funcMean),hdr.qform44);
    cbiWriteNifti([fullfile(dataDir,'func',sesname) '_funcmean_'.hdr'],...
        funcMean,hdrFuncMean);

    
    funcMeans{zScan} = nanmean(data,4);
    nVolumes{zScan} = sum(~isnan(data),4);


end
funcMeanAll = nansum(cat(4,funcMeans{:}).*cat(4,nVolumes{:}),4)./...
    nansum(cat(4,nVolumes{:}));

