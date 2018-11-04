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
parser.addParameter('blackDepth',1, @isnumeric);
parser.addParameter('whiteDepth',1, @isnumeric);
parser.addParameter('planeDepth',[], @isnumeric);
parser.addParameter('illumination', 'EqualEnergy.spd', @ischar);

parser.parse(varargin{:});
blackDepth = parser.Results.blackDepth;
whiteDepth = parser.Results.whiteDepth;
planeDepth = parser.Results.planeDepth;
illumination = parser.Results.illumination;

%% Read in base scene
scenePath = fullfile(piRootPath,'data','V3','slantedBar');
sceneName = 'slantedBar.pbrt';
recipe = piRead(fullfile(scenePath,sceneName),'version',3);

%% Make adjustments to the plane

if(~isempty(planeDepth))
    % If the user provides an overall plane depth, override the black and
    % white depths.
    whiteDepth = planeDepth;
    blackDepth = planeDepth;
end

for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name,'BlackPlane')
        recipe.assets(ii).position = [recipe.assets(ii).position(1);recipe.assets(ii).position(2); blackDepth];
    end
    if strcmp(recipe.assets(ii).name,'WhitePlane')
        recipe.assets(ii).position = [recipe.assets(ii).position(1);recipe.assets(ii).position(2); whiteDepth];
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

