function lightSources = piLightAddToWorld(thisR, varargin)
%% This function is going to be deprecated
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
% Zheng Lyu, 2020
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
  thisR = piLightDelete(thisR, 1);
  thisR = piLightAdd(thisR, 'type', 'point');
  thisR = piLightAdd(thisR, 'type', 'point', 'camera coordinate', true);
  piLightGet(thisR);
%}

%% Parse inputs

varargin = ieParamFormat(varargin);  % Allow spaces and capitalization

p = inputParser;
p.addRequired('recipe', @(x)(isa(x,'recipe')));
p.addParameter('lightsource',[],@isstruct);

p.parse(thisR, varargin{:});
lightSource = p.Results.lightsource;

%% Check all applicable parameters

if isfield(lightSource, 'type'), type = lightSource.type;
else, type = 'point'; end

if isfield(lightSource, 'lightspectrum')
    if isnumeric(lightSource.lightspectrum)
        lightSpectrum = ['[ ' num2str(reshape(lightSource.lightspectrum, [1, numel(lightSource.lightspectrum)])), ']'];
    else
        lightSpectrum = sprintf('"spds/lights/%s.spd"', lightSource.lightspectrum);
    end
else
    % There is no specified light spectrum.  So we assign D65.
    lightSpectrum = sprintf('"spds/lights/%s.spd"', 'D65');
    lightSource.lightspectrum = 'D65';
end

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

if isfield(lightSource, 'mapname'), mapname = lightSource.mapname;
else, mapname = ''; end

% This is a marker for the position where we define the light source
if isfield(lightSource, 'pos'), pos = lightSource.pos;
else, pos = 1; end

% This is the text defining the whole attribute section of light
if isfield(lightSource, 'line'), line = lightSource.line;
else, line = {}; end

% This is the parameter especially used by infinite light
if isfield(lightSource, 'nsamples'), nsamples = lightSource.nsamples;
else, nsamples = 16; end 

% This is the parameter for area light
if isfield(lightSource, 'twosided')
    if lightSource.twosided == 1
        twosided = 'true';
    else
        twosided = 'false';
    end
else
    twosided = 'false';
end

%% Write out lightspectrum
if exist('lightSpectrum', 'var')
    if ischar(lightSource.lightspectrum)
        try
            % This is the wavelength hardcoded in PBRT
            wavelength = 365:5:705;
            data = ieReadSpectra(lightSource.lightspectrum, wavelength, 0);
        catch
            error('%s light is not recognized \n', lightSource.lightspectrum);
        end
        outputDir = fileparts(thisR.outputFile);
        lightSpdDir = fullfile(outputDir, 'spds', 'lights');
        thisLightfile = fullfile(lightSpdDir,...
            sprintf('%s.spd', lightSource.lightspectrum));
        if ~exist(lightSpdDir, 'dir'), mkdir(lightSpdDir); end
        fid = fopen(thisLightfile, 'w');
        for ii = 1: length(data)
            fprintf(fid, '%d %d \n', wavelength(ii), data(ii)*spectrumScale);
        end
        fclose(fid);
        
        % It is a path to spd file
        spectrumType = "spectrum";
    elseif isnumeric(lightSource.lightspectrum) 
        %% Determine the color representation
        % It's in RGB or number defined spectrum
        if numel(lightSource.lightspectrum) == 3
            % Use three numbers for RGB values.
            spectrumType = "rgb";
        elseif numel(lightSource.lightspectrum) == 2
            % User present two values for temperature and scale factor.
            spectrumType = "blackbody";
        else
            % User put values in pair with wavelength and value.
            if mod(numel(lightSource.lightspectrum), 2) == 0
                spectrumType = "spectrum";
            else
                error('Bad light spectrum');
            end
        end
    else
        error('Incorrect light spectrum.');
    end
end

%% Construct a lightsource structure

