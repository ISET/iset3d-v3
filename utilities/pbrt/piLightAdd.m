function thisR = piLightAdd(thisR, varargin)
% Add different types of light sources to a scene
%
% Syntax
%
% Brief description
%
%
% Inputs:
%       'thisR' -  Insert a light source in this recipe.
%
% Optional key/value pairs
%
%       'type'  - The type of light source to insert. Can be the following:
%             'point'   - Casts the same amount of illumination in all
%                         directions. Takes parameters 'to' and 'from'.
%             'spot'    - Specify a cone of directions in which light is
%                         emitted. Takes parameters 'to','from',
%                         'coneangle', and 'conedeltaangle.'
%             'distant' - A directional light source "at
%                         infinity". Takes parameters 'to' and 'from'.
%             'area'    - convert an object into an area light. (TL: Needs
%                         more documentation; I'm not sure how it's used at
%                         the moment.)
%             'infinite' - an infinitely far away light source that
%                          potentially casts illumination from all
%                          directions. Takes no parameters.
%
%       'light spectrum' - The spectrum that the light will emit. Read
%                          from ISETCam/ISETBio light data. See
%                          "isetbio/isettools/data/lights" or
%                          "isetcam/data/lights."
%       'spectrumscale'  - scale the spectrum. Important for setting
%                          relative weights for multiple light sources.
%       'cameracoordinate' - true or false. automatically place the light
%                            at the camera location.
%       'update'         - update an existing light source.
%
%       For more information in the different light sources and their
%       parameters, take a look at the PBRT web page:
%
%       https://www.pbrt.org/fileformat-v3.html#lights
%
%       Not al the lights and parameters can be represented in ISET3d at
%       the moment, but our hope is that they will be in the future.
%
% Outputs:
%
% Zhenyi, TL, SCIEN, 2019
%
% Required: ISETCam
%
% See also:
%   piSkymapAdd, piLight*
%

% Examples:
%{
  % Need to get a recipe in here!
  thisR = piRecipeDefault;
  lightSources = piLightGet(thisR);
  thisR = piLightDelete(thisR, 2);
  thisR = piLightAdd(thisR, 'type', 'point');
  thisR = piLightAdd(thisR, 'type', 'point', 'camera coordinate', true);
%}

%% Parse inputs

varargin = ieParamFormat(varargin);  % Allow spaces and capitalization

p = inputParser;
p.addRequired('recipe', @(x)(isa(x,'recipe')));
p.addParameter('type', 'point', @ischar);
% Load in a light source saved in ISETCam/data/lights
p.addParameter('lightspectrum', 'D65');
% used for point/spot/distant/laser light
p.addParameter('from', [0 0 0]);
% used for spot light
p.addParameter('to', [0 0 1]);

% The angle that the spotlight's cone makes with its primary axis.
% For directions up to this angle from the main axis, the full radiant
% intensity given by "I" is emitted. After this angle and up to
% "coneangle" + "conedeltaangle", illumination falls off until it is zero.
p.addParameter('coneangle', 30, @isnumeric); % It's 30 by default
% The angle at which the spotlight intensity begins to fall off at the edges.
p.addParameter('conedeltaangle', 5, @isnumeric); % It's 5 by default
% place a lightsource at the camera's position
p.addParameter('cameracoordinate',false);
% scale the spectrum
p.addParameter('spectrumscale', 1);
% update an exist light
p.addParameter('update',0);
p.parse(thisR, varargin{:});

type = p.Results.type;
lightSpectrum = p.Results.lightspectrum;
spectrumScale = p.Results.spectrumscale;
from = p.Results.from;
to = p.Results.to;
coneAngle = p.Results.coneangle;
conDeltaAngle = p.Results.conedeltaangle;
idxL      = p.Results.update;

