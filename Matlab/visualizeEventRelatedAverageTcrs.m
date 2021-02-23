function visualizeEventRelatedAverageTcrs(eventRelatedAverage)
% most simple: average all time courses w/o ROI
% SE from std over all these responses
% alternatives:
% use ROI
% multidimensional plots
% average standard errors
% use standard error of only single time courses/ ROI size = 1
%
% compare applying ROI before/while calculating event relate average
% and applying it here
%
% what about parametrizaition of time courses: 
% e.g. layer dependent, position dependent

figure;

conditionList = {eventRelatedAverage(:).condition};
nConditions = length(conditionList);
for zCondition=1:nConditions 
    baselineVols = eventRelatedAverage(zCondition).t < ...
        eventRelatedAverage(zCondition).tStart;
    baseline = nanmean(eventRelatedAverage(zCondition).m(baselineVols));
                
    errorbar(eventRelatedAverage(zCondition).t,...
        eventRelatedAverage(zCondition).m/baseline-1,...
        eventRelatedAverage(zCondition).se/baseline,'LineWidth',1.5);
    hold on;
end

grid;
axis tight;
ax = axis;
line([eventRelatedAverage(zCondition).tStart ...
    eventRelatedAverage(zCondition).tStop],...
    [ax(3) ax(3)],'LineWidth',6,'Color',[0 0 0 ]);
hold off;
legend(conditionList);
end
