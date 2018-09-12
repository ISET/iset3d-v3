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
parser.addParameter('backDepth', 2, @isnumeric);
parser.addParameter('frontDepth',1, @isnumeric);
parser.addParameter('illumination', 'EqualEnergy.spd', @ischar);

parser.parse(varargin{:});
backDepth    = parser.Results.backDepth;
frontDepth   = parser.Results.frontDepth;
illumination = parser.Results.illumination;

%% Read in base scene
scenePath = fullfile(piRootPath,'data','V3','slantedBarTexture');

% Check plane order
sceneName = 'slantedBarTexture.pbrt';

recipe = piRead(fullfile(scenePath,sceneName),'version',3);
%% Make adjustments to the point

% Clear previous transforms
% piClearObjectTransforms(recipe,'WhitePlane');
% piClearObjectTransforms(recipe,'BlackPlane');

% Add given transforms
recipe = piObjectTransform(recipe, 'FrontPlane', ...
    'Translate', [0 0 frontDepth]);
recipe = piObjectTransform(recipe, 'BackPlane', ...
    'Translate', [0 0 backDepth]);

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

