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
parser.addParameter('spectrum',[]) % Can be a vector a string
parser.addParameter('radius',1, @isnumeric);

parser.parse(varargin{:});
location = parser.Results.location;
rgb = parser.Results.rgb;
radius = parser.Results.radius;
spect = parser.Results.spectrum;

%% Decide whether to use spectrum or rgb
if(isempty(spect))
    colorLine = sprintf('"rgb Kd" [%f %f %f]',rgb(1),rgb(2),rgb(3));
else
    if(isstring(spect))
        warning(['Using %s file for spectrum. Remember to copy this ' ... 
            'file in your working folder!'],spect)
        colorLine = sprintf('"spectrum Kd" [%s]',spect);
    elseif(isvector(spect))
        colorLine = sprintf('"spectrum Kd" [%s]',num2str(spect));
    else
        error('Unknown spectrum input for piAddSphere.')
    end
end

%% Create the text lines for the sphere
targetScript(1) = {'AttributeBegin'};
targetScript(2) = {sprintf('  Translate %f %f %f',location)};
targetScript(3) = {sprintf('  Shape "sphere" "float radius" [%f] %s',...
    radius,colorLine)};
targetScript(4) = {'AttributeEnd'};

%% Insert these lines into the world block of the recipe

worldWSphere = [recipe.world(1);
    targetScript';
    recipe.world(2:end)];
recipe.world = worldWSphere;
    
end

