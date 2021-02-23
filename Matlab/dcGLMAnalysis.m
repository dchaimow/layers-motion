function glmResults = ...
    dcGLMAnalysis(sesname,zScan,dataTransformFunction)
config;
eval(sesname);



if exist('zScan','var') && ~isempty(zScan)
    [DM,conditionList] = buildSingleRunDesignMatrix(sesname,zScan);
    data = loadFunctionalData(sesname,zScan);
    nConditions = length(conditionList);
    contrasts = cell(1,nConditions+1);
    for zContrast=1:nConditions+1
        contrasts{zContrast} = zeros(1,nConditions);
        contrasts{zContrast}(zContrast) = 1;
    end
else
    [DM,conditionList] = buildMultiRunDesignMatrix(sesname);
    data = loadFunctionalData(sesname);
    nConditions = length(conditionList);
    contrasts = cell(1,nConditions+1);
    nPredictorsPerRun = size(DM,2)/nScans;    
    for zContrast=1:nConditions+1
        singleRunContrast = zeros(1,nPredictorsPerRun);
        singleRunContrast(zContrast) = 1;
        contrasts{zContrast} = ...
            repmat(singleRunContrast,[1 nScans])/nScans;
    end

end

% process data (apply dataTransform)
if exist('dataTransformFunction','var')
    data = dataTransformFunction(data);
end

% fit GLM
[beta, dataModeled, dataResiduals, DMValid] = fitglm(DM,data);

% calculate contrasts
[cb,cbError,ct,cp] = ...
    calculateGLMContrastResults(DMValid,beta,dataResiduals,contrasts);

glmResults.cb = cb;
glmResults.cbError = cbError;
glmResults.ct = ct;
glmResults.cp = cp;
glmResults.contrasts = contrasts;
glmResults.conditionList = conditionList;

% organize results
%figure;
%subplot(1,2,1);

%plot(mean(reshape(data(132:151, 25:29, :,2:end),[],size(data,4)-1)));
%hold on;
%plot(mean(reshape(dataModeled(132:151, 25:29, :,2:end),[],size(data,4)-1)));
%axis tight;
%hold off;
end

function [DM,conditionList] = buildMultiRunDesignMatrix(sesname)
config;
eval(sesname);

sDM = cell(1,nScans);
scanConditionLists = cell(1,nScans);
for zScan = 1:nScans
   [sDM{zScan},scanConditionLists{zScan}] = ...
       buildSingleRunDesignMatrix(sesname,zScan);
end
% make sure conditions an their order is identical between runs
conditionList = extractSameParameter(scanConditionLists,@(c) c);

% make sure design matrices have the same size (change to allow diff. nT)
sDMDims = extractSameParameter(sDM,@(c) size(c));
nT = sDMDims(1);
nPredictors = sDMDims(2);

DM = zeros(nScans*sDMDims);
for zScan=1:nScans
    DM((1:nT)+nT*(zScan-1),(1:nPredictors)+nPredictors*(zScan-1)) = ...
        sDM{zScan};
    %for zPredictor=1:nPredictors
    %    DM((1:nT)+nT*(zScan-1),(zPredictor-1)*nScans+zScan) = ...
    %        sDM{zScan}(:,zPredictor);
    %end    
end
end

function [DM,conditionList] = buildSingleRunDesignMatrix(sesname,zScan)
% builds single run desing matrix WITHOU constant predictor
config;
eval(sesname);

% set number of volumes
hdr = cbiReadNiftiHeader(...
    fullfile(dataDir,'func',[scanlist{zScan} '.hdr']));
nT = hdr.dim(5);

% load stimulation protocol and determine stimulation paradigm
stimData = load(fullfile(dataDir,'stim',stimFiles{zScan}));
% NOTE: need to check that name of Blank condition is correct?
paradigm = dcparadigmfromprotocol(stimData.scan,'Blank');

DMConst = constPredictor(nT);
DMStim  = stimPredictor(paradigm, nT, TR);
DMLin   = linearTrendPredictor(nT);

DM = [DMStim DMConst DMLin ];
conditionList = paradigm.conditionList;
end



function [beta,dataModelled,dataResiduals,DMValid] = fitglm(DM,data)
sz = size(data);
nT = sz(end);
dataFlat = reshape(data,[],nT)';

noData = any(isnan(DM),2) | any(isnan(dataFlat),2);

DMValid = DM(~noData,:);
dataFlatValid = dataFlat(~noData,:);

