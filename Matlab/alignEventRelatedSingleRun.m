function eventRelatedData = ...
    alignEventRelatedSingleRun(sesname,zScan,dataTransformFunction)

config;
eval(sesname);

% load stimulation protocol and determine stimulation paradigm
stimData = load(fullfile(dataDir,'stim',stimFiles{zScan}));
paradigmFull = dcparadigmfromprotocol(stimData.scan,'');
paradigm = dcparadigmfromprotocol(stimData.scan,'Blank');
nConditionsFull = length(paradigmFull.conditionList);
nConditions = length(paradigm.conditionList);
% check that blank condition was removed:
assert(nConditionsFull==nConditions+1);

% load data
data = loadFunctionalData(sesname,zScan);
if exist('dataTransformFunction','var')
    data = dataTransformFunction(data);
end

eventRelatedData = struct();
for zCondition = 1:nConditions
    startTimes = paradigm.startTimes{zCondition};
    stopTimes = paradigm.stopTimes{zCondition};
    [alignedData,t,tStart,tStop] = ...
        eventRelatedTimeCourseAlignment(...
        data,startTimes,stopTimes, TR);
    eventRelatedData(zCondition).condition = ...
        paradigm.conditionList{zCondition};
    eventRelatedData(zCondition).alignedData = alignedData;
    eventRelatedData(zCondition).t = t;
    eventRelatedData(zCondition).tStart = tStart;
    eventRelatedData(zCondition).tStop = tStop;
end
end