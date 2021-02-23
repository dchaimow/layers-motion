function visualizeLayerGLMResults(glmResults)
figure;
nConditions = length(glmResults.conditionList);
p = zeros(1,nConditions);
for zCondition = 1:nConditions
    p(zCondition) = plot(-5:0.5:5,...
        mean(glmResults.cb(:,:,zCondition)./...
        glmResults.cb(:,:,nConditions+1)),'LineWidth',1.5);
    
    %p(zCondition) = errorbar(-5:0.5:5,...
    %    mean(glmResults{zScan}.cb(:,:,zCondition)./...
    %    glmResults{zScan}.cb(:,:,nConditions+1)),...
    %    mean(glmResults{zScan}.cbError(:,:,zCondition)./...
    %    glmResults{zScan}.cb(:,:,nConditions+1)),'LineWidth',1.5);
    
    hold on;
end
hold off;
grid;
axis([-5 5 -0.05 0.15]);
line([0 0],[-0.05 0.15],'LineStyle',':','Color','k');
xlabel('cortical depth [mm]');
ylabel('relative change');
legend(p,glmResults.conditionList);
end


