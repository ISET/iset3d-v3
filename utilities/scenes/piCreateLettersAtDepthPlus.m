function recipe = piCreateLettersAtDepthPlus(varargin)
%CREATELETTERSATDEPTHPLUS 
% Create a recipe for a scene that consists of three letters (A,B,C,D,E)
% placed at different distances away from the camera. The backdrop consists
% of a checkerboard wall and ground. The letters can be placed at arbitrary
% degrees away from the optical axis.

% OPTIONAL input parameter/val
%   Xdist - distance from the camera to the letter X in meters
%   Xdeg  - degrees away from the optical axis for letter X
%   illumination - illumination of the scene (infinite light) as as SPD
%                filename.

% RETURN
%   recipe - recipe for this created scene

%% Parse inputs
parser = inputParser();

parser.addParameter('Adist',0.1, @isnumeric);
parser.addParameter('Bdist',0.15, @isnumeric);
parser.addParameter('Cdist',0.2, @isnumeric);
parser.addParameter('Ddist',0.25, @isnumeric);
parser.addParameter('Edist',0.3, @isnumeric);

parser.addParameter('Adeg',3, @isnumeric);
parser.addParameter('Bdeg',1.5, @isnumeric);
parser.addParameter('Ddeg',1.5, @isnumeric);
parser.addParameter('Edeg',3, @isnumeric);

parser.addParameter('nchecks',[64 64],@isnumeric); %[wall ground]
parser.addParameter('illumination', 'EqualEnergy.spd', @ischar);

parser.parse(varargin{:});

Adist = parser.Results.Adist;
Bdist = parser.Results.Bdist;
Cdist = parser.Results.Cdist;
Ddist = parser.Results.Ddist;
Edist = parser.Results.Edist;

Adeg = parser.Results.Adeg;
Bdeg = parser.Results.Bdeg;
Ddeg = parser.Results.Ddeg;
Edeg = parser.Results.Edeg;

nchecks = parser.Results.nchecks;
illumination = parser.Results.illumination;

%% Read in base scene
scenePath = fullfile(piRootPath,'local','scenes','lettersAtDepthPlus');
sceneName = 'lettersAtDepthPlus.pbrt';

recipe = piRead(fullfile(scenePath,sceneName),'version',3);

%% Change checkerboard pattern

if(length(nchecks) == 1)
    nchecks(2) = nchecks(1);
end

recipe = piMaterialTextureAdd(recipe,'WallMaterial',...
    'checkerboard',...
    'uscale',nchecks(1),...
    'vscale',nchecks(1),...
    'color1',[0.3 0.3 0.3]);

recipe = piMaterialTextureAdd(recipe,'GroundMaterial',...
    'checkerboard',...
    'uscale',nchecks(2),...
    'vscale',nchecks(2),...
    'color1',[0.3 0.3 0.3]);
                            
%% Calculate x-locations of the letters, given their depth

% "A" will be X degrees to the left
Ax = -1*tand(Adeg)*Adist ;

% "B" will be X degrees to the left
Bx = -1*tand(Bdeg)*Bdist ;

% "C" will always be in the center
Cx = 0;

% "D" will be X degrees to the right
Dx = tand(Ddeg)*Ddist ;

% "E" will be X degrees to the right
Ex = tand(Edeg)*Edist ;

%% Make adjustments to the letters

for ii = 1:length(recipe.assets)
    
    if strcmp(recipe.assets(ii).name,'A')
        recipe.assets(ii).position(1) = Ax;
        recipe.assets(ii).position(3) = Adist;
        recipe.assets(ii).scale = recipe.assets(ii).scale.*0.8;
    end
    
    if strcmp(recipe.assets(ii).name,'B')
        recipe.assets(ii).position(1) = Bx;
        recipe.assets(ii).position(3) = Bdist;
        recipe.assets(ii).scale = recipe.assets(ii).scale.*0.8;
    end
    
    if strcmp(recipe.assets(ii).name,'C')
        recipe.assets(ii).position(1) = Cx;
        recipe.assets(ii).position(3) = Cdist;
        recipe.assets(ii).scale = recipe.assets(ii).scale.*0.8;
    end
    
    if strcmp(recipe.assets(ii).name,'D')
        recipe.assets(ii).position(1) = Dx;
        recipe.assets(ii).position(3) = Ddist;
        recipe.assets(ii).scale = recipe.assets(ii).scale.*0.8;
    end
   
    if strcmp(recipe.assets(ii).name,'E')
        recipe.assets(ii).position(1) = Ex;
        recipe.assets(ii).position(3) = Edist;
        recipe.assets(ii).scale = recipe.assets(ii).scale.*0.8;
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