% Different types of lights that we know how to add.
switch type
    case 'point'
        lightSources{1}.type = 'point';
        if lightSource.cameracoordinate
            lightSources{1}.line{1} = 'AttributeBegin';
            lightSources{1}.line{2,:} = 'CoordSysTransform "camera"';
            lightSources{1}.line{3,:} = sprintf('LightSource "point" "%s I" %s', spectrumType, lightSpectrum);
            lightSources{1}.line{end+1} = 'AttributeEnd';
        else
            lightSources{1}.line{1,:} = sprintf('LightSource "point" "%s I" %s "point from" [%.4f %.4f %.4f]',...
                spectrumType, lightSpectrum, from(1), from(2), from(3));
        end


    case 'spot'
        lightSources{1}.type = 'spot';
        thisConeAngle = sprintf('"float coneangle" [%.4f]', coneAngle);
        thisConeDelta = sprintf('"float conedeltaangle" [%.4f]', coneDeltaAngle);

        if lightSource.cameracoordinate
            lightSources{1}.line{1} = 'AttributeBegin';
            lightSources{1}.line{2,:} = 'CoordSysTransform "camera"';
            lightSources{1}.line{3,:} = sprintf('LightSource "spot" "%s I" %s %s %s',...
                spectrumType, lightSpectrum, thisConeAngle, thisConeDelta);
            lightSources{1}.line{end+1} = 'AttributeEnd';
        else
            lightSources{1}.line{1,:} = sprintf('LightSource "spot" "%s I" %s "point from" [%.4f %.4f %.4f] "point to" [%.4f %.4f %.4f] %s %s',...
                spectrumType, lightSpectrum, from(1), from(2), from(3), to(1), to(2), to(3), thisConeAngle, thisConeDelta);
        end

        % Set spectrum information
        lightSources{1}.lightspectrum = lightSpectrum;

        %Set light position and direction
        lightSources{1}.position = from;
        lightSources{1}.direction = to;

        % Set coneAngle and coneDeltaAngle
        lightSources{1}.coneangle = coneAngle;
        lightSources{1}.conedeltaangle = coneDeltaAngle;



    case 'laser' % not supported for public
        lightSources{1}.type = 'laser';
        lightSources{1}.line{1,:} = sprintf('LightSource "laser" "%s I" %s "point from" [%.4f %.4f %.4f] "point to" [%.4f %.4f %.4f]',...
            spectrumType, lightSpectrum, from(1), from(2), from(3), to(1), to(2), to(3));
        thisConeAngle = sprintf('float coneangle [%d]', coneAngle);
        thisConeDelta = sprintf('float conedelataangle [%d]', coneDeltaAngle);
        lightSources{1}.line{1,:} = [lightSources{end+1}.line{2}, thisConeAngle, thisConeDelta];
    case 'distant'
        lightSources{1}.type = 'distant';
        if lightSource.cameracoordinate
            lightSources{1}.line{1} = 'AttributeBegin';
            lightSources{1}.line{2} = 'CoordSysTransform "camera"';
            
            lightSources{1}.line{3} = sprintf('LightSource "distant" "%s L" %s', spectrumType, lightSpectrum);
            lightSources{1}.line{end+1} = 'AttributeEnd';            
        else
            lightSources{1}.line{1,:} = sprintf('LightSource "distant" "%s L" %s "point from" [%.4f %.4f %.4f] "point to" [%.4f %.4f %.4f]',...
                spectrumType, lightSpectrum, from, to);
        end

        % Set spectrum information
        lightSources{1}.lightspectrum = lightSpectrum;

        %Set light position and direction
        lightSources{1}.position = from;
        lightSources{1}.direction = to;
    case 'infinite'
        lightSources{1}.type = 'infinite';
        
        lightSources{1}.line = line;
        if isempty(mapname)
            % Set spectrum information
            lightSources{1}.lightspectrum = lightSpectrum;
            lightSources{1}.line{pos} = sprintf('LightSource "infinite" "%s L" %s "integer nsamples" [%d]', spectrumType, lightSpectrum, nsamples);
        else
            lightSources{1}.mapname = mapname;
            lightSources{1}.line{pos} = sprintf('LightSource "infinite" "string mapname" "%s" "integer nsamples" [%d]', mapname, nsamples);
        end
    case 'area'
        lightSources{1}.type = 'area';
        lightSources{1}.line = line;
        lightSources{1}.line{pos} = sprintf('AreaLightSource "diffuse" "%s L" %s "bool twosided" "%s" "integer nsamples" [%d]',...
                                                spectrumType, lightSpectrum, twosided, nsamples);
        
end

end


