function assessVolumeCorrelation(sesname)
% displays correlation between volume of the functional data of a session
% run-wise and overall

config;
eval(sesname);

for zScan=1:nScans
    visualizeVolumeCorrelation(sesname,zScan)
    sgtitle([sesname ', run ' num2str(zScan)]);
     dcprintfig([sesname '_assessVolumeCorrelation_run_' num2str(zScan)],...
        16,24,fullfile(dataDir,'figures'))
    close(gcf);
end
visualizeVolumeCorrelation(sesname);
sgtitle([sesname ', all runs concatenated']);
dcprintfig([sesname '_assessVolumeCorrelation_allruns'],...
    16,24,fullfile(dataDir,'figures'))
close(gcf);
end

function visualizeVolumeCorrelation(sesname,scanNumber)
config;
eval(sesname);

if exist('scanNumber','var')
    data = loadFunctionalData(sesname,scanNumber);
else
    data = loadFunctionalData(sesname);
end

figure;

c = corrcoef(reshape(data,[],size(data,4)));

subplot(5,1,[1 4]);
imagesc(c,[0.75 1]);
axis equal;
axis tight;
colorbar('southoutside');
title('Correlation between volumes');
ylabel('volume no.');

subplot(5,1,5);
plot(nanmean(c));
axis tight;
xlabel('volume no.');
title('Average correlation for each volume')
end