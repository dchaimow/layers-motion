function data = ...
    extractROIIntensityPrctile(data,prctileThreshold,normalizeFlag)
sz = size(data);
dataFlat = reshape(data,[],sz(end));
dataFlatMean = nanmean(dataFlat,2);
threshold = prctile(dataFlatMean(:),prctileThreshold);
mask = dataFlatMean(:)>threshold;
        
dataFlat = dataFlat(mask,:);
if exist('normalizeFlag','var') && normalizeFlag
   dataFlat = bsxfun(@rdivide,dataFlat,dataFlatMean(mask));
end
data = nanmean(dataFlat,1);
end
