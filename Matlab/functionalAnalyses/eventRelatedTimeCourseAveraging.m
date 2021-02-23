function [m,se,t,tStart,tStop] = ...
    eventRelatedTimeCourseAveraging(data,startTimes,stopTimes, TR)
sz = size(data);
nT = sz(end);
dataflat = reshape(data,[],nT);
assert(length(startTimes)==length(stopTimes));
nPresentations = length(startTimes);

preStim = 6; % s
preStimVols = round(preStim/TR);

startVols = startTimes/TR + 1;
stopVols = stopTimes/TR + 1;

blockDurationVols = (unique(stopVols-startVols));
assert(length(blockDurationVols)==1);

postStimVols = round(blockDurationVols * 2); 

stimPeriods = bsxfun(@plus,startVols,0:(blockDurationVols-1));
prePeriods =  bsxfun(@plus,startVols,-preStimVols:-1);
postPeriods = bsxfun(@plus,stopVols,0:postStimVols-1);

nVols = preStimVols+blockDurationVols+postStimVols;

eventRelatedData = zeros(size(dataflat,1),nVols,nPresentations);
for zPresentation  = 1:nPresentations
    baselineValues = mean(dataflat(:,prePeriods(zPresentation,:)),2);
    baselineValues(baselineValues==0) = nan;
    eventRelatedData(:,:,zPresentation) = bsxfun(@rdivide,...
        dataflat(:,...
        [prePeriods(zPresentation,:) ...
        stimPeriods(zPresentation,:), ...
        postPeriods(zPresentation,:)]),...
        baselineValues) - 1;
end

m = ...
    reshape(mean(eventRelatedData,3),[sz(1:end-1) nVols]);
se = ...
    reshape(mean(eventRelatedData,3),[sz(1:end-1) nVols])...
    ./sqrt(nPresentations);
t = [-preStimVols:-1, ...
    0:(blockDurationVols-1), ...
    blockDurationVols+(-0:postStimVols-1)] * TR;
tStart = 0;
tStop = blockDurationVols * TR;
end