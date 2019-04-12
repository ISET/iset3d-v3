function recipe = piAddSphere(recipe, varargin)
% Add a simple sphere object into the world block of a recipe.
%
% Syntax:
%   recipe = piAddSphere(recipe, [varargin])
%
% Description:
%    Add a simple sphere object into the world block of a recipe.
%
% Inputs:
%    recipe   - Object. A recipe object.
%
% Outputs:
%    recipe   - Object. The modified recipe object.
%
% Optional key/value pairs:
%    location - Matrix. A 1x3 Matrix containing the coordinate location of
%               the sphere [x y z]. Default [0 0 0]
%    rgb      - Matrix. A 1x3 Matrix containing the RGB color values to
%               represent the color of the sphere. Default [1 0 0].
%    spectrum - Vector. A character or numeric vector. Represents either
%               the spectrum file or spectrum values. Default [].
%    radius   - Numeric. The radius of the sphere. Default 1.
%
% Notes:
%    * TODO: Implement Spectrum support for rgb key/value pair.
%

%% Parse inputs
parser = inputParser();
parser.addParameter('location', [0 0 0], @isvector);
parser.addParameter('rgb', [1 0 0], @isvector);
parser.addParameter('spectrum', []) % Can be a vector a string
parser.addParameter('radius', 1, @isnumeric);

parser.parse(varargin{:});
location = parser.Results.location;
rgb = parser.Results.rgb;
radius = parser.Results.radius;
spect = parser.Results.spectrum;

%% Decide whether to use spectrum or rgb
if isempty(spect)
    colorLine = sprintf('"rgb Kd" [%f %f %f]', rgb(1), rgb(2), rgb(3));
else
    if isstring(spect)
        warning(['Using %s file for spectrum. Remember to copy this ' ...
            'file in your working folder!'], spect)
        colorLine = sprintf('"spectrum Kd" [%s]', spect);
    elseif isvector(spect)
        colorLine = sprintf('"spectrum Kd" [%s]', num2str(spect));
    else
        error('Unknown spectrum input for piAddSphere.')
    end
end

%% Create the text lines for the sphere
targetScript(1) = {'AttributeBegin'};
targetScript(2) = {sprintf('  Translate %f %f %f', location)};
targetScript(3) = {sprintf('  Shape "sphere" "float radius" [%f] %s', ...
    radius, colorLine)};
targetScript(4) = {'AttributeEnd'};

%% Insert these lines into the world block of the recipe
worldWSphere = [recipe.world(1);
    targetScript';
    recipe.world(2:end)];
recipe.world = worldWSphere;

end
