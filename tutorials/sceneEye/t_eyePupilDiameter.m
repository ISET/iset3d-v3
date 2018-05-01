%% t_eyePupilDiameter.m
%
% Render the slanted bar at different pupil diameters.
%
% Depends on: pbrt2ISET, ISETBIO, Docker, ISET
%
% TL ISETBIO Team, 2017

%% Initialize ISETBIO
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
planeDistance = 5; % 3 meter away
myScene = sceneEye('slantedBar','planeDistance',planeDistance); 

%% Set fixed parameters
myScene.accommodation = 1/planeDistance; % Accomodate to plane
myScene.fov = 4;

myScene.numCABands = 6;
myScene.diffractionEnabled = true;

%% Loop through pupil diameters
pupilDiameters = [6 5 4 3 2 1];

% HQ version
% numRays = [1024 1024 1024 2048 4096 4096]; 
% myScene.resolution = 512; 

% Fast test version
numRays = [128 128 128 128 128];
myScene.resolution = 128; 


if(length(numRays) ~= length(pupilDiameters))
    error('numRays and pupilDiameters length need to match!')
end

for ii = 1:length(pupilDiameters)
    
    currPupilDiam = pupilDiameters(ii);
    currNumRays = numRays(ii);
    
    myScene.pupilDiameter = currPupilDiam;
    myScene.numRays = currNumRays;
    
    myScene.name = sprintf('pupilDiam_%0.2fmm',currPupilDiam);
    
    oi = myScene.render;
    
    % Save the oi and the corresponding myScene object into the save
    % directory.
    saveFilename = fullfile(saveDir,[myScene.name '.mat']);
    save(saveFilename,'oi','myScene');
    
    % Show the optical image
    ieAddObject(oi);
    oiWindow;
    
end




