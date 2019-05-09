function thisR = piLightAdd(thisR, varargin)
%% Add different type of light sources to a scene
% 
% Inputs:
%       thisR: render recipe
%       types:
%             Point: Casts the same amount of illumination in all directions.
%             Spot: Specify a cone of directions in which light is emitted.
%             distant: It represents a directional light source "at infinity".
%       other related parameters for each type of light source
% Outputs:
%        
% Required: ISETCam
% See also: piSkymapAdd(Add HDR lighting for global illumination)
% Zhenyi, SCIEN, 2019
% Example:
%{
lightSources = piLightGet(thisR);
thisR = piLightDelete(thisR, lightSources, 2);
thisR = piLightAdd(thisR, 'type', 'point');
thisR = piLightAdd(thisR, 'type', 'point', 'camera coordinate', true);

%}
%%
varargin = ieParamFormat(varargin);  % Allow spaces and capitalization

p = inputParser;
p.addRequired('recipe', @(x)(isa(x,'recipe')));
p.addParameter('type', 'point', @ischar);
% Load in a light source saved in ISETCam/data/lights
p.addParameter('lightspectrum', 'D65');
p.addParameter('pointfrom', [0 0 0]);
% used for spot light
p.addParameter('pointto', [0 0 1]);
% The angle that the spotlight's cone makes with its primary axis. 
% For directions up to this angle from the main axis, the full radiant 
% intensity given by "I" is emitted. After this angle and up to 
% "coneangle" + "conedeltaangle", illumination falls off until it is zero.
p.addParameter('coneangle', 30, @isnumeric); % It's 30 by default
% The angle at which the spotlight intensity begins to fall off at the edges.
p.addParameter('conedeltaangle', 5, @isnumeric); % It's 5 by default
% place a lightsource at the camera's position
p.addParameter('cameracoordinate',false);
p.parse(thisR, varargin{:});

type = p.Results.type;
lightSpectrum = p.Results.lightspectrum;
pointFrom = p.Results.pointfrom;
pointTo = p.Results.pointto;
coneAngle = p.Results.coneangle;
conDeltaAngle = p.Results.conedeltaangle;

%% Write out lightspectrum into a light.spd file
[~,sceneName] = fileparts(thisR.inputFile);
try
    thisLight = load(lightSpectrum);
catch
    error('%s light is not recognized \n', lightSpectrum);
end

lightSpdDir = fullfile(piRootPath, 'local', sceneName, 'spds', 'lights');
thisLightfile = fullfile(lightSpdDir,...
                sprintf('%s.spd', lightSpectrum));
if ~exist(lightSpdDir, 'dir'), mkdir(lightSpdDir); end
fid = fopen(thisLightfile, 'w');
for ii = 1: length(thisLight.data)
    fprintf(fid, '%d %d \n', thisLight.wavelength(ii), thisLight.data(ii));
end
fclose(fid);
%% Read light source struct from world struct
lightSources = piLightGet(thisR, 'print', false);
%% Construct a lightsource structure
numLights = length(Lightsource);
Lightsource{numLights+1}.line{1} = 'AttributeBegin';
switch type
    case 'point'
        if p.Results.cameracoordinate
            Lightsource{numLights+1}.line{2,:} = 'CoordSysTransform "camera"';
            Lightsource{numLights+1}.line{3,:} = sprintf('LightSource "point" "spectrum I" "spds/lights/%s.spd"', lightSpectrum);
        else
            Lightsource{numLights+1}.line{2,:} = sprintf('LightSource "point" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d]',...
                lightSpectrum, pointFrom);
        end    
    case 'spot'
        Lightsource{numLights+1}.line{2,:} = sprintf('LightSource "point" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d]',...
                lightSpectrum, pointFrom, pointTo);
        thisConeAngle = sprintf('float coneangle [%d]', coneAngle);
        thisConeDelta = sprintf('float conedelataangle [%d]', conDeltaAngle);
        Lightsource{numLights+1}.line{2,:} = [Lightsource{end+1}.line{2}, thisConeAngle, thisConeDelta];
    case 'distant'
        Lightsource{numLights+1}.line{2,:} = sprintf('LightSource "point" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d]',...
                lightSpectrum, pointFrom, pointTo);        
end
Lightsource{numLights+1}.line{end+1} = 'AttributeEnd';

%%
index_m = piContains(thisR.world,'_materials.pbrt');
index_g = piContains(thisR.world,'_geometry.pbrt');
world{1} = 'WorldBegin';
for jj = 1: numLights+1
    numWorld = length(world);
    for kk = 1: length(Lightsource{jj}.line)
        world{numWorld+kk,:} = Lightsource{jj}.line{kk};
    end
end
numWorld = length(world);
world{numWorld+1,:} = thisR.world{index_m};
world{numWorld+2,:} = thisR.world{index_g};
world{end+1,:} = 'WorldEnd';
thisR.world = world;
end


