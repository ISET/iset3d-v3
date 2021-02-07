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
    specVal = piLightGet(thisLight, 'spectrum val');
    if ~isempty(specVal)
        if ischar(specVal)
            try
                % This is the wavelength hardcoded in PBRT
                wavelength = 365:5:705;
                data = ieReadSpectra(specVal, wavelength, 0);
            catch
                error('%s light is not recognized \n', specVal);
            end
            outputDir = fileparts(thisR.outputFile);
            lightSpdDir = fullfile(outputDir, 'spds', 'lights');
            thisLightfile = fullfile(lightSpdDir,...
                sprintf('%s_%f.spd', specVal, spectrumScale));
            if ~exist(lightSpdDir, 'dir'), mkdir(lightSpdDir); end
            fid = fopen(thisLightfile, 'w');
            for jj = 1: length(data)
                fprintf(fid, '%d %d \n', wavelength(jj), data(jj)*spectrumScale);
            end
            fclose(fid);
            
            % It is a path to spd file
            spectrumType = "spectrum";
            
            %{
                % Construct light spectrum
                lightSpectrum = sprintf('"spds/lights/%s_%f.spd"', specVal, spectrumScale);
            %}
        elseif isnumeric(specVal)
            %% Determine the color representation
            % It's in RGB or number defined spectrum
            if numel(specVal) == 3
                % Use three numbers for RGB values.
                spectrumType = "rgb";
            elseif numel(specVal) == 2
                % User present two values for temperature and scale factor.
                spectrumType = "blackbody";
            else
                % User put values in pair with wavelength and value.
                if mod(numel(specVal), 2) == 0
                    spectrumType = "spectrum";
                else
                    error('Bad light spectrum');
                end
            end
            
            %{
                % Construct light spectrum text
                lightSpectrum = ['[' ,piNum2String(thisLight.lightspectrum * spectrumScale),']'];
            %}
        else
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
            % First check if there is any rotation, translation or
            % concatransformation
            transTxt = piLightGenerateTransformText(thisLight);
            lightSourceText{ii}.line = [lightSourceText{ii}.line transTxt];
            
            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);

            % spectrum
            [~, spdTxt] = piLightGet(thisLight, 'spectrum val', 'pbrt text', true);
            if ~isempty(spdTxt)
                lghtDef = strcat(lghtDef, spdTxt);
            end
            
            % From
            [~, fromTxt] = piLightGet(thisLight, 'from val', 'pbrt text', true);
            if ~isempty(fromTxt)
                lghtDef = strcat(lghtDef, fromTxt);
            end
            
            lightSourceText{ii}.line = [lightSourceText{ii}.line lghtDef];
            
            % Whether coordinate at camera pos
            if thisLight.cameracoordinate
                lightSourceText{ii}.line{end + 1} = 'CoordSysTransform "camera"';
            end

        case 'distant'
            % First check if there is any rotation, translation or
            % concatransformation
            transTxt = piLightGenerateTransformText(thisLight);
            lightSourceText{ii}.line = [lightSourceText{ii}.line transTxt];

            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);
            [~, spdTxt] = piLightGet(thisLight, 'spectrum val', 'pbrt text', true);
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

            % Whether coordinate at camera pos
            if thisLight.cameracoordinate
                lightSourceText{ii}.line{end + 1} = 'CoordSysTransform "camera"';
            end
        case 'goniometric'
            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);

            % spectrum
            [~, spdTxt] = piLightGet(thisLight, 'spectrum val', 'pbrt text', true);
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
            [~, spdTxt] = piLightGet(thisLight, 'spectrum val', 'pbrt text', true);
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
            [~, mapnameTxt] = piLightGet(thisLight, 'mapname val', 'pbrt text', true);
            if ~isempty(mapnameTxt)
                lghtDef = strcat(lghtDef, mapnameTxt);
            end

            lightSourceText{ii}.line = [lightSourceText{ii}.line lghtDef];
            
        case 'projection'
            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);

            % spectrum
            [~, spdTxt] = piLightGet(thisLight, 'spectrum val', 'pbrt text', true);
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
            % First check if there is any rotation, translation or
            % concatransformation
            transTxt = piLightGenerateTransformText(thisLight);
            lightSourceText{ii}.line = [lightSourceText{ii}.line transTxt];
            
            % Construct the light definition line
            [~, lghtDef] = piLightGet(thisLight, 'type', 'pbrt text', true);

            % spectrum
            [~, spdTxt] = piLightGet(thisLight, 'spectrum val', 'pbrt text', true);
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
            [~, spdTxt] = piLightGet(thisLight, 'spectrum val', 'pbrt text', true);
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

