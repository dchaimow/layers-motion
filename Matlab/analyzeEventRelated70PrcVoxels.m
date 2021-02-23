function analyzeEventRelated70PrcVoxels(sesname)
% analyze functional data of a session runwise using GLM
% and combine results across runs
% NOTE: CRF data may need to be analyzed differently (see
% dcAllScansFullGLM.m)

config;
eval(sesname);

dataTransformFunction = @(data) extractROIIntensityPrctile(data,70,true);

eventRelatedData = cell(1,nScans);
eventRelatedAverage = cell(1,nScans);
for zScan=1:nScans
    eventRelatedData{zScan} = ...
        alignEventRelatedSingleRun(sesname,zScan,dataTransformFunction);
    eventRelatedAverage{zScan} = ...
        averageEventRelated(eventRelatedData{zScan});       
    visualizeEventRelatedAverageTcrs(eventRelatedAverage{zScan});
    
    sgtitle([sesname ', run ' num2str(zScan)]);
    dcprintfig([sesname '_eventRelated70PrcVoxels_run_' num2str(zScan)],...
        24,18,fullfile(dataDir,'figures'))
    close(gcf);

end
eventRelatedAverageOverAllRuns = ...
    averageEventRelated(eventRelatedData);
visualizeEventRelatedAverageTcrs(eventRelatedAverageOverAllRuns);
sgtitle([sesname ', all runs']);
dcprintfig([sesname '_eventRelated70PrcVoxels_allruns'],24,18,fullfile(dataDir,'figures'))
close(gcf);
end



