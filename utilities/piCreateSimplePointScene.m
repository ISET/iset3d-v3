function recipe = piCreateSimplePointScene(varargin)
% Create a recipe for a simple point scene given some scene parameters.
%
% Syntax:
%   recipe = piCreateSimplePointScene([varargin])
%
% Description:
%    Create a recipe for a simple point scene given provided parameters.
%
% Inputs:
%    None.
%
% Outputs:
%    recipe        - Object. The created recipe object.
%
% Optional key/value pairs:
%    pointDiameter - Numeric. The diameter of the point (meters). Default
%                    is 0.01.
%    pointRGB      - Matrix. A 1x3 Matrix representing the color of the
%                    point. Default is [].
%    pointSpectrum - String. The spectrum of the point, as an SPD filename.
%                    If a spectrum is given, it will take precedence over
%                    the RGB value. Default is ''.
%    pointDistance - Numeric. The distance away from the origin along the
%                    positive z-axis in meters. Default is 1.
%    illumination  - String. The illumination of the scene (infinite light)
%                    as as SPD filename. Default is 'EqualEnergy.spd'.
%    pbrtVersion   - Numeric. The version number. Default is 3.
%

% History:
%    XX/XX/XX  XXX  Created
%    04/02/19  JNM  Documentation pass

%% Parse inputs
parser = inputParser();
parser.addParameter('pointDiameter', 0.01, @isnumeric);
parser.addParameter('pointRGB', [], @isvector);
parser.addParameter('pointSpectrum', '', @isstring);
parser.addParameter('pointDistance', 1, @isnumeric);
parser.addParameter('illumination', 'EqualEnergy.spd', @ischar);
parser.addParameter('pbrtVersion', 3, @isnumeric);

parser.parse(varargin{:});
pointRGB = parser.Results.pointRGB;
pointSpectrum = parser.Results.pointSpectrum;
illumination = parser.Results.illumination;
pbrtVersion = parser.Results.pbrtVersion;

% If version 2, the units are in millimeters. If version 3, units are in
% meters. We will scale the units appropriately.
if pbrtVersion == 2
    unitScale = 10 ^ 3;
elseif pbrtVersion == 3
    unitScale = 1;
else
    error('PBRT version not recognized.');
end

pointDiameter = parser.Results.pointDiameter * unitScale;
pointDistance = parser.Results.pointDistance * unitScale;

% Warn users of unimplemented features
if ~(isempty(pointRGB)) || ~isempty(pointSpectrum)
    warning(strcat('pointRGB and pointSpectrum are not implemented ', ...
        'yet. Point RGB set to [1 1 1] by default.'));
end

%% Read in base scene
if pbrtVersion == 3
    recipe = piRead(fullfile(piRootPath, 'data', 'SimplePoint', ...
        'simplePointV3.pbrt'), 'version', 3);
elseif pbrtVersion == 2
    recipe = piRead(fullfile(piRootPath, 'data', 'SimplePoint', ...
        'simplePoint.pbrt'), 'version', 2);
end

%% Make adjustments to the point
% Clear previous transforms
piClearObjectTransforms(recipe, 'Point');

% Add given transforms
piObjectTransform(recipe, 'Point', 'Scale', ...
    [pointDiameter pointDiameter 1]);
piObjectTransform(recipe, 'Point', 'Translate', [0 0 pointDistance]);

%% Make adjustments to the background plane
piClearObjectTransforms(recipe, 'Plane');

% Make it large!
piObjectTransform(recipe, 'Plane', 'Scale', ...
    [pointDistance * 10 pointDistance * 10 1]);

% Move it slightly beyond the point
piObjectTransform(recipe, 'Plane', 'Translate', ...
    [0 0 pointDistance + 0.5 * unitScale]);

%% Make adjustments to color
% TODO: Ask Zhenyi about this...

%% Make adjustments to the light
recipe = piWorldFindAndReplace(recipe, 'EqualEnergy.spd', illumination);

end
