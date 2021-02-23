function [alignedData,t,tStart,tStop] = ...
    eventRelatedTimeCourseAlignment(data,startTimes,stopTimes, TR)
% parameters
normalizeFlag = true; % normalize rel. to. voxel signal intensity
preStim = 6; % s
postStimFactor = 1; % post stim time relative to stim time

sz = size(data);
nT = sz(end);

dataFlat = reshape(data,[],nT);
if normalizeFlag
    meanDataFlat = nanmean(dataFlat,2);
    dataFlat = bsxfun(@rdivide,dataFlat,meanDataFlat);
end

assert(length(startTimes)==length(stopTimes));
nPresentations = length(startTimes);

preStimVols = round(preStim/TR);
startVols = startTimes/TR + 1;
stopVols = stopTimes/TR + 1;
blockDurationVols = (unique(stopVols-startVols));
assert(length(blockDurationVols)==1);
postStimVols = round(blockDurationVols * postStimFactor); 

stimPeriods = bsxfun(@plus,startVols,0:(blockDurationVols-1));
prePeriods =  bsxfun(@plus,startVols,-preStimVols:-1);
postPeriods = bsxfun(@plus,stopVols,0:postStimVols-1);

nVols = preStimVols+blockDurationVols+postStimVols;

alignedData = zeros(size(dataFlat,1),nVols,nPresentations);
for zPresentation  = 1:nPresentations
    alignedData(:,:,zPresentation) = dataFlat(:,...
        [prePeriods(zPresentation,:) ...
        stimPeriods(zPresentation,:), ...
        postPeriods(zPresentation,:)]);
end
t = [-preStimVols:-1, ...
    0:(blockDurationVols-1), ...
    blockDurationVols+(-0:postStimVols-1)] * TR;
tStart = 0;
tStop = blockDurationVols * TR;
end