function maxRange = dcrendermap(anat,map,mask,clip)
%DCRENDERMAP  ...
%   Requirements
%
%   Design
%
%   Interfaces
%
%   Discussion
%

% Copyright 2008 Denis Chaimow.
% Created by Denis Chaimow on 06-Nov-2008 21:11:58
% $Id$'

%TODO: Write documentation
%TODO: Implement first version
if exist ('clip','var') && length(clip)==2
    minRange = clip(1);
    maxRange = clip(2);
elseif exist('clip','var') && clip < 0
    maxRange = prc_vctr(abs(map(mask==1)),0.95);
    minRange = -maxRange;
elseif exist('clip','var') && clip
    maxRange = clip;
    minRange = -maxRange;
else
    maxRange = prctile(abs(map(mask==1)),95);
    minRange = -maxRange;
end
if any(mask(:))
imagesc(map.*mask,[minRange maxRange]);
end
axis image;
%colorbar;
hold on;

anatAdj = (anat-min(anat(:)))/(max(anat(:))-min(anat(:)));
anatRGB = ind2rgb(round(anatAdj*256),gray(256));

%mapAdj = imadjust(map);
%mapRGB = ind2rgb(round(anatAdj*size(cmap,1)),cmap);

imshow(anatRGB);
if(any(mask(:)))
hold on;
h = imagesc(map,[minRange maxRange]);
set(h, 'AlphaData', mask);
hold off;
end