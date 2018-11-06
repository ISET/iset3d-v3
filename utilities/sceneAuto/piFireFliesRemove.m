%% Find and remove fireflies(ray-tracing artifacts) in the image
% 
% The rendering algorithm sometimes produces these unwanted white spots
% just, well, because of ray tracing.
% copy from isetAuto
function oi = piFireFliesRemove(ieObject)
% now the ieOjbect is a scene, will add lens case --zhenyi0919

%% Here is an image that has a bunch

% ieAddObject(ieObject); sceneWindow;
% oi = oiCreate('diffraction limited');
% oi = oiCompute(ieObject,oi);
% ieAddObject(oi); oiWindow;
oi = ieObject;

%% Have a look.  I think you can see a bunch of white pixels
illuminance = oiGet(oi,'illuminance');
illuminance = ieScale(illuminance,0,1);
logIlluminance = log10(illuminance);
% vcNewGraphWin;
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


% vcNewGraphWin;
% imagesc(dLogIlluminance);
% colorbar;
% hist(dLogIlluminance(:),100);


%% Find points  more than XX larger than the average of their neighbors 
brightSpots = (dLogIlluminance > log10(3.5));
[r,c] = find(brightSpots);

vcNewGraphWin;
imagesc(brightSpots);

g = ones(3,3)/9;
isolatedBrightSpots = conv2(brightSpots,g);
sum(isolatedBrightSpots(:))

% Sometimes we have white points within the local neighborhood, which
% limits the effectiveness
multipleSpots = (isolatedBrightSpots > 1);
% Good when this is zero
sum(multipleSpots(:))
%% Calculate the illuminance around the bright spots

% g = ones(3,3)/8;
% g(2,2) = 0;
g= ones(5,5)/24;
g(3,3) = 0;
g(3,4)=0;
g(3,2)=0;
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