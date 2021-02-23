function defineLayerSampleGrids(sesname,endPoints)
config;
eval(sesname);

addpath(genpath(mrToolsPath));

if ~exist('endPoints','var')
    img = nanmean(loadFunctionalData(sesname),4);

    nSlices = size(img,3);

    img = permute(img,[2,1,3]);

    imagesc(img(:,:,floor(nSlices/2)));
    axis image;
    colormap gray;
    title('Select window ');
    winrect = getrect;

    endPoints = cell(1,nSlices);
    for z=1:nSlices
        imagesc(img(:,:,z));
        axis image;
        colormap gray;
        title(['Draw Sulcus for slice ' num2str(z)]);
        axis([winrect(1) winrect(1)+winrect(3) ...
            winrect(2) winrect(2)+winrect(4)]);
        roi = drawline;
        endPoints{z} = roi.Position;
    end
else
    nSlices = length(endPoints);
end

dx = 0.5;% mm
maximumDepth = 5; % mm
corticalDepths = 0:dx:maximumDepth;
nCorticalDepths = length(corticalDepths);

Xplus = cell(1,nSlices);
Xminus = cell(1,nSlices);
for z=1:nSlices
    p = endPoints{z}(2,:) - endPoints{z}(1,:);
    l = norm(p);
    p = p / norm(l);
    
    q = [p(2) -p(1)];
    
    % starting points (sulcus)
    corticalPositions = [fliplr(-dx:-dx:-l/2) 0:dx:l/2];
    nCorticalPositions = length(corticalPositions);
        
    X0 = bsxfun(@plus,...
        endPoints{z}(1,:)+l/2*p,...
        corticalPositions'*p);
        
    Xplus{z} = zeros(2,nCorticalPositions,nCorticalDepths);
    Xminus{z} = zeros(2,nCorticalPositions,nCorticalDepths);
    Xplus{z}(1,:,:) = ...
        round(bsxfun(@plus,X0(:,1),corticalDepths * q(1)));
    Xplus{z}(2,:,:) = ...
        round(bsxfun(@plus,X0(:,2),corticalDepths * q(2)));
    Xminus{z}(1,:,:) = ...
        round(bsxfun(@plus,X0(:,1),corticalDepths * -q(1)));
    Xminus{z}(2,:,:) = ...
        bsxfun(@plus,X0(:,2),[0:dx:maximumDepth] * -q(2));   
end

save(fullfile(dataDir,'anat',[sesname '_layerSampleGrid']),...
    'Xplus','Xminus');
save(fullfile(dataDir,'anat',[sesname '_sulcusEndPoints']),...
    'endPoints');
end