A = DMValid'*DMValid;
betaFlat = (A\DMValid')*dataFlatValid;

dataModelledFlat = nan(size(dataFlat));
dataModelledFlat(~noData,:) = DMValid*betaFlat;
dataResidualsFlat = nan(size(dataFlat));
dataResidualsFlat(~noData,:) = dataFlatValid - dataModelledFlat(~noData,:);

beta = reshape(betaFlat',[sz(1:end-1) size(betaFlat,1)]);
dataModelled = reshape(dataModelledFlat',...
    [sz(1:end-1) size(dataModelledFlat,1)]);
dataResiduals = reshape(dataResidualsFlat',...
    [sz(1:end-1) size(dataResidualsFlat,1)]);
end

function [cb,cbError,ct,cp] = ...
    calculateGLMContrastResults(DM,beta,dataResiduals,contrasts)
sz = size(dataResiduals);
nT = sz(end);
nDMPred = size(DM,2);
df = size(DM,1)-rank(DM);

betaFlat = reshape(beta,[],nDMPred)';
dataResidualsFlat = reshape(dataResiduals,[],nT)';

residualVariance = nansum(dataResidualsFlat.*dataResidualsFlat)/df;
A = DM'*DM;

nContrasts = length(contrasts);


cbErrorFlat = zeros([nContrasts prod(sz(1:end-1))]);
cbFlat = zeros([nContrasts prod(sz(1:end-1))]);
ctFlat = zeros([nContrasts prod(sz(1:end-1))]);
cpFlat = zeros([nContrasts prod(sz(1:end-1))]);

for zContrast = 1:length(contrasts)
    c = zeros(nDMPred,1);
    c(1:length(contrasts{zContrast})) = contrasts{zContrast};
    
    cbErrorFlat(zContrast,:) = sqrt(residualVariance*(c'* (A \ c)));
    ctFlat(zContrast,:) = (c'*betaFlat)./cbErrorFlat(zContrast,:);
    cbFlat(zContrast,:) = c'*betaFlat;
    cpFlat(zContrast,:) = 2*(1-tcdf(abs(ctFlat(zContrast,:)),df));
end
cb = reshape(cbFlat',[sz(1:end-1) size(cbFlat,1)]);
cbError = reshape(cbErrorFlat',[sz(1:end-1) size(cbErrorFlat,1)]);
ct = reshape(ctFlat',[sz(1:end-1) size(ctFlat,1)]);
cp = reshape(cpFlat',[sz(1:end-1) size(cpFlat,1)]);
end

function [tMap,pMap,bMap] = maps(DM,residualsFlat,betaFlat,dataSize,contrasts)
nDMPred = size(DM,2);
df = size(DM,1)-rank(DM);
residualVariance = sum(residualsFlat.*residualsFlat)/df;
A = DM'*DM;

nContrasts = length(contrasts);
tMap = zeros([dataSize nContrasts]);w
pMap = zeros([dataSize nContrasts]);
bMap = zeros([dataSize nContrasts]);

for zContrasts = 1:length(contrasts)
    c = zeros(nDMPred,1);
    c(1:length(contrasts{zContrasts})) = contrasts{zContrasts};
    betaErrorFlat = sqrt(residualVariance*(c'* (A \ c)));
    tFlat = (c'*betaFlat)./betaErrorFlat;
    bFlat = c'*betaFlat;
    %two sided ttest? p that abs(T) larger t_est
    pFlat = 2*(1-tcdf(abs(tFlat),df));
    tMap(:,:,:,zContrasts) = reshape(tFlat,dataSize);
    pMap(:,:,:,zContrasts) = reshape(pFlat,dataSize);
    bMap(:,:,:,zContrasts) = reshape(bFlat,dataSize);
end
end

function DM = stimPredictor(paradigm,nT,TR)
% construct stimulation design matrix
nConditions = length(paradigm.conditionList);
t = (0:nT-1)*TR;
DM = zeros(nT,nConditions);
for zCondition = 1:nConditions
    for zPresentation = 1:length(paradigm.startTimes{zCondition})
        tStart =  paradigm.startTimes{zCondition}(zPresentation);
        tEnd = paradigm.stopTimes{zCondition}(zPresentation);
        DM(:,zCondition) = DM(:,zCondition) + hrffunc(t,tStart,tEnd)';
    end
    % normalization
    if max(DM(:,zCondition))
        DM(:,zCondition) = DM(:,zCondition)/max(DM(:,zCondition));
    end
end
end

function DM = constPredictor(nT)
DM = ones(nT,1);
end

function DM = linearTrendPredictor(nT)
DM = linspace(-1,1,nT)';
end
