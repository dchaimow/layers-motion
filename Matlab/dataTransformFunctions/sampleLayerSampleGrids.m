function dataSampled = ...
    sampleLayerSampleGrids(data,sesname,zSlice,plusMinus)
% data - functional data (i.e. dimensions of X,Y,slices,time)
% sesname - session name, used for loading sample grid
% zSlice - number of slice
% plusMinus - +1/-1 = sampling in pos./neg. direction orth. to sulcus

config;
eval(sesname)

load(fullfile(dataDir,'anat',[sesname '_layerSampleGrid']),...
    'Xplus','Xminus');

if plusMinus == 1
    samplePoints = Xplus{zSlice};
elseif plusMinus == -1
    samplePoints = Xminus{zSlice};
elseif plusMinus == 0
    samplePoints = cat(3,Xminus{zSlice}(:,:,end:-1:2), Xplus{zSlice});
else
    error('wrong argument value for plusMinus (should be +1/-1)');
end

nT = size(data,4);
nCorticalPositions = size(samplePoints,2);
nCorticalDepths = size(samplePoints,3);

dataSampled = zeros(nCorticalPositions,nCorticalDepths,nT);
for zT = 1:nT
    dataSampled(:,:,zT) = ...
        squeeze(data(sub2ind(size(data),...
        round(samplePoints(1,:,:)),...
        round(samplePoints(2,:,:)),...
        repmat(zSlice,[1,nCorticalPositions,nCorticalDepths]),...
        repmat(zT,[1,nCorticalPositions,nCorticalDepths]))));
end
end