function thisR = piCreateSlantedBarScene(varargin)
%CREATESIMPLEPOINT 
% Create a recipe for a slanted bar scene. 

% OPTIONAL input parameter/val
%   blackDepth - distance from the camera to the black side of the slanted
%                bar (in meters)
%   whiteDepth - distance from the camera to the white side of the slanted
%                bar (in meters)
%   illumination - illumination of the scene (infinite light) as as SPD
%                filename.
%   planeDepth - distance from camera to both black and white sides. If
%                set, this will override the blackDepth/whiteDepth
%                parameters. (in meters)

% RETURN
%   recipe - recipe for this created scene

% Examples:
%{
  thisR = piCreateSlantedBarScene('planeDepth',0.5);
%}

%% Parse inputs
parser = inputParser();
parser.addParameter('planeDepth',1, @isnumeric);
parser.addParameter('eccentricity',0, @isnumeric);
parser.addParameter('illumination', 'EqualEnergy.spd', @ischar);
parser.addParameter('whiteDepth',0, @isnumeric);
parser.addParameter('blackDepth',0, @isnumeric);

parser.parse(varargin{:});

planeDepth   = parser.Results.planeDepth;
eccentricity = parser.Results.eccentricity;
illumination = parser.Results.illumination;

%% Read in base scene
scenePath = fullfile(piRootPath,'data','V3','slantedBar');
sceneName = 'slantedBar.pbrt';
thisR = piRead(fullfile(scenePath,sceneName));

%% Make adjustments to the plane

% Calculate x position given eccentricity
% Note: Where should this position be calculated from?
x = tand(eccentricity)*planeDepth;

%% Set the two planes to the specified distance

T = [x,0,planeDepth];

thisGroup= piAssetNames(thisR,'group find','WhitePlane');
thisR.assets(thisGroup(1)).groupobjs(thisGroup(2)).position(3) = T(3);

thisGroup= piAssetNames(thisR,'group find','BlackPlane');
thisR.assets(thisGroup(1)).groupobjs(thisGroup(2)).position(3) = T(3);

%{
[gnames,cnames] = piAssetNames(thisR);
gnames{thisGroup(1)}{thisGroup(2)}
%}

%% Make adjustments to the light

% Check illumination file
[~,n,e] = fileparts(illumination);
illumName = [n e];

if(~exist(fullfile(scenePath,illumName),'file'))
    Warning(['%s SPD file does not exist in the scene folder. You will'...
        'need to copy it manually into your working folder!'],illumName)
end

thisR = piWorldFindAndReplace(thisR,'EqualEnergy.spd',illumName);


end

