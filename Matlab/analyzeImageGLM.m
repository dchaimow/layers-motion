function analyzeImageGLM(sesname)
config;
eval(sesname);

addpath(genpath(mrToolsPath));


glmResults = cell(1,nScans);
for zScan=1:nScans
    glmResults{zScan} = dcGLMAnalysis(...
        sesname, zScan);
    visualizeImageGLMResults(glmResults{zScan});
    sgtitle([sesname ', run ' num2str(zScan)]);
    dcprintfig([sesname '_imageGLM_run_' num2str(zScan)],...
        36,16,fullfile(dataDir,'figures'))
    close(gcf);
end
glmResultsOverAllRuns = dcGLMAnalysis(...
        sesname, []);
visualizeImageGLMResults(glmResultsOverAllRuns);
sgtitle([sesname ', all runs']);
dcprintfig([sesname '_imageGLM_allruns'],36,16,fullfile(dataDir,'figures'))
close(gcf);
end