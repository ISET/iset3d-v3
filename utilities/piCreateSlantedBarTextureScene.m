function recipe = piCreateSlantedBarTextureScene(varargin)
%CREATESIMPLEPOINT 
% Create a recipe for a slanted bar texture scene. 

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
scenePath = fullfile(piRootPath,'data','V3','slantedBarAdjustableDepth');

% Check plane order
if(whiteDepth <= blackDepth)
    sceneName = 'slantedBarTexture.pbrt';
else
    sceneName = 'slantedBarTexture.pbrt';
end

recipe = piRead(fullfile(scenePath,sceneName),'version',3);
%% Make adjustments to the point

% Clear previous transforms
% piClearObjectTransforms(recipe,'WhitePlane');
% piClearObjectTransforms(recipe,'BlackPlane');

% Add given transforms
if(isempty(planeDepth))
    recipe = piObjectTransform(recipe, 'WhitePlane', ...
        'Translate', [0 0 whiteDepth]);
    recipe = piObjectTransform(recipe, 'BlackPlane', ...
        'Translate', [0 0 blackDepth]);
else
    recipe = piObjectTransform(recipe, 'WhitePlane', ...
        'Translate', [0 0 planeDepth]);
    recipe = piObjectTransform(recipe, 'BlackPlane', ...
        'Translate', [0 0 planeDepth]);
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

