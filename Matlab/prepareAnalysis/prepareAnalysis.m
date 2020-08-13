function prepareAnalysis(dicomDir,sesname,useOnlineRecon)
% purpose: convert evrything to nifti, (set qform), copy data, create m file
% for 7T high resolution (GRASE) sessions consisting of:
% - fieldmap data
% - T1 weighted 2 contrast anatomy
% - SWI
% - multiple GRASE runs of functional data with corresponding stimulation
%  ("result") files
% (NOTE: other data in some sessions? e.g. T1 in functional slices, GE BV?

% Requirements:
% mrTools
% dcm2niix
% offlineRecon_3D code

% TODO:
% - modify offline recon
% - info is not extracted in online recon (including echo spacing for
%   unwarping)

config;

% add paths
addpath(genpath(mrToolsPath));
addpath(genpath(offlineReconPath));

%% Set all information
if ~exist('sesname','var')
    tkns = regexp(dicomDir,'dc(m\d\d\d\d\d\d\d\d)','tokens');
    sesname = tkns{1}{1};
end

niftiDir = fullfile(sesParentDir,'nifti');

% find fieldmap data
a = dir(fullfile(dicomDir,'*gre_field_mapping'));
phaseScan = a(end).name;
magScan = ['MR' phaseScan(3:5) ...
    sprintf('%.3d', str2double(phaseScan(6:8))-1) ...
    phaseScan(9:end)];
phaseDir = fullfile(dicomDir,phaseScan);
magDir = fullfile(dicomDir,magScan);
phaNiftiFileBaseName = fullfile(niftiDir,[sesname '_pha']);
magNiftiFileBaseName = fullfile(niftiDir,[sesname '_mag']);

% find 3danatdir
a = dir(fullfile(dicomDir,'*-eja_tfl_2contrast*'));
anat3dDir = fullfile(dicomDir,a(end).name);
anatNiftiFileBaseName = fullfile(niftiDir,[sesname '_anat']);

% find swi data
a = dir(fullfile(dicomDir,'*_Images'));
swiPhaseScan = a(end).name;
swiMagScan = a(length(a)/2).name;
swiMagNormScan = ['MR' swiMagScan(3:5) ...
    sprintf('%.3d', str2double(swiMagScan(6:8))+1) ...
    swiMagScan(9:end) '-Norm'];
swiPhaseDir = fullfile(dicomDir,swiPhaseScan);
swiMagDir = fullfile(dicomDir,swiMagScan);
swiMagNormDir =  fullfile(dicomDir,swiMagNormScan);
swiPhaNiftiFileBaseName = fullfile(niftiDir,[sesname '_swipha']);
swiMagNiftiFileBaseName = fullfile(niftiDir,[sesname '_swimag']);
swiMagNormNiftiFileBaseName = fullfile(niftiDir,[sesname '_swimagnorm']);

% find func dirs, assume all scans with func in the name
a = dir(fullfile(dicomDir,'*func'));
nScans = length(a);
funcDirs = cell(1,nScans);
funcNiftiFileBaseName  = cell(1,length(funcDirs));
for z=1:nScans
    funcDirs{z} = fullfile(dicomDir,a(z).name);
    funcNiftiFileBaseName{z} = fullfile(niftiDir,...
        [sesname '_func_' num2str(z,'%.2d')]);
end

%% Nifti conversion
% create nifti dir
if exist(niftiDir,'dir')
    rmdir(niftiDir,'s');
end
mkdir(niftiDir);

%nifti conversion of fieldmap data
phaNiftiFileBaseName = ...
    convertDICOM2Nifti(phaseDir, niftiDir, phaNiftiFileBaseName);
magNiftiFileBaseName = ...
    convertDICOM2Nifti(magDir, niftiDir, magNiftiFileBaseName);

% nifti conversion of 3d anat
anatNiftiFileBaseName = ...
    convertDICOM2Nifti(anat3dDir, niftiDir, anatNiftiFileBaseName);

% nifti conversion of SWI
swiPhaNiftiFileBaseName = ...
    convertDICOM2Nifti(swiPhaseDir, niftiDir, swiPhaNiftiFileBaseName);
swiMagNiftiFileBaseName = ...
    convertDICOM2Nifti(swiMagDir, niftiDir, swiMagNiftiFileBaseName);
swiMagNormNiftiFileBaseName = ...
    convertDICOM2Nifti(swiMagNormDir, niftiDir, swiMagNormNiftiFileBaseName);

% nifti conversion of func
funcParameters = cell(1,length(funcDirs));
for z=1:length(funcDirs)
    a = dir(fullfile(funcDirs{z},'*.dat'));
    if isempty(a) || useOnlineRecon
        funcNiftiFileBaseName{z} = ...
            convertDICOM2Nifti(...
            funcDirs{z}, niftiDir, funcNiftiFileBaseName{z});
    else
        %% STILL TODO:
        error('modify offline recon!');
        dcOfflineRecon2Nifti(nFuncSlices,a(1).name,funcFileBase{z});
    end
    funcParameters{z} = ...
        jsondecode(fileread([funcNiftiFileBaseName{z} '.json']));
end

%% Copy all files
% create directory structure
mkdir(sesParentDir,sesname);
mkdir(fullfile(sesParentDir,sesname),'anat');
mkdir(fullfile(sesParentDir,sesname),'func');
mkdir(fullfile(sesParentDir,sesname),'stim');
mkdir(fullfile(sesParentDir,sesname),'results');
mkdir(fullfile(sesParentDir,sesname),'figures');

% copy anat
system(['cp ' fullfile(niftiDir,'*anat*') ' ' ...
    fullfile(sesParentDir,sesname,'anat')]);
system(['cp ' fullfile(niftiDir,'*mag*') ' ' ...
    fullfile(sesParentDir,sesname,'anat')]);
system(['cp ' fullfile(niftiDir,'*pha*') ' ' ...
    fullfile(sesParentDir,sesname,'anat')]);
system(['cp ' fullfile(niftiDir,'*swi*') ' ' ...
    fullfile(sesParentDir,sesname,'anat')]);

% copy func
system(['cp ' fullfile(niftiDir,'*func*') ' ' ...
    fullfile(sesParentDir,sesname,'func/')]);

% check and assign stimfiles, copy
aa = dir(fullfile(resultDir, ['*' sesname(1:3) '*' sesname(4:end) '*']));
stimFileName = cell(1,length(funcNiftiFileBaseName));
zScan = 1;
for zStim=1:length(aa)
    scanStartTime = datevec(funcParameters{zScan}.AcquisitionTime);
    hdr = cbiReadNiftiHeader([funcNiftiFileBaseName{zScan} '.hdr']);
    scanDuration = hdr.dim(5) * funcParameters{z}.RepetitionTime;
    
    s = load(fullfile(aa(zStim).folder,aa(zStim).name));
    stimStartTime = datevec(s.scan.startTime);
    stimStopTime = datevec(s.scan.stopTime);
    stimDuration = datetime(stimStopTime) - datetime(stimStartTime);        
           
    stimStartTime(1:3) = 0;
    scanStartTime(1:3) = 0;   
    startGap = abs(datetime(scanStartTime)-...
        datetime(stimStartTime));    
    durationGap = abs(stimDuration - seconds * scanDuration);
    
    if startGap > duration('00:00:02')
        error('Difference between stimfile start and scan start > 2 s, please check!');
    elseif durationGap > duration('00:00:02')
        error('Difference between stim duration and scan duration > 2 s, please check!');
    else
        stimFileName{zScan} = aa(zStim).name;
        copyfile(fullfile(resultDir,stimFileName{zScan}),...
            fullfile(sesParentDir,sesname,'stim/'));
        zScan = zScan + 1;
    end
    if zScan > length(funcNiftiFileBaseName)
        break;
    end
end

% extract consistent TR
TR = extractSameParameter(funcParameters,@(c) c.RepetitionTime);

% remove nifti dir
rmdir(niftiDir,'s');

% remove nifti directory from file names
[~,anatNiftiFileBaseName,~] = fileparts(anatNiftiFileBaseName);
[~,magNiftiFileBaseName,~] = fileparts(magNiftiFileBaseName);
[~,phaNiftiFileBaseName,~] = fileparts(phaNiftiFileBaseName);
[~,swiMagNiftiFileBaseName,~] = fileparts(swiMagNiftiFileBaseName);
[~,swiPhaNiftiFileBaseName,~] = fileparts(swiPhaNiftiFileBaseName);
[~,swiMagNormNiftiFileBaseName,~] = fileparts(swiMagNormNiftiFileBaseName);
for zz=1:length(funcNiftiFileBaseName)
    [~,funcNiftiFileBaseName{zz},~] = fileparts(funcNiftiFileBaseName{zz});
end

%% create m file
str0 = '%% Define parameters';
str1 = ['dataDir = ''' fullfile(sesParentDir,sesname) ''';'];
str2 = ['anatFile= ''' anatNiftiFileBaseName  ''';'];
str3 = ['magFile = ''' magNiftiFileBaseName  ''';'];
str4 = ['phaFile = ''' phaNiftiFileBaseName  ''';'];
str5 = ['swiMagFile = ''' swiMagNiftiFileBaseName  ''';'];
str6 = ['swiPhaFile = ''' swiPhaNiftiFileBaseName  ''';'];
str7 = ['swiMagNormFile = ''' swiMagNormNiftiFileBaseName ''';'];
str8 = 'scanlist = {';
for zz=1:length(funcNiftiFileBaseName)
    str8 = [str8 '''' funcNiftiFileBaseName{zz}  ''';\n'];
end
str8(end-2:end-1)= '};';
str8 = str8(1:end-1);

str9 = 'stimFiles = {';
for zStim = 1:length(stimFileName)
    str9 = [str9 '''' stimFileName{zStim} ''';\n'];
end
str9(end-2:end-1)= '};';
str9 = str9(1:end-1);

str10 = ['nScans = length(scanlist); \n' ...
    'TR = ' num2str(TR) ';'];


str = [str0 '\n' str1 '\n\n' str2 '\n\n' str3 '\n' str4 '\n\n' ...
    str5 '\n' str6 '\n' str7 '\n\n' str8 '\n\n' str9 '\n\n' str10];

fid = fopen(fullfile(rootDir,'sessionParameters',[sesname '.m']),'w');
fprintf(fid, str);
fclose(fid);
end

function niftiFileBaseName = ...
    convertDICOM2Nifti(dicomDir,niftiDir,requestedNiftiFileBaseName)
config;

[status,cmdout] = ...
    system([dcm2niixPath ' -b y -ba y -f  %n-%2s-%p  -m y' ...
    ' -o ' niftiDir ' -z n ' dicomDir]);
if status
    error(['DICOM to Nifti conversion of ' dicomDir ' failed.']);
else
    tkns = regexp(cmdout,'DICOM as (.*?) \(','tokens');
    assert(length(tkns)==1);
    assert(length(tkns{1})==1);    
    niftiFileBaseName = tkns{1}{1};    
end

if exist('requestedNiftiFileBaseName','var')
    a = dir([niftiFileBaseName '*']);
    for z=1:length(a)
        [~,~,ext] = fileparts(a(z).name);
        system(['mv ' fullfile(a(z).folder,a(z).name) ' ' ...
            requestedNiftiFileBaseName ext]);
    end   
    niftiFileBaseName = requestedNiftiFileBaseName;
end

% convert to NIFTI pair
system(['export FSLDIR=' fslDir ...
    ';export PATH=$PATH:' fullfile(fslDir,'bin') ...
    ';fslchfiletype NIFTI_PAIR ' niftiFileBaseName]);
end

function dcOfflineRecon2Nifti(nSlices, datFile, niftiFile, diniftiPath)
%estimate number of slices or define number of slices
%offline recon to sdt -> tmp directory
%convert online recon dicom to nifti -> tmp directory
%save offline recon sdt to nifti using online nifti header
%delete offline sdt and online nifti in tmp directory
%copy offline recon nifti in destination diretory
sliceOrder = [nSlices/2 + 1 : -1 : 1 nSlices:-1:nSlices/2+2];
[dicomDir,datBase,~] = fileparts(datFile);
[tmpDir,~,~] = fileparts(niftiFile);

system([diniftiPath ' -f n2 -s ' ...
    num2str(nSlices) ' *.dcm ' niftiFile]);
[img,hdr] = cbiReadNifti([niftiFile '.hdr']);

a = dir('*.dcm');
dcminf = dicominfo(a(1).name);

%[outImgAb,outImgPh,info] = dcOfflineRecon3D(fullfile(dicomDir,datBase));
[outImgAb,~,info] = dcOfflineRecon3D(fullfile(dicomDir,datBase));

data = outImgAb;
%dataPh = outImgPh;

%data = (10000*data)/max(data(:));
data = data * 10000;
data = data(:,:,sliceOrder,:);
%dataPh = dataPh(:,:,sliceOrder,:);

dataM = mean(data,4);
imgM  = mean(img(:,:,:,2:end),4);

c1 = corrcoef(imgM, flipdim(circshift(dataM,[0 -1 0 0]),2));
c2 = corrcoef(imgM, flipdim(circshift(dataM,[-1 0 0 0]),1));

if c1(1,2)>c2(1,2)
    data = flipdim(circshift(data,[0 -1 0 0]),2);
    %   dataPh = flipdim(circshift(dataPh,[0 -1 0 0]),2);
else
    data = flipdim(circshift(data,[-1 0 0 0]),1);
    %   dataPh = flipdim(circshift(dataPh,[0 -1 0 0]),2);
end

hdr = cbiSetNiftiQform(cbiCreateNiftiHeader(data),hdr.qform44);
cbiWriteNifti([niftiFile '.hdr'],data,hdr);
%hdr = cbiSetNiftiQform(cbiCreateNiftiHeader(dataPh),hdr.qform44);
%cbiWriteNifti([niftiFile '_ph.hdr'],dataPh,hdr);
info.dicom = dcminf;
save([niftiFile '_info'],'info');
end