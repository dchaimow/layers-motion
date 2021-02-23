function data = extractROI(data,ROI,normalizeFlag)
sz = size(data);
dataFlat = reshape(data,[],sz(end));
dataFlatROI = dataFlat(logical(ROI(:)),:);
if exist('normalizeFlag','var') && normalizeFlag
   dataFlatROI = bsxfun(@rdivide,dataFlatROI,nanmean(dataFlatROI,2));
end
data = nanmean(dataFlatROI,1);
end
