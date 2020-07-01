function recipe = piCreateSlantedBarScene(varargin)
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

%% Parse inputs
parser = inputParser();
parser.addParameter('planeDepth',1, @isnumeric);
parser.addParameter('eccentricity',0, @isnumeric);
parser.addParameter('illumination', 'EqualEnergy.spd', @ischar);
parser.addParameter('whiteDepth',0, @isnumeric);
parser.addParameter('blackDepth',0, @isnumeric);

parser.parse(varargin{:});
planeDepth = parser.Results.planeDepth;
eccentricity = parser.Results.eccentricity;
illumination = parser.Results.illumination;

%% Read in base scene
scenePath = fullfile(piRootPath,'data','V3','slantedBar');
sceneName = 'slantedBar.pbrt';
recipe = piRead(fullfile(scenePath,sceneName));

%% Make adjustments to the plane

% Calculate x position given eccentricity
% Note: Where should this position be calculated from?
x = tand(eccentricity)*planeDepth;

for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name,'BlackPlane')
        recipe.assets(ii).position = ...
            [recipe.assets(ii).position(1)+x;...
            recipe.assets(ii).position(2);...
            planeDepth];
    end
    if strcmp(recipe.assets(ii).name,'WhitePlane')
        recipe.assets(ii).position = ...
            [recipe.assets(ii).position(1)+x;...
            recipe.assets(ii).position(2);...
            planeDepth];
    end
end

%% Make adjustments to the light

% Check illumination file
[~,n,e] = fileparts(illumination);
illumName = [n e];

if(~exist(fullfile(scenePath,illumName),'file'))
    Warning(['%s SPD file does not exist in the scene folder. You will'...
        'need to copy it manually into your working folder!'],illumName)
end
recipe = piWorldFindAndReplace(recipe,'EqualEnergy.spd',illumName);


end

