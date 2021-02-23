function showFullTimeCourse(sesname)
% TODO: use dataTransformFunction
prctileThreshold = 70;

config;
eval(sesname);

for zScan=1:nScans
    data = loadFunctionalData(sesname,zScan);
    meanImg = nanmean(data,4);
    threshold = prctile(meanImg(:),prctileThreshold);
    flatdata = reshape(data,[],size(data,4));
    flatdataNormalized = bsxfun(@rdivide,flatdata,meanImg(:))-1;
    
    % load stimulation protocol and determine stimulation paradigm
    stimData = load(fullfile(dataDir,'stim',stimFiles{zScan}));
    % NOTE: need to check that name of Blank condition is correct?
    paradigm = dcparadigmfromprotocol(stimData.scan,'Blank');
    startVols = [paradigm.startTimes{:}]/TR+1;
    stopVols = [paradigm.stopTimes{:}]/TR+1;
    
    
    figure;
    subplot(2,1,1);
    imagesc(meanImg(:,:,3)'.*(meanImg(:,:,3)'>threshold));
    title(['Signal intensity > ' num2str(prctileThreshold) ' percentile']);
    axis image;
    axis off;
    colormap gray;
    
    subplot(2,1,2);
    plot(nanmean(flatdataNormalized(meanImg(:)>threshold,:)),...
        'LineWidth',1.5);
    title('Average time course');
    axis tight;
    ax = axis;
    line([startVols(:) stopVols(:)], [ax(3) ax(3)],...
        'Color',[0 0 0],'LineWidth',3)
    grid;
    xlabel('volume no.');
    ylabel('relative change w.r.t. mean');
    
    sgtitle([sesname ', run ' num2str(zScan)]);
    
    dcprintfig([sesname '_fullTimeCourse_' num2str(zScan)],...
        16,16,fullfile(dataDir,'figures'))
    close(gcf);    
end
end

