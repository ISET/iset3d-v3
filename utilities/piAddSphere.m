function recipe = piAddSphere(recipe,varargin)
%piAddSphere 
% Add a simple sphere object into the world block of a recipe. 

% OPTIONAL input parameter/val
%   location - coordinate location of the sphere [x y z]
%   rgb - color of sphere, as an rgb value (TODO: Allow spectrum as well.)
%   radius - radius of the sphere

% RETURN
%   recipe - recipe with updated world block

%% Parse inputs
parser = inputParser();
parser.addParameter('location',[0 0 0], @isvector);
parser.addParameter('rgb', [1 0 0], @isvector);
parser.addParameter('radius',1, @isnumeric);

parser.parse(varargin{:});
location = parser.Results.location;
rgb = parser.Results.rgb;
radius = parser.Results.radius;

%% Create the text lines for the sphere
targetScript(1) = {'AttributeBegin'};
targetScript(2) = {sprintf('  Translate %f %f %f',location)};
targetScript(3) = {sprintf('  Shape "sphere" "float radius" [%f] "rgb Kd" [%f %f %f]',...
    radius,rgb(1),rgb(2),rgb(3))};
targetScript(4) = {'AttributeEnd'};

%% Insert these lines into the world block of the recipe

worldWSphere = [recipe.world(1);
    targetScript';
    recipe.world(2:end)];
recipe.world = worldWSphere;
    
end