%% check whether a light needs to be replaced
if idxL
    lightsource = piLightGet(thisR, 'print', false);
    type = lightsource{idxL}.type;
    
    if find(piContains(varargin, 'lightspectrum')), lightSpectrum = p.Results.lightspectrum;
    else, [~,lightSpectrum] = fileparts(lightsource{idxL}.spectrum); end
    
    if find(piContains(varargin, 'from')), from = p.Results.from;
    else, from = lightsource{idxL}.position; end
    
    if find(piContains(varargin, 'to')), to = p.Results.to;
    else, to = lightsource{idxL}.direction; end
    
    if find(piContains(varargin, 'coneAngle')), coneAngle = p.Results.coneangle;
    else, coneAngle = lightsource{idxL}.coneangle; end
    
    if find(piContains(varargin, 'coneDeltaAngle')), conDeltaAngle = p.Results.conedeltaangle;
    else, conDeltaAngle = lightsource{idxL}.conedeltaangle; end
    piLightDelete(thisR, idxL);
end

%% Write out lightspectrum into a light.spd file

if ischar(lightSpectrum)
    try
        % Load from ISETCam/ISETBio ligt data
        thisLight = load(lightSpectrum);
    catch
        error('%s light is not recognized \n', lightSpectrum);
    end
    outputDir = fileparts(thisR.outputFile);
    lightSpdDir = fullfile(outputDir, 'spds', 'lights');
    thisLightfile = fullfile(lightSpdDir,...
        sprintf('%s.spd', lightSpectrum));
    if ~exist(lightSpdDir, 'dir'), mkdir(lightSpdDir); end
    fid = fopen(thisLightfile, 'w');
    for ii = 1: length(thisLight.data)
        fprintf(fid, '%d %d \n', thisLight.wavelength(ii), thisLight.data(ii)*spectrumScale);
    end
    fclose(fid);
    % Zheng Lyu added 10-2019
    if ~isfile(fullfile(lightSpdDir,strcat(lightSpectrum, '.mat')))
        copyfile(which(strcat(lightSpectrum, '.mat')), lightSpdDir);
    end
else
    % to do
    % add customized lightspectrum array [400 1 600 1 800 1]
end

%% Read light source struct from world struct
% currentlightSources = piLightGet(thisR, 'print', false);

%% Construct a lightsource structure
% numLights = length(currentlightSources);

