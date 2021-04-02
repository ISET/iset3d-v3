function [lightSources, lightTextRanges] = piLightGetFromText(intext, varargin)
% Read a light source struct based on the parameters in the recipe
%
% This routine only works for light sources that are exported from
% Cinema 4D.  It will not work in all cases.  We should fix that.
%
% Inputs
%   intext: Usually this is the thisR.world slot
%
% Optional key/val pairs
%   print info:   Printout the list of lights (default is true)
%
% Returns
%   lightSources:  Cell array of light source structures
%
% Zhenyi, SCIEN, 2019
% Zheng Lyu    , 2020, 2021
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
p.addRequired('intext', @iscell);
p.addParameter('printinfo',true);

p.parse(intext, varargin{:});

%%   Find the indices of the lines the .world slot that are a LightSource

AttBegin  =  find(piContains(intext,'AttributeBegin'));
AttEnd    =  find(piContains(intext,'AttributeEnd'));
arealight =  piContains(intext,'AreaLightSource');
light     =  piContains(intext,'LightSource');
lightIdx  =  find(light);   % Find which lines have LightSource on them.

%%
nLights = sum(light);
lightSources = cell(1, nLights);
lightTextRanges = cell(1, nLights);
for ii = 1:nLights
    % Find the attributes sections of the input text from the World.
    %    
    if length(AttBegin) >= ii &&...
            lightIdx(ii) > AttBegin(ii) &&...
            lightIdx(ii) < AttEnd(ii)
        lightLines  = intext(AttBegin(ii):AttEnd(ii));
        lightTextRanges{ii} = [AttBegin(ii), AttEnd(ii)];
    elseif strncmp(intext(lightIdx(ii)-1),'Transform ',10)
        light(arealight) = 0;
        lightLines = intext(lightIdx(ii)-1:lightIdx(ii));
        lightTextRanges{ii} = [lightIdx(ii)-1 lightIdx(ii)];
    else
        light(arealight) = 0;
        lightLines  = intext(lightIdx(ii));
        lightTextRanges{ii} = lightIdx(ii);
    end    
    
    % The txt below is derived from the intext stored in the
    % lightSources.line slot.
    if find(piContains(lightLines, 'AreaLightSource'))
        lightName = sprintf('#%d_Light_type:%s', ii, 'area');
        thisLightSource = piLightCreate(lightName, 'type', 'area');

        thisLine = lightLines{piContains(lightLines, 'AreaLightSource')};
        
        % Spectrum
        spec = piParameterGet(thisLine, 'L');
        thisLightSource = piLightSet(thisLightSource, 'spd val', spec);
        
        % Twosided
        twoside = piParameterGet(thisLine, 'bool twosided');
        if twoside
            if strcmp(twoside, 'false')
                thisLightSource = piLightSet(thisLightSource, 'twosided val', false);
            else
                thisLightSource = piLightSet(thisLightSource, 'twosided val', true);
            end
        end
        
        % n samples
        nSamples = piParameterGet(thisLine, 'integer nsamples');
        thisLightSource = piLightSet(thisLightSource, 'nsamples val', nSamples);
    else
        % Assign type
        lightType = lightLines{piContains(lightLines,'LightSource')};
        lightType = strsplit(lightType, ' ');
        lightType = lightType{2}(2:end-1); % Remove the quote mark
        lightName = sprintf('#%d_Light_type:%s', ii, lightType);
        thisLightSource = piLightCreate(lightName, 'type', lightType);
        
        if any(piContains(lightLines, 'CoordSysTransform "camera"'))
            thisLightSource = piLightSet(thisLightSource, 'cameracoordinate', true);
        end
        
        thisLine = lightLines{piContains(lightLines, 'LightSource')};
        switch lightType
            case 'infinite'
                % Spectrum
                spec = piParameterGet(thisLine, 'L');
                thisLightSource = piLightSet(thisLightSource, 'spd val', spec);
                
                % n samples
                nsamples = piParameterGet(thisLine, 'integer nsamples');
                thisLightSource = piLightSet(thisLightSource, 'nsamples val', nsamples);
                
                % mapname
                mapname = piParameterGet(thisLine, 'string mapname');
                thisLightSource = piLightSet(thisLightSource, 'mapname val', mapname);
                
            case 'spot'
                % Spectrum
                spec = piParameterGet(thisLine, 'I');
                thisLightSource = piLightSet(thisLightSource, 'spd val', spec);
                
                % from
                from = piParameterGet(thisLine, 'point from');
                thisLightSource = piLightSet(thisLightSource, 'from val', from);
                
                % to
                to = piParameterGet(thisLine, 'point to');
                thisLightSource = piLightSet(thisLightSource, 'to val', to);
                
                % cone angle
                coneangle = piParameterGet(thisLine, 'float coneangle');
                thisLightSource = piLightSet(thisLightSource, 'coneangle val', coneangle);
                
                % conedeltaangle
                conedeltaangle = piParameterGet(thisLine, 'float conedelataangle');
                thisLightSource = piLightSet(thisLightSource, 'conedeltaangle val', conedeltaangle);
                
            case 'point'
                % Spectrum
                spec = piParameterGet(thisLine, 'I');
                thisLightSource = piLightSet(thisLightSource, 'spd val', spec);
                
                % from
                from = piParameterGet(thisLine, 'point from');
                thisLightSource = piLightSet(thisLightSource, 'from val', from);
                
            case 'goniometric'
                % Spectrum
                spec = piParameterGet(thisLine, 'I');
                thisLightSource = piLightSet(thisLightSource, 'spd val', spec);
                
                % mapname
                mapname = piParameterGet(thisLine, 'string mapname');
                thisLightSource = piLightSet(thisLightSource, 'mapname val', mapname);
                
            case 'distant'
                % Spectrum
                spec = piParameterGet(thisLine, 'L');
                thisLightSource = piLightSet(thisLightSource, 'spd val', spec);
                
                % from
                from = piParameterGet(thisLine, 'point from');
                thisLightSource = piLightSet(thisLightSource, 'from val', from);
                
                % to
                to = piParameterGet(thisLine, 'point to');
                thisLightSource = piLightSet(thisLightSource, 'to val', to);               

            case 'projection'
                % Spectrum
                spec = piParameterGet(thisLine, 'I');
                thisLightSource = piLightSet(thisLightSource, 'spd val', spec);               

                % FOV
                fov = piParameterGet(thisLine, 'float fov');
                thisLightSource = piLightSet(thisLightSource, 'fov val', fov);
               
                % mapname
                mapname = piParameterGet(thisLine, 'string mapname');
                thisLightSource = piLightSet(thisLightSource, 'mapname val', mapname);
        end
    end
    
    % Zheng: To check with Zhenyi - do we need all rot, position and
    % ctform?
    % Parse ConcatTransform
    concatTrans = find(piContains(lightLines, 'ConcatTransform'));
    if concatTrans
        [rotation, position, ctform] = piParseConcatTransform(lightLines{concatTrans});
        thisLightSource = piLightSet(thisLightSource, 'rotation val', rotation);
        thisLightSource = piLightSet(thisLightSource, 'position val', position);
        thisLightSource = piLightSet(thisLightSource, 'ctform val', ctform);
    end
    
    % Parse rotation
    rot = find(piContains(lightLines, 'Rotate'));
    if rot
        [~, rotation] = piParseVector(lightLines(rot));
        thisLightSource = piLightSet(thisLightSource, 'rotation val', rotation);
    end
    
    % Look up translation
    trans = find(piContains(lightLines, 'Translate'));
    if trans
        [~, position] = piParseVector(lightLines(trans));
        thisLightSource = piLightSet(thisLightSource, 'position val', position);
    end
    
    % Parse shape
    shp = find(piContains(lightLines, 'Shape'));
    if shp
        shape = piParseShape(lightLines{shp});
        thisLightSource = piLightSet(thisLightSource, 'shape val', shape);
    end
    
    % Look up scale
    scl = find(piContains(lightLines, 'Scale'));
    if scl
        [~, scle] = piParseVector(lightLines(scl));
        thisLightSource = piLightSet(thisLightSource, 'scale val', scle);
    end
    
    %{
        % Look up Material (ZLY: why do we want to have it here?)
        scl = find(piContains(lightSources{ii}.line, 'Material'));
        if scl
            materiallist = piBlockExtract_gp(lightSources{ii}.line, 'blockName','Material');
            lightSources{ii}.material = materiallist;
        end
    %}
    
    lightSources{ii} = thisLightSource;
end

%%
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

