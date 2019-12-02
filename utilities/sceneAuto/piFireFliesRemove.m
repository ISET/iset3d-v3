function oi = piFireFliesRemove(ieObject,varargin)
% Find and remove fireflies(ray-tracing artifacts) in the image
%
% Syntax
%   oi = piFireFliesRemove(ieObject)
% 
% Input
%   ieObject - an optical image
% 
% Optional key/val pairs
%   show flies -  logical, default false
%
% Description
%   The rendering algorithm sometimes produces these unwanted white
%   spots just, well, because of ray tracing. copy from isetAuto. Now
%   the ieOjbect is a scene, will add lens case --zhenyi0919 
%
% Zhenyi Liu, 2019
%
% See also
%  piAcquisition2IP

% TODO
%  The algorithm is incomplete and should be updated.  ZL has some network
%  he thinks might be better.
%

%% Here is an image that has a bunch

varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('ieObject',@isstruct);
p.addParameter('showflies',false,@islogical);
p.parse(ieObject,varargin{:});

oi = ieObject;

%% Have a look.  I think you can see a bunch of white pixels
illuminance = oiGet(oi,'illuminance');
illuminance = ieScale(illuminance,0,1);
logIlluminance = log10(illuminance);

% ieNewGraphWin;
% imagesc(logIlluminance);
% colorbar;

% Compute the local derivative, comparing each point to its neighbors
g = -1*ones(3,3)/8;
g(2,2) = 1;
% % g = -1*ones(1,3)/2;
% % g(1,2) = 1;
% g = -1*ones(3,1)/2;
% g(2,1) = 1;
% sum(g(:))
dLogIlluminance = conv2(logIlluminance,g,'same');

%% Replace the Inf points with the average of their neighbors


%{
 ieNewGraphWin;
 imagesc(dLogIlluminance);
 colorbar;
 hist(dLogIlluminance(:),100);
%}

%% Find points  more than XX larger than the average of their neighbors 
brightSpots = (dLogIlluminance > log10(3.5));
[r,c] = find(brightSpots);

if p.Results.showflies
    ieNewGraphWin;
    imagesc(brightSpots);
end

g = ones(3,3)/9;
isolatedBrightSpots = conv2(brightSpots,g);
sum(isolatedBrightSpots(:));

% Sometimes we have white points within the local neighborhood, which
% limits the effectiveness
multipleSpots = (isolatedBrightSpots > 1);
% Good when this is zero
sum(multipleSpots(:));
%% Calculate the illuminance around the bright spots

% g = ones(3,3)/8;
% g(2,2) = 0;
g= ones(5,5)/24;
g(3,3) = 0;
g(3,4) = 0;
g(3,2) = 0;
g(2,3) = 0;
g(4,3) = 0;

photons = oiGet(oi,'photons');
localSurround = zeros(size(photons));
nWave = oiGet(oi,'nwave');
for ii=1:nWave
    localSurround(:,:,ii) = conv2(photons(:,:,ii),g,'same');
end

%%
correctedPhotons = photons;
for ii = 1:length(r)
    correctedPhotons(r(ii),c(ii),:) = localSurround(r(ii),c(ii),:);
end

%% It seems like the photons have the wrong spectrum

% They are white, and thus not matched in color to the surrounding pixels
% We need to replace the full spectrum of the white points with the average
% spectrum of the surrounding points, not just scale the white pixels
oi = oiSet(oi,'photons',correctedPhotons);

end