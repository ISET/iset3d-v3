%% s_snellen.m
%
%
% TL ISETBIO Team, 2017
    

%% Initialize ISETBIO
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Scene setup 
snellenDistanceDpt = 1.2;
snellenFOV = 10;
width = 2*tand(snellenFOV/2)*(1/snellenDistanceDpt);
snellenSize = [width width];

scenePinhole = sceneEye('snellenSingle',...
    'objectDistance',1/snellenDistanceDpt,...
    'objectSize',[snellenSize snellenSize]);

myScene.pupilDiameter = 4;

myScene.fov = 20;
myScene.numRays = 256;
myScene.resolution = 256;

%% Step through accommodation

accomm = [1.2]; % in diopters

opticalImages = cell(length(accomm),1);
for ii = 1:length(accomm)
    
    myScene.accommodation = accomm(ii);
    myScene.name = sprintf('accom_%0.2fdpt',myScene.accommodation);
    
    oi = myScene.render;
    ieAddObject(oi);
    opticalImages{ii} = oi;
end

oiWindow;




