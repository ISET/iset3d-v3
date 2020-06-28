function piLightWrite(thisR)
% Write a file with the lights for this recipe
%
% Synopsis
%   piLightWrite(thisR)
%
% Brief description
%  This function writes out the file containing the descriptions of the
%  scene lights for the PBRT scene. The scene_lights file is included by
%  the main scene file.
%
% Input
%   thisR - ISET3d recipe
%
% Optional key/value pairs
%   N/A
%
% Outputs
%   N/A
%
% See also
%  piLightGet

% Examples:
%{
 thisR = piRecipeDefault;
 piLightGet(thisR);
 piWrite(thisR);
 scene = piRender(thisR);
 sceneWindow(scene);
%}

%% parse inputs
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.parse(thisR);

%% Write out light sources one by one
lightSourceText = cell(1, numel(thisR.lights));

%% Check all applicable parameters for every light
for ii = 1:numel(thisR.lights)
    
    thisLightSource = thisR.lights{ii};
    if isfield(thisLightSource, 'type'), type = thisLightSource.type;
    else, type = 'point'; end
    
    if isfield(thisLightSource, 'lightspectrum')
        if isnumeric(thisLightSource.lightspectrum)
            lightSpectrum = ['[ ' num2str(thisLightSource.lightspectrum), ']'];
        else
            lightSpectrum = sprintf('"spds/lights/%s.spd"', thisLightSource.lightspectrum);
        end
    else
        % There is no specified light spectrum.  So we assign D65.
        lightSpectrum = sprintf('"spds/lights/%s.spd"', 'D65');
        thisLightSource.lightspectrum = 'D65';
    end
    
    if isfield(thisLightSource, 'from'), from = thisLightSource.from;
    else, from = [0 0 0]; end
    
    if isfield(thisLightSource, 'to'), to = thisLightSource.to;
    else, to = [0 0 1]; end
    
    if isfield(thisLightSource, 'coneangle'), coneAngle = thisLightSource.coneangle;
    else, coneAngle = 30; end
    
    if isfield(thisLightSource, 'conedeltaangle'), coneDeltaAngle = thisLightSource.conedeltaangle;
    else, coneDeltaAngle = 5; end
    
    if isfield(thisLightSource, 'spectrumscale'), spectrumScale = thisLightSource.spectrumscale;
    else, spectrumScale = 1; end
    
    if isfield(thisLightSource, 'mapname'), mapname = thisLightSource.mapname;
    else, mapname = ''; end
    
    % This is a marker for the position where we define the light source
    if isfield(thisLightSource, 'pos'), pos = thisLightSource.pos;
    else, pos = 1; end
    
    % This is the text defining the whole attribute section of light
    if isfield(thisLightSource, 'line'), line = thisLightSource.line;
    else, line = {}; end
    
    % This is the parameter especially used by infinite light
    if isfield(thisLightSource, 'nsamples'), nsamples = thisLightSource.nsamples;
    else, nsamples = 16; end
    
    % This is the parameter for area light
    if isfield(thisLightSource, 'twosided')
        if thisLightSource.twosided == 1
            twosided = 'true';
        else
            twosided = 'false';
        end
    else
        twosided = 'false';
    end
    
    %% Write out lightspectrum to the file
    if exist('lightSpectrum', 'var')
        if ischar(thisLightSource.lightspectrum)
            try
                % This is the wavelength hardcoded in PBRT
                wavelength = 365:5:705;
                data = ieReadSpectra(thisLightSource.lightspectrum, wavelength, 0);
            catch
                error('%s light is not recognized \n', thisLightSource.lightspectrum);
            end
            outputDir = fileparts(thisR.outputFile);
            lightSpdDir = fullfile(outputDir, 'spds', 'lights');
            thisLightfile = fullfile(lightSpdDir,...
                sprintf('%s.spd', thisLightSource.lightspectrum));
            if ~exist(lightSpdDir, 'dir'), mkdir(lightSpdDir); end
            fid = fopen(thisLightfile, 'w');
            for jj = 1: length(data)
                fprintf(fid, '%d %d \n', wavelength(jj), data(jj)*spectrumScale);
            end
            fclose(fid);
            
            % It is a path to spd file
            spectrumType = "spectrum";
        elseif isnumeric(thisLightSource.lightspectrum)
            %% Determine the color representation
            % It's in RGB or number defined spectrum
            if numel(thisLightSource.lightspectrum) == 3
                % Use three numbers for RGB values.
                spectrumType = "rgb";
            elseif numel(thisLightSource.lightspectrum) == 2
                % User present two values for temperature and scale factor.
                spectrumType = "blackbody";
            else
                % User put values in pair with wavelength and value.
                if mod(numel(thisLightSource.lightspectrum), 2) == 0
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
            lightSourceText{ii}.type = 'point';
            if thisLightSource.cameracoordinate
                lightSourceText{ii}.line{1} = 'AttributeBegin';
                lightSourceText{ii}.line{2,:} = 'CoordSysTransform "camera"';
                lightSourceText{ii}.line{3,:} = sprintf('LightSource "point" "%s I" %s', spectrumType, lightSpectrum);
                lightSourceText{ii}.line{end+1} = 'AttributeEnd';
            else
                lightSourceText{ii}.line{1,:} = sprintf('LightSource "point" "%s I" %s "point from" [%.4f %.4f %.4f]',...
                    spectrumType, lightSpectrum, from(1), from(2), from(3));
            end
            
            
        case 'spot'
            lightSourceText{ii}.type = 'spot';
            thisConeAngle = sprintf('"float coneangle" [%.4f]', coneAngle);
            thisConeDelta = sprintf('"float conedeltaangle" [%.4f]', coneDeltaAngle);
            
            if thisLightSource.cameracoordinate
                lightSourceText{ii}.line{1} = 'AttributeBegin';
                lightSourceText{ii}.line{2,:} = 'CoordSysTransform "camera"';
                lightSourceText{ii}.line{3,:} = sprintf('LightSource "spot" "%s I" %s %s %s',...
                    spectrumType, lightSpectrum, thisConeAngle, thisConeDelta);
                lightSourceText{ii}.line{end+1} = 'AttributeEnd';
            else
                lightSourceText{ii}.line{1,:} = sprintf('LightSource "spot" "%s I" %s "point from" [%.4f %.4f %.4f] "point to" [%.4f %.4f %.4f] %s %s',...
                    spectrumType, lightSpectrum, from(1), from(2), from(3), to(1), to(2), to(3), thisConeAngle, thisConeDelta);
            end
            
        case 'laser' % not supported for public
            lightSourceText{ii}.line{1,:} = sprintf('LightSource "laser" "%s I" %s "point from" [%.4f %.4f %.4f] "point to" [%.4f %.4f %.4f]',...
                spectrumType, lightSpectrum, from(1), from(2), from(3), to(1), to(2), to(3));
            thisConeAngle = sprintf('float coneangle [%d]', coneAngle);
            thisConeDelta = sprintf('float conedelataangle [%d]', coneDeltaAngle);
            lightSourceText{ii}.line{1,:} = [lightSourceText{end+1}.line{2}, thisConeAngle, thisConeDelta];
        case 'distant'
            if thisLightSource.cameracoordinate
                lightSourceText{ii}.line{1} = 'AttributeBegin';
                lightSourceText{ii}.line{2} = 'CoordSysTransform "camera"';
                
                lightSourceText{ii}.line{3} = sprintf('LightSource "distant" "%s L" %s', spectrumType, lightSpectrum);
                lightSourceText{ii}.line{end+1} = 'AttributeEnd';
            else
                lightSourceText{ii}.line{1,:} = sprintf('LightSource "distant" "%s L" %s "point from" [%.4f %.4f %.4f] "point to" [%.4f %.4f %.4f]',...
                    spectrumType, lightSpectrum, from, to);
            end
            
        case 'infinite'
            lightSourceText{ii}.type = 'infinite';
            
            lightSourceText{ii}.line = line;
            if isempty(mapname)
                lightSourceText{ii}.line{pos} = sprintf('LightSource "infinite" "%s L" %s "integer nsamples" [%d]', spectrumType, lightSpectrum, nsamples);
            else
                lightSourceText{ii}.line{pos} = sprintf('LightSource "infinite" "string mapname" "%s" "integer nsamples" [%d]', mapname, nsamples);
            end
        case 'area'
            lightSourceText{ii}.line = line;
            lightSourceText{ii}.line{pos} = sprintf('AreaLightSource "diffuse" "%s L" %s "bool twosided" "%s" "integer nsamples" [%d]',...
                spectrumType, lightSpectrum, twosided, nsamples);
            
    end
end

%% Write to scene_lights.pbrt file
[workingDir, n] = fileparts(thisR.outputFile);
fname_lights = fullfile(workingDir, sprintf('%s_lights.pbrt', n));

fid = fopen(fname_lights, 'w');
fprintf(fid, '# Exported by piLightWrite on %i/%i/%i %i:%i:%0.2f \n',clock);

for ii = 1:numel(lightSourceText)
    for jj = 1:numel(lightSourceText{ii}.line)
        fprintf(fid, '%s \n',lightSourceText{ii}.line{jj});
    end
end
end