%% Old version
%{
%% Check all applicable parameters for every light
for ii = 1:numel(thisR.lights)
    
    thisLightSource = thisR.lights{ii};
    if isfield(thisLightSource, 'type'), type = thisLightSource.type;
    else, type = 'point'; end
   
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
    
    if isfield(thisLightSource, 'lightspectrum')&& ~isempty(thisLightSource.lightspectrum)
        if isnumeric(thisLightSource.lightspectrum)
            lightSpectrum = ['[' ,piNum2String(thisLightSource.lightspectrum),']'];
        else
            lightSpectrum = sprintf('"spds/lights/%s_%f.spd"', thisLightSource.lightspectrum, spectrumScale);
        end
    else
        % There is no specified light spectrum.  So we assign D65.
        lightSpectrum = sprintf('"spds/lights/%s_%f.spd"', 'D65', spectrumScale);
        thisLightSource.lightspectrum = 'D65';
    end
    
    if isfield(thisLightSource, 'mapname'), mapname = thisLightSource.mapname;
    else, mapname = ''; end
    
    % This is a marker for the position where we define the light source
    if isfield(thisLightSource, 'pos'), pos = thisLightSource.pos;
    else, pos = 1; end
    
    % This is the text defining the whole attribute section of light
    if isfield(thisLightSource, 'line'), line = thisLightSource.line;
    else, line = {}; end
    
    % This is the parameter especially used by infinite light and area
    % light
    if isfield(thisLightSource, 'nsamples')&& ~isempty(thisLightSource.nsamples), nsamples = thisLightSource.nsamples;
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
    
    if isfield(thisLightSource, 'rotate') 
        rotate = thisLightSource.rotate;
    else
        rotate = [];
    end
    
    if isfield(thisLightSource, 'concattransform') && ~isempty(thisLightSource.concattransform) 
        ctform = thisLightSource.concattransform;
    else
        ctform = [];
    end
    
    if isfield(thisLightSource, 'position') && ~isempty(thisLightSource.position)
        position = thisLightSource.position;
    else
        position = [];
    end
    
    if isfield(thisLightSource, 'shape') && ~isempty(thisLightSource.shape)
        shape = thisLightSource.shape;
    else
        shape = [];
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
                sprintf('%s_%f.spd', thisLightSource.lightspectrum, spectrumScale));
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
                lightSourceText{ii}.line = line;
                lightSourceText{ii}.line{pos} = sprintf('LightSource "point" "%s I" %s "point from" [%.4f %.4f %.4f]',...
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
                lightSourceText{ii}.line = line;
                lightSourceText{ii}.line{pos} = sprintf('LightSource "spot" "%s I" %s "point from" [%.4f %.4f %.4f] "point to" [%.4f %.4f %.4f] %s %s',...
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
                lightSourceText{ii}.line = line;
                lightSourceText{ii}.line{pos} = sprintf('LightSource "distant" "%s L" %s "point from" [%.4f %.4f %.4f] "point to" [%.4f %.4f %.4f]',...
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
            % lightSourceText{ii}.line = line;
            % lightSourceText{ii}.line{pos} = sprintf('AreaLightSource "diffuse" "%s L" %s "bool twosided" "%s" "integer nsamples" [%d]',...
            %     spectrumType, lightSpectrum, twosided, nsamples);
            lightSourceText{ii}.line{1} = 'AttributeBegin';
            if ~isempty('position') && ~isempty(position)
                % might remove this;
                if iscell(position)
                    position = position{1};
                end
                lightSourceText{ii}.line{end+1} = sprintf('Translate %.3f %.3f %.3f',...
                        position(1), position(2), position(3));
            end
            if ~isempty('rotate') && ~isempty(rotate)
                % might remove this;
                if iscell(rotate)
                    rotate = rotate{1};
                end
                rot_size = size(rotate);
                if rot_size(1)>rot_size(2)
                    rotate = rotate';
                end
                for rr = 1:3
                    thisRotate = rotate(rr,:);
                    degree = thisRotate(1);
                    if thisRotate(2)==1 
                        x_degree = degree;
                    elseif thisRotate(3)==1
                        y_degree = degree;
                    elseif thisRotate(4)==1
                        z_degree = degree;
                    end
                end
                if exist('z_degree','var')
                    lightSourceText{ii}.line{end+1} = sprintf('Rotate %.3f 0 0 1', z_degree);
                end
                if exist('y_degree', 'var')
                    lightSourceText{ii}.line{end+1} = sprintf('Rotate %.3f 0 1 0', y_degree);
                end
                if exist('x_degree', 'var')
                    lightSourceText{ii}.line{end+1} = sprintf('Rotate %.3f 1 0 0', x_degree);
                end
            elseif exist('ctform', 'var') && ~isempty(ctform)
                lightSourceText{ii}.line{end+1} = sprintf('ConcatTransform [%.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f]', ctform(:));
            end
            % Add light properties
            lightSourceText{ii}.line{end+1} = sprintf('AreaLightSource "diffuse" "%s L" %s "bool twosided" "%s" "integer nsamples" [%d]',...
                         spectrumType, lightSpectrum, twosided, nsamples);
            % Add shape information
            if ~isempty('shape')
                lightSourceText{ii}.line{end+1} = piShape2Text(shape);
            end
            
            lightSourceText{ii}.line{end+1} = 'AttributeEnd';
    end
end
%}

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
end
end