% Different types of lights that we know how to add.
switch type
    case 'point'
        lightSources{1}.type = 'point';
        if p.Results.cameracoordinate
            lightSources{1}.line{1} = 'AttributeBegin';
            lightSources{1}.line{2,:} = 'CoordSysTransform "camera"';
            lightSources{1}.line{3,:} = sprintf('LightSource "point" "spectrum I" "spds/lights/%s.spd"', lightSpectrum);
            lightSources{1}.line{end+1} = 'AttributeEnd';
        else
            lightSources{1}.line{1,:} = sprintf('LightSource "point" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d]',...
                lightSpectrum, from);
        end
    case 'spot'
        lightSources{1}.type = 'spot';
        thisConeAngle = sprintf('"float coneangle" [%d]', coneAngle);
        thisConeDelta = sprintf('"float conedeltaangle" [%d]', conDeltaAngle);
        
        if p.Results.cameracoordinate
            lightSources{1}.line{1} = 'AttributeBegin';
            lightSources{1}.line{2,:} = 'CoordSysTransform "camera"';
            lightSources{1}.line{3,:} = sprintf('LightSource "spot" "spectrum I" "spds/lights/%s.spd" %s %s',...
                lightSpectrum, thisConeAngle, thisConeDelta);
            lightSources{1}.line{end+1} = 'AttributeEnd';
        else
            lightSources{1}.line{1,:} = sprintf('LightSource "spot" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d] %s %s',...
                lightSpectrum, from, to, thisConeAngle, thisConeDelta);
        end
        
    case 'laser' % not supported for public
        lightSources{1}.type = 'laser';
        lightSources{1}.line{1,:} = sprintf('LightSource "laser" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d]',...
            lightSpectrum, from, to);
        thisConeAngle = sprintf('float coneangle [%d]', coneAngle);
        thisConeDelta = sprintf('float conedelataangle [%d]', conDeltaAngle);
        lightSources{1}.line{1,:} = [lightSources{end+1}.line{2}, thisConeAngle, thisConeDelta];
    case 'distant'
        lightSources{1}.type = 'distant';
        lightSources{1}.line{1,:} = sprintf('LightSource "distant" "spectrum L" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d]',...
            lightSpectrum, from, to);
    case 'infinite'
        lightSources{1}.type = 'infinite';
        lightSources{1}.line{1,:} = sprintf('LightSource "infinite" "spectrum L" "spds/lights/%s.spd"',lightSpectrum);
    case 'area'
        % find area light geometry info
        
        nlight = 1;
        for ii = 1:length(thisR.assets)
            if piContains(lower(thisR.assets(ii).name), 'area')
                lightSources{nlight}.type = 'area'; %#ok<*AGROW>
                lightSources{nlight}.line{1} = 'AttributeBegin';
                if idxL
                    % Why is there a +nLight?
                    lightSources{+nlight}.line{2,:} = sprintf('Translate %f %f %f',from(1),...
                        from(2), from(3));
                else
                    lightSources{nlight}.line{2,:} = sprintf('Translate %f %f %f',thisR.assets(ii).position(1),...
                        thisR.assets(ii).position(2), thisR.assets(ii).position(3));
                end
                lightSources{nlight}.line{3,:} = sprintf('Rotate %f %f %f %f',thisR.assets(ii).rotate(:,1));
                lightSources{nlight}.line{4,:} = sprintf('Rotate %f %f %f %f',thisR.assets(ii).rotate(:,2));
                lightSources{nlight}.line{5,:} = sprintf('Rotate %f %f %f %f',thisR.assets(ii).rotate(:,3));
                lightSources{nlight}.line{6,:} = sprintf('AreaLightSource "diffuse" "spectrum L" "spds/lights/%s.spd"', lightSpectrum);
                lightSources{nlight}.line{7,:} = sprintf('Include "%s"', thisR.assets(ii).children.output);
                lightSources{nlight}.line{end+1} = 'AttributeEnd';
                nlight = nlight+1;
                
            elseif piContains(lower(thisR.assets(ii).name), 'light')
                lightSources{nlight}.type = 'area';
                lightSources{nlight}.line{1} = 'AttributeBegin';
                if idxL
                    lightSources{+nlight}.line{2,:} = sprintf('Translate %f %f %f',from(1),...
                        from(2), from(3));
                else
                    lightSources{nlight}.line{2,:} = sprintf('Translate %f %f %f',thisR.assets(ii).position(1),...
                        thisR.assets(ii).position(2), thisR.assets(ii).position(3));
                end
                lightSources{nlight}.line{3,:} = sprintf('Rotate %f %f %f %f',thisR.assets(ii).rotate(:,1));
                lightSources{nlight}.line{4,:} = sprintf('Rotate %f %f %f %f',thisR.assets(ii).rotate(:,2));
                lightSources{nlight}.line{5,:} = sprintf('Rotate %f %f %f %f',thisR.assets(ii).rotate(:,3));
                lightSources{nlight}.line{6,:} = sprintf('AreaLightSource "diffuse" "spectrum L" "spds/lights/%s.spd"', lightSpectrum);
                lightSources{nlight}.line{7,:} = sprintf('Shape "sphere" "float radius" [.1]');
                lightSources{nlight}.line{end+1} = 'AttributeEnd';
                nlight = nlight+1;
            end
        end
end

%% Update the world data

index_m = piContains(thisR.world,'_materials.pbrt');
index_g = piContains(thisR.world,'_geometry.pbrt');
world = thisR.world(1:end-3);
for jj = 1: length(lightSources)
    numWorld = length(world);
    % infinity light can be added by piSkymap add.
    if ~piContains(lightSources{jj}.type, 'infinity')
        for kk = 1: length(lightSources{jj}.line)
            world{numWorld+kk,:} = lightSources{jj}.line{kk};
        end
    end
end

% What does this do?  Close up the World section?
numWorld = length(world);
world{numWorld+1,:} = thisR.world{index_m};
world{numWorld+2,:} = thisR.world{index_g};
world{end+1,:} = 'WorldEnd';
thisR.world = world;

%% Tell the user the status.  We might turn this off some day.

if idxL, fprintf('Existing lights updated.\n');
else,    fprintf('New light added.\n');
end

end


