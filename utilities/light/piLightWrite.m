function lightSourceText = piLightWrite(thisR, varargin)
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
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.addParameter('writefile', true);
p.parse(thisR, varargin{:});

writefile = p.Results.writefile;

%% Write out light sources one by one
lightSourceText = cell(1, numel(thisR.lights));

%% Check all applicable parameters for every light
for ii = 1:numel(thisR.lights)
    thisLight = thisR.lights{ii};
    spectrumScale = piLightGet(thisLight, 'specscale val');
    
    %% Write out lightspectrum to the file if the data is from file
    specVal = piLightGet(thisLight, 'spd val');
    if ~isempty(specVal)
        if ischar(specVal)
            [~,~,ext] = fileparts(specVal);
            if isequal(ext,'.spd')
                % User has a local file that will be copied
            else
                % Read the mat file.  Should have a mat extension.
                % This is the wavelength hardcoded in PBRT
                wavelength = 365:5:705;
                if isequal(ext,'.mat') || isempty(ext)
                    data = ieReadSpectra(specVal, wavelength, 0);
                else
                    error('Light extension seems wrong: %s\n',ext);
                end

                % Saving the light information in the spd sub-directory 
                outputDir = thisR.get('output dir');
                lightSpdDir = fullfile(outputDir, 'spds', 'lights');
                thisLightfile = fullfile(lightSpdDir,...
                    sprintf('%s_%f.spd', specVal, spectrumScale));
                if ~exist(lightSpdDir, 'dir'), mkdir(lightSpdDir); end
                
                fid = fopen(thisLightfile, 'w');
                for jj = 1: length(data)
                    fprintf(fid, '%d %d \n', wavelength(jj), data(jj)*spectrumScale);
                end
                fclose(fid);                
                
            end        
        elseif isnumeric(specVal)
            % Numeric.  Do nothing
        else
            % Not numeric or char but not empty.  So, something wrong.
            error('Incorrect light spectrum.');
        end
    end
    
    %% Construct a lightsource structure
    % Different types of lights that we know how to add.
    type = piLightGet(thisLight, 'type');
    
    % We would use attributeBegin/attributeEnd for all cases
    lightSourceText{ii}.line{1} = 'AttributeBegin';
    
    
    switch type
        case 'point'
            % Whether coordinate at camera pos
            if thisLight.cameracoordinate
                lightSourceText{ii}.line{end + 1} = 'CoordSysTransform "camera"';
            end
            
            % First check if there is any rotation, translation or
            % concatransformation
            transTxt = piLightGenerateTransformText(thisLight);
            lightSourceText{ii}.line = [lightSourceText{ii}.line transTxt];
            
            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);
            
            % spectrum
            [~, spdTxt] = piLightGet(thisLight, 'spd val', 'pbrt text', true);
            if ~isempty(spdTxt)
                lghtDef = strcat(lghtDef, spdTxt);
            end
            
            % From
            [~, fromTxt] = piLightGet(thisLight, 'from val', 'pbrt text', true);
            if ~isempty(fromTxt)
                lghtDef = strcat(lghtDef, fromTxt);
            end
            
            lightSourceText{ii}.line = [lightSourceText{ii}.line lghtDef];
                        
        case 'distant'
            % Whether coordinate at camera pos
            if thisLight.cameracoordinate
                lightSourceText{ii}.line{end + 1} = 'CoordSysTransform "camera"';
            end
            
            % First check if there is any rotation, translation or
            % concatransformation
            transTxt = piLightGenerateTransformText(thisLight);
            lightSourceText{ii}.line = [lightSourceText{ii}.line transTxt];
            
            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);
            [~, spdTxt] = piLightGet(thisLight, 'spd val', 'pbrt text', true);
            lghtDef = strcat(lghtDef, spdTxt);
            % lghtDef = sprintf('LightSource "distant" "%s L" %s', spectrumType, lightSpectrum);
            
            % From
            [~, fromTxt] = piLightGet(thisLight, 'from val', 'pbrt text', true);
            if ~isempty(fromTxt)
                lghtDef = strcat(lghtDef, fromTxt);
            end
            
            % To
            [~, toTxt] = piLightGet(thisLight, 'to val', 'pbrt text', true);
            if ~isempty(toTxt)
                lghtDef = strcat(lghtDef, toTxt);
            end
            
            lightSourceText{ii}.line = [lightSourceText{ii}.line lghtDef];
            
            
        case 'goniometric'
            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);
            
            % spectrum
            [~, spdTxt] = piLightGet(thisLight, 'spd val', 'pbrt text', true);
            if ~isempty(spdTxt)
                lghtDef = strcat(lghtDef, spdTxt);
            end
            
            % mapname
            [~, mapnameTxt] = piLightGet(thisLight, 'mapname val', 'pbrt text', true);
            if ~isempty(mapnameTxt)
                lghtDef = strcat(lghtDef, mapnameTxt);
            end
            
            lightSourceText{ii}.line = [lightSourceText{ii}.line lghtDef];
            
        case 'infinite'
            % First check if there is any rotation, translation or
            % concatransformation
            transTxt = piLightGenerateTransformText(thisLight);
            lightSourceText{ii}.line = [lightSourceText{ii}.line transTxt];
            
            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);
            
            % spectrum
            [~, spdTxt] = piLightGet(thisLight, 'spd val', 'pbrt text', true);
            if ~isempty(spdTxt)
                lghtDef = strcat(lghtDef, spdTxt);
            end
            
            % lghtDef = sprintf('LightSource "infinite" "%s L" %s', spectrumType, lightSpectrum);
            
            % nsamples
            [~, nsamplesTxt] = piLightGet(thisLight, 'nsamples val', 'pbrt text', true);
            if ~isempty(nsamplesTxt)
                lghtDef = strcat(lghtDef, nsamplesTxt);
            end
            
            % mapname
            [mapName, mapnameTxt] = piLightGet(thisLight, 'mapname val', 'pbrt text', true);
            if ~isempty(mapnameTxt)
                lghtDef = strcat(lghtDef, mapnameTxt);
                
                if ~exist(fullfile(thisR.get('output dir'),mapName),'file')
                    mapFile = which(mapName);
                    copyfile(mapFile,thisR.get('output dir'))
                end
            end
            
            lightSourceText{ii}.line = [lightSourceText{ii}.line lghtDef];
            
        case 'projection'
            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);
            
            % spectrum
            [~, spdTxt] = piLightGet(thisLight, 'spd val', 'pbrt text', true);
            if ~isempty(spdTxt)
                lghtDef = strcat(lghtDef, spdTxt);
            end
            
            % mapname
            [~, mapnameTxt] = piLightGet(thisLight, 'mapname val', 'pbrt text', true);
            if ~isempty(mapnameTxt)
                lghtDef = strcat(lghtDef, mapnameTxt);
            end
            
            % fov
            [~, fovTxt] = piLightGet(thisLight, 'fov val', 'pbrt text', true);
            if ~isempty(fovTxt)
                lghtDef = strcat(lghtDef, fovTxt);
            end
            
            lightSourceText{ii}.line = [lightSourceText{ii}.line lghtDef];
            
        case {'spot', 'spotlight'}
            % Whether coordinate at camera pos
            if thisLight.cameracoordinate
                lightSourceText{ii}.line{end + 1} = 'CoordSysTransform "camera"';
            end
            
            % First check if there is any rotation, translation or
            % concatransformation
            transTxt = piLightGenerateTransformText(thisLight);
            lightSourceText{ii}.line = [lightSourceText{ii}.line transTxt];
            
            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);
            
            % spectrum
            [~, spdTxt] = piLightGet(thisLight, 'spd val', 'pbrt text', true);
            if ~isempty(spdTxt)
                lghtDef = strcat(lghtDef, spdTxt);
            end
            
            % From
            [~, fromTxt] = piLightGet(thisLight, 'from val', 'pbrt text', true);
            if ~isempty(fromTxt)
                lghtDef = strcat(lghtDef, fromTxt);
            end
            
            % To
            [~, toTxt] = piLightGet(thisLight, 'to val', 'pbrt text', true);
            if ~isempty(toTxt)
                lghtDef = strcat(lghtDef, toTxt);
            end
            
            % Cone angle
            [~, coneangleTxt] = piLightGet(thisLight, 'coneangle val', 'pbrt text', true);
            if ~isempty(coneangleTxt)
                lghtDef = strcat(lghtDef, coneangleTxt);
            end
            
            % Cone delta angle
            [~, conedeltaangleTxt] = piLightGet(thisLight, 'conedeltaangle val', 'pbrt text', true);
            if ~isempty(conedeltaangleTxt)
                lghtDef = strcat(lghtDef, conedeltaangleTxt);
            end
            
            lightSourceText{ii}.line = [lightSourceText{ii}.line lghtDef];
            
            
        case 'area'
            % First check if there is any rotation, translation or
            % concatransformation
            transTxt = piLightGenerateTransformText(thisLight);
            lightSourceText{ii}.line = [lightSourceText{ii}.line transTxt];
            
            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);
            
            % spectrum
            [~, spdTxt] = piLightGet(thisLight, 'spd val', 'pbrt text', true);
            if ~isempty(spdTxt)
                lghtDef = strcat(lghtDef, spdTxt);
            end
            % lghtDef = sprintf('AreaLightSource "diffuse" "%s L" %s', spectrumType, lightSpectrum);
            
            % nsamples
            [~, nsamplesTxt] = piLightGet(thisLight, 'nsamples val', 'pbrt text', true);
            if ~isempty(nsamplesTxt)
                lghtDef = strcat(lghtDef, nsamplesTxt);
            end
            
            % twosided
            [~, twosidedTxt] = piLightGet(thisLight, 'twosided val', 'pbrt text', true);
            if ~isempty(twosidedTxt)
                lghtDef = strcat(lghtDef, twosidedTxt);
            end
            
            lightSourceText{ii}.line = [lightSourceText{ii}.line lghtDef];
            
            % Attach shape
            [~, shpTxt] = piLightGet(thisLight, 'shape val', 'pbrt text', true);
            
            lightSourceText{ii}.line = [lightSourceText{ii}.line shpTxt];
            
    end
    lightSourceText{ii}.line{end+1} = 'AttributeEnd';
    
end



if writefile
    %% Write to scene_lights.pbrt file
    [workingDir, n] = fileparts(thisR.outputFile);
    fname_lights = fullfile(workingDir, sprintf('%s_lights.pbrt', n));
    
    fid = fopen(fname_lights, 'w');
    fprintf(fid, '# Exported by piLightWrite on %i/%i/%i %i:%i:%0.2f \n',clock);
    
    for ii = 1:numel(lightSourceText)
        for jj = 1:numel(lightSourceText{ii}.line)
            fprintf(fid, '%s \n',lightSourceText{ii}.line{jj});
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
end
end