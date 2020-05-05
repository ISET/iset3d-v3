function thisR = piLightAddToWorld(thisR, varargin)
% Add different types of light sources to world struct
%
% Syntax
%       thisR = piLightAddToWorld(thisR, varargin)
% Brief description
%   Write light into world struct. This is now a internal function.
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
%       'cameracameracoordinate' - true or false. automatically place the light
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
  thisR = piLightAdd(thisR, 'type', 'point', 'camera cameracoordinate', true);
%}

%% Parse inputs

varargin = ieParamFormat(varargin);  % Allow spaces and capitalization

p = inputParser;
p.addRequired('recipe', @(x)(isa(x,'recipe')));
p.addParameter('lightsource',[],@isstruct);

p.parse(thisR, varargin{:});
lightSource = p.Results.lightsource;

%% Check all applicable parameters
if isfield(lightSource, 'name'), name = lightSource.name;
else, name = 'Default light'; end

if isfield(lightSource, 'type'), type = lightSource.type;
else, type = 'point'; end

if isfield(lightSource, 'lightspectrum'), lightSpectrum = lightSource.lightspectrum;
else, lightSpectrum = 'D65'; end

if isfield(lightSource, 'from'), from = lightSource.from;
else, from = [0 0 0]; end

if isfield(lightSource, 'to'), to = lightSource.to;
else, to = [0 0 1]; end

if isfield(lightSource, 'coneangle'), coneAngle = lightSource.coneangle;
else, coneAngle = 30; end

if isfield(lightSource, 'conedeltaangle'), coneDeltaAngle = lightSource.conedeltaangle;
else, coneDeltaAngle = 5; end

if isfield(lightSource, 'spectrumscale'), spectrumScale = lightSource.spectrumscale;
else, spectrumScale = 1; end

%% Write out lightspectrum into a light.spd file

if ischar(lightSpectrum)
    try
        % ZLY: Wave is hardcoded in PBRT. In the future we might want to change
        % it so that we can use customized wave.
        wavelength = 365:5:705;
        data = ieReadSpectra(lightSpectrum, wavelength, 0);
    catch
        error('%s light is not recognized \n', lightSpectrum);
    end
    outputDir = fileparts(thisR.outputFile);
    lightSpdDir = fullfile(outputDir, 'spds', 'lights');
    thisLightfile = fullfile(lightSpdDir,...
        sprintf('%s.spd', lightSpectrum));
    if ~exist(lightSpdDir, 'dir'), mkdir(lightSpdDir); end
    fid = fopen(thisLightfile, 'w');
    for ii = 1: length(data)
        fprintf(fid, '%d %d \n', wavelength(ii), data(ii)*spectrumScale);
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
        if lightSource.cameracoordinate
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
        thisConeDelta = sprintf('"float conedeltaangle" [%d]', coneDeltaAngle);

        if lightSource.cameracoordinate
            lightSources{1}.line{1} = 'AttributeBegin';
            lightSources{1}.line{2,:} = 'CoordSysTransform "camera"';
            lightSources{1}.line{3,:} = sprintf('LightSource "spot" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d] %s %s',...
                lightSpectrum, from, to, thisConeAngle, thisConeDelta);
            lightSources{1}.line{end+1} = 'AttributeEnd';
        else
            lightSources{1}.line{1,:} = sprintf('LightSource "spot" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d] %s %s',...
                lightSpectrum, from, to, thisConeAngle, thisConeDelta);
        end

        % Set spectrum information
        lightSources{1}.spectrum = sprintf("spds/lights/%s.spd", lightSpectrum);

        %Set light position and direction
        lightSources{1}.position = from;
        lightSources{1}.direction = to;

        % Set coneAngle and coneDeltaAngle
        lightSources{1}.coneangle = coneAngle;
        lightSources{1}.conedeltaangle = coneDeltaAngle;



    case 'laser' % not supported for public
        lightSources{1}.type = 'laser';
        lightSources{1}.line{1,:} = sprintf('LightSource "laser" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d]',...
            lightSpectrum, from, to);
        thisConeAngle = sprintf('float coneangle [%d]', coneAngle);
        thisConeDelta = sprintf('float conedelataangle [%d]', coneDeltaAngle);
        lightSources{1}.line{1,:} = [lightSources{end+1}.line{2}, thisConeAngle, thisConeDelta];
    case 'distant'
        lightSources{1}.type = 'distant';
        if lightSource.cameracoordinate
            lightSources{1}.line{1} = 'AttributeBegin';
            lightSources{1}.line{2,:} = 'CoordSysTransform "camera"';
            lightSources{1}.line{3,:} = sprintf('LightSource "distant" "spectrum L" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d]',...
                lightSpectrum, from, to);
            lightSources{1}.line{end+1} = 'AttributeEnd';            
        else
            lightSources{1}.line{1,:} = sprintf('LightSource "distant" "spectrum L" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d]',...
                lightSpectrum, from, to);
        end

        % Set spectrum information
        lightSources{1}.spectrum = sprintf("spds/lights/%s.spd", lightSpectrum);

        %Set light position and direction
        lightSources{1}.position = from;
        lightSources{1}.direction = to;
    case 'infinite'
        lightSources{1}.type = 'infinite';
        lightSources{1}.line{1,:} = sprintf('LightSource "infinite" "spectrum L" "spds/lights/%s.spd"',lightSpectrum);

        % Set spectrum information
        lightSources{1}.spectrum = sprintf("spds/lights/%s.spd", lightSpectrum);
    case 'area'
        % find area light geometry info

        nlight = 1;
        for ii = 1:length(thisR.assets)
            % Set the name
            lightSources{nlight}.name = name;

            % Set the spectrumScale
            lightSources{nlight}.spectrumscale = spectrumScale;

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

                % Set spectrum information
                lightSources{nlight}.spectrum = sprintf("spds/lights/%s.spd", lightSpectrum);

                % Set spectrum area light
                lightSources{nlight}.area = thisR.assets(ii).children.output;

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

                % Set spectrum information
                lightSources{nlight}.spectrum = sprintf("spds/lights/%s.spd", lightSpectrum);

                % Set spectrum area light
                lightSources{nlight}.area = sprintf('Shape "sphere" "float radius" [.1]');

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

end


