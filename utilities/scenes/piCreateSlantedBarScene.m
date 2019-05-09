function recipe = piCreateSlantedBarScene(varargin)
% Create a recipe for a slanted bar scene.
%
% Syntax:
%   recipe = piCreateSlantedBarScene([varargin])
%
% Description:
%    Create a recipe for a slanted bar scene.
%
% Inputs:
%    None.
%
% Outputs:
%    recipe       - Object. The created recipe object.
%
% Optional key/value pairs:
%    blackDepth   - Numeric. The distance from the camera to the black side
%                   of the slanted bar (in meters). Default is 0.
%    whiteDepth   - Numeric. The distance from the camera to the white side
%                   of the slanted bar (in meters). Default is 0.
%    illumination - String. The illumination of the scene (infinite light)
%                   as as SPD filename. Default is 'EqualEnergy.spd'.
%    planeDepth   - Numeric. The distance from camera to both black and
%                   white sides. If set, this will override the
%                   blackDepth/whiteDepth parameters (in meters). Default
%                   is 1.
%    eccentricity - Numeric. The eccentricity. Default is 0.
%

% History:
%    XX/XX/XX  XXX  Created
%    04/02/19  JNM  Documentation pass

%% Parse inputs
parser = inputParser();
parser.addParameter('planeDepth', 1, @isnumeric);
parser.addParameter('eccentricity', 0, @isnumeric);
parser.addParameter('illumination', 'EqualEnergy.spd', @ischar);
parser.addParameter('whiteDepth', 0, @isnumeric);
parser.addParameter('blackDepth', 0, @isnumeric);

parser.parse(varargin{:});
planeDepth = parser.Results.planeDepth;
eccentricity = parser.Results.eccentricity;
illumination = parser.Results.illumination;

%% Read in base scene
scenePath = fullfile(piRootPath, 'data', 'V3', 'slantedBar');
sceneName = 'slantedBar.pbrt';
recipe = piRead(fullfile(scenePath, sceneName), 'version', 3);

%% Make adjustments to the plane
% Calculate x position given eccentricity
% [Note: XXX - Where should this position be calculated from?]
x = tand(eccentricity)*planeDepth;

for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name, 'BlackPlane')
        recipe.assets(ii).position = ...
            [recipe.assets(ii).position(1) + x; ...
            recipe.assets(ii).position(2); planeDepth];
    end
    if strcmp(recipe.assets(ii).name, 'WhitePlane')
        recipe.assets(ii).position = ...
            [recipe.assets(ii).position(1) + x; ...
            recipe.assets(ii).position(2); planeDepth];
    end
end

%% Make adjustments to the light
% Check illumination file
[~, n, e] = fileparts(illumination);
illumName = [n e];

if ~exist(fullfile(scenePath, illumName), 'file')
    Warning(['%s SPD file does not exist in the scene folder. You will'...
        'need to copy it manually into your working folder!'], illumName)
end
recipe = piWorldFindAndReplace(recipe, 'EqualEnergy.spd', illumName);

end
