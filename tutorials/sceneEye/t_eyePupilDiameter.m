%% t_eyePupilDiameter.m
%
% Deprecated
%
% Render the slanted bar scene at different pupil diameters. The rendered
% images can be used to calculate the MTF of the eye at a specific pupil
% size. 
%
% Depends on: iset3d, isetbio, Docker
%
% TL ISETBIO Team, 2017

%% Initialize ISETBIO
if piCamBio
    fprintf('%s: requires ISETBIO, not ISETCam\n',mfilename); 
    return;
end
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Initialize save folder
% Since rendering these images often takes a while, we will save out the
% optical images into a folder for later processing.
saveDirName = sprintf('pupil_%s',datestr(now,'mm-dd-yy_HH_MM'));
saveDir = fullfile(isetbioRootPath,'local',saveDirName);
if(~exist(saveDir,'dir'))
    mkdir(saveDir);
end

%% Load scene
planeDistance = 5; % 5 meters away
thisEye = sceneEye('slantedBar','planeDistance',planeDistance); 

%% Set fixed parameters
thisEye.accommodation = 1/planeDistance; % Accomodate to plane
thisEye.fov = 4;

thisEye.numCABands = 6;
thisEye.diffractionEnabled = true;

%% Loop through pupil diameters
pupilDiameters = [6 4 2];

% Fast test version
%{
numRays = [128 128 128];
myScene.resolution = 128; 
%}
% Fast test version
% {
numRays = [128 128 128]*4;
thisEye.resolution = 128*4; 
%}

if(length(numRays) ~= length(pupilDiameters))
    error('numRays and pupilDiameters length need to match!')
end

for ii = 1:length(pupilDiameters)
    
    currPupilDiam = pupilDiameters(ii);
    currNumRays = numRays(ii);
    
    thisEye.pupilDiameter = currPupilDiam;
    thisEye.numRays = currNumRays;
    
    thisEye.name = sprintf('pupilDiam_%0.2fmm',currPupilDiam);
    
    oi = thisEye.render;
    
    % Save the oi and the corresponding myScene object into the save
    % directory.
    saveFilename = fullfile(saveDir,[thisEye.name '.mat']);
    save(saveFilename,'oi','myScene');
    
    % Show the optical image
    oiWindow(oi);
    
end




