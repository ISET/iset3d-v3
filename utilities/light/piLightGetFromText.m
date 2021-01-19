function lightSources = piLightGetFromText(thisR, intext, varargin)
% Read a light source struct based on the parameters in the recipe
%
% This routine only works for light sources that are exported from
% Cinema 4D.  It will not work in all cases.  We should fix that.
%
% Inputs
%   thisR:  Recipe
%   intext
% Optional key/val pairs
%   print:   Printout the list of lights
%
% Returns
%   lightSources:  Cell array of light source structures
%
% Zhenyi, SCIEN, 2019
% Zheng Lyu    , 2020
% See also
%   piLightDeleteWorld, piLightAddToWorld

% Examples
%{
  thisR = piRecipeDefault;
  lightSources = piLightGet(thisR);
  thisR = piLightDelete(thisR, 1);
  thisR = piLightAdd(thisR, 'type', 'point');
  thisR = piLightAdd(thisR, 'type', 'point', 'camera coordinate', true);
  piLightGet(thisR);
%}

%% Parse inputs

varargin = ieParamFormat(varargin);
p  = inputParser;
p.addRequired('thisR', @(x)(isa(x,'recipe')));
p.addRequired('intext', @iscell);
p.addParameter('printinfo',true);

p.parse(thisR, intext, varargin{:});

%%   Find the indices of the lines the .world slot that are a LightSource

AttBegin  =  find(piContains(intext,'AttributeBegin'));
AttEnd    =  find(piContains(intext,'AttributeEnd'));
arealight =  piContains(intext,'AreaLightSource');
light     =  piContains(intext,'LightSource');
lightIdx  =  find(light);   % Find which lines have LightSource on them.

%% Parse the properties of the light in each line in the lightIdx list

nLights = sum(light);
lightSources = cell(1, nLights);

for ii = 1:nLights
    %     % Initialize the light structure
    %     lightSources{ii} = piLightCreate(thisR);
    
    % Find the attributes sections of the input text from the World.
    %
    if length(AttBegin) >= ii &&...
            lightIdx(ii) > AttBegin(ii) &&...
            lightIdx(ii) < AttEnd(ii)
        lightSources{ii}.line  = intext(AttBegin(ii):AttEnd(ii));
        lightSources{ii}.range = [AttBegin(ii), AttEnd(ii)];
        lightSources{ii}.pos   = lightIdx(ii) - AttBegin(ii) + 1;
    elseif strncmp(intext(lightIdx(ii)-1),'Transform ',10)
        light(arealight) = 0;
        lightSources{ii}.line = intext(lightIdx(ii)-1:lightIdx(ii));
        lightSources{ii}.range = [lightIdx(ii)-1 lightIdx(ii)];
    else
        light(arealight) = 0;
        lightSources{ii}.line  = intext(lightIdx(ii));
        lightSources{ii}.range = lightIdx(ii);
    end
    
    % The txt below is derived from the intext stored in the
    % lightSources.line slot.
    if find(piContains(lightSources{ii}.line, 'AreaLightSource'))
        lightSources{ii}.type = 'area';
        thisLine = lightSources{ii}.line{piContains(lightSources{ii}.line, 'AreaLightSource')};
        lightSources{ii}.lightspectrum = piParameterGet(thisLine, 'L');
        twoside = piParameterGet(thisLine, 'bool twosided');
        if twoside
            if strcmp(twoside, 'false')
                lightSources{ii}.twosided = 0;
            else
                lightSources{ii}.twosided = 1;
            end
        end
        lightSources{ii}.nsamples = piParameterGet(thisLine, 'integer nsamples');
        
        % Parse ConcatTransform
        concatTrans = find(piContains(lightSources{ii}.line, 'ConcatTransform'));
        if concatTrans
            [rot, position, ctform] = piParseConcatTransform(lightSources{ii}.line{concatTrans});
            lightSources{ii}.rotate = rot;
            lightSources{ii}.position = position;
            lightSources{ii}.concattransform = ctform;
        end
        rot = find(piContains(lightSources{ii}.line, 'Rotate'));
        if rot
            [~, lightSources{ii}.rotate] = piParseVector(lightSources{ii}.line(rot));
        end
        
        % Look up translation
        trans = find(piContains(lightSources{ii}.line, 'Translate'));
        if trans
            [~, lightSources{ii}.position] = piParseVector(lightSources{ii}.line(trans));
        end
        % Parse shape
        
        shp = find(piContains(lightSources{ii}.line, 'Shape'));
        if shp
            lightSources{ii}.shape = piParseShape(lightSources{ii}.line{shp});
        end
        % Look up scale
        scl = find(piContains(lightSources{ii}.line, 'Scale'));
        if scl
            [~, lightSources{ii}.scale] = piParseVector(lightSources{ii}.line(scl));
        end
        % Look up Material
        scl = find(piContains(lightSources{ii}.line, 'Material'));
        if scl
            materiallist = piBlockExtract_gp(lightSources{ii}.line, 'blockName','Material');
