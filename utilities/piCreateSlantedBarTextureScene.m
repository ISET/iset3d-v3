function recipe = piCreateSlantedBarTextureScene(varargin)
%CREATESIMPLEPOINT 
% Create a recipe for a slanted bar texture scene. 
%
%   recipe = piCreateSlantedBarTextureScene(varargin)
%
% Required:
%   None
%
% Optional key/value parameters
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

% Depth in meters
parser.addParameter('topDepth', 2, @isnumeric);
parser.addParameter('bottomDepth',1, @isnumeric);
parser.addParameter('nchecks',1024,@isscalar);
parser.addParameter('illumination', 'EqualEnergy.spd', @ischar);

parser.parse(varargin{:});
topDepth    = parser.Results.topDepth;
bottomDepth   = parser.Results.bottomDepth;
illumination = parser.Results.illumination;
nchecks     = parser.Results.nchecks;

%% Read in base scene
scenePath = fullfile(piRootPath,'data','V3','slantedBarTexture');
sceneName = 'slantedBarTexture.pbrt';

recipe = piRead(fullfile(scenePath,sceneName),'version',3);

%% Add Checkerboard texture
recipe = piMaterialTextureAdd(recipe,'TopPlane','checkerboard','uscale',nchecks,'vscale',nchecks);
recipe = piMaterialTextureAdd(recipe,'BottomPlane','checkerboard','uscale',nchecks,'vscale',nchecks);

%% Make adjustments to the plane

for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name,'TopPlane')
        recipe.assets(ii).position = [recipe.assets(ii).position(1);recipe.assets(ii).position(2); topDepth];
    end
    if strcmp(recipe.assets(ii).name,'BottomPlane')
        recipe.assets(ii).position = [recipe.assets(ii).position(1);recipe.assets(ii).position(2); bottomDepth];
    end
end

%% Make the plane that's further back slightly larger
% Prevents tiny gaps between the two planes

% If they are equal in distance, we don't do anything.
if(topDepth > bottomDepth)
    lookFor = 'TopPlane';
elseif(bottomDepth > topDepth)
    lookFor = 'BottomPlane';
end

for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name,lookFor)
        % Increase size by 10 cm.
        recipe.assets(ii).size.l = recipe.assets(ii).size.l + 0.01; 
        recipe.assets(ii).size.h = recipe.assets(ii).size.h + 0.01;
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

