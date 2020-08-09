function assessSNR(sesname)
% displays variation and SNR of the functional data of a session
% run-wise and overall

config;
eval(sesname);

for zScan=1:nScans
    visualizeSNR(sesname,zScan)
    sgtitle([sesname ', run ' num2str(zScan)]);
    dcprintfig([sesname '_assessSNR_run_' num2str(zScan)],...
        36,16,fullfile(dataDir,'figures'))
    close(gcf);
end
visualizeSNR(sesname);
sgtitle([sesname ', all runs concatenated']);
dcprintfig([sesname '_assessSNR_allruns'],36,16,fullfile(dataDir,'figures'))
close(gcf);
end

function visualizeSNR(sesname,scanNumber)
config;
eval(sesname);

if exist('scanNumber','var')
    data = loadFunctionalData(sesname,scanNumber);
else
    data = loadFunctionalData(sesname);
end
figure;
mdata = nanmean(data,4);
sdata = nanstd(data,0,4);
vdata = sdata.^2;
snrdata = mdata./sdata;



nSlices = size(data,3);

for zSlice = 1:nSlices
    subplot(nSlices,4,1+(zSlice-1)*4);
    imagesc(mdata(:,:,zSlice)');
    axis image;
    ylabel(['Slice ' num2str(zSlice)]);
    colormap(gca,gray);
    set(gca,'XTickLabels','');
    set(gca,'YTickLabels','');
    subplot(nSlices,4,2+(zSlice-1)*4);
    imagesc(vdata(:,:,zSlice)');
    axis image;
    axis off;
    subplot(nSlices,4,3+(zSlice-1)*4);
    imagesc(snrdata(:,:,zSlice)',[0 30]);
    axis image;
    axis off;
end

subplot(nSlices,4,1);
title('Mean')

subplot(nSlices,4,2);
title('Variance')

subplot(nSlices,4,3);
title('SNR');

subplot(1,4,4);
histogram(snrdata(:));
title({'SNR histogram',['(90-percentile = ' ...
    num2str(prctile(snrdata(:),90),3) ')']});
xlabel('SNR');
set(gca,'YTickLabels','');
end