%             matierallist = parseBlockMaterial(lightSources{ii}.line);
            lightSources{ii}.material = materiallist;
        end
    else
        % Assign type
        lightType = lightSources{ii}.line{piContains(lightSources{ii}.line,'LightSource')};
        lightType = strsplit(lightType, ' ');
        lightSources{ii}.type = lightType{2}(2:end-1); % Remove the quote mark
        lightSources{ii}.cameracoordinate = false;
        if any(piContains(lightSources{ii}.line, 'CoordSysTransform "camera"'))
            lightSources{ii}.cameracoordinate = true;
        end
        thisLine = lightSources{ii}.line{piContains(lightSources{ii}.line, 'LightSource')};
        switch lightSources{ii}.type
            case 'infinite'
                lightSources{ii}.nsamples = piParameterGet(thisLine, 'integer nsamples');
                lightSources{ii}.mapname = piParameterGet(thisLine, 'string mapname');
                %This can returen any type of spectrum
                lightSources{ii}.lightspectrum = piParameterGet(thisLine, 'L');
            case 'spot'
                lightSources{ii}.lightspectrum = piParameterGet(thisLine, 'I');
                lightSources{ii}.from = piParameterGet(thisLine, 'point from');
                lightSources{ii}.to = piParameterGet(thisLine, 'point to');
                lightSources{ii}.coneangle = piParameterGet(thisLine, 'float coneangle');
                lightSources{ii}.conedeltaangle = piParameterGet(thisLine, 'float conedelataangle');
            case 'point'
                lightSources{ii}.lightspectrum = piParameterGet(thisLine, 'I');
                lightSources{ii}.from = piParameterGet(thisLine, 'point from');
            case 'goniometric'
                lightSources{ii}.lightspectrum = piParameterGet(thisLine, 'I');
                lightSources{ii}.mapname = piParameterGet(thisLine, 'string mapname');
            case 'distance'
                lightSources{ii}.lightspectrum = piParameterGet(thisLine, 'L');
                lightSources{ii}.from = piParameterGet(thisLine, 'point from');
                lightSources{ii}.to = piParameterGet(thisLine, 'point to');
            case 'projection'
                lightSources{ii}.lightspectrum = piParameterGet(thisLine, 'I');
                lightSources{ii}.fov = piParameterGet(thisLine, 'float fov');
                lightSources{ii}.mapname = piParameterGet(thisLine, 'string mapname');
        end
        
        % Look up rotate
        rot = find(piContains(lightSources{ii}.line, 'Rotate'));
        if rot
            [~, lightSources{ii}.rotate] = piParseVector(lightSources{ii}.line(rot));
        end
        
        % Look up translation
        trans = find(piContains(lightSources{ii}.line, 'Translate'));
        if trans
            [~, lightSources{ii}.position] = piParseVector(lightSources{ii}.line(trans));
        end
        
        % Look up scale
        scl = find(piContains(lightSources{ii}.line, 'Scale'));
        if scl
            [~, lightSources{ii}.scale] = piParseVector(lightSources{ii}.line(scl));
        end
        % Look up Material
        scl = find(piContains(lightSources{ii}.line, 'Material'));
        if scl
            matierallist = piBlockExtract_gp(lightSources{ii}.line,'blockname','Material');
            lightSources{ii}.material = matierallist;
        end
    end
end
%% Give to light
for ii = 1:numel(lightSources)
    if ~isfield(lightSources{ii}, 'name')
        lightSources{ii}.name = sprintf('#%d_Light_type:%s', ii, lightSources{ii}.type);
    end
end

if p.Results.printinfo
    disp('---------------------')
    disp('*****Light Type******')
    for ii = 1:length(lightSources)
        fprintf('%d: name: %s     type: %s\n', ii,lightSources{ii}.name,lightSources{ii}.type);
    end
    disp('*********************')
    disp('---------------------')
end


end

