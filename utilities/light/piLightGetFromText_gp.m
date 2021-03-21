function lightSources = piLightGetFromText_gp(thisR, intext, varargin)
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
    if length(AttBegin) >= ii
        lightSources{ii}.line  = intext(AttBegin(ii):AttEnd(ii));
        lightSources{ii}.range = [AttBegin(ii), AttEnd(ii)];
        lightSources{ii}.pos   = lightIdx(ii) - AttBegin(ii) + 1;
    else
        light(arealight) = 0;
        lightSources{ii}.line  = intext(lightIdx(ii));
        lightSources{ii}.range = lightIdx(ii);
    end
    
    % The txt below is derived from the intext stored in the
    % lightSources.line slot.
    if find(piContains(lightSources{ii}.line, 'AreaLightSource'))
        lightSources{ii}.type = 'area';
        txt = lightSources{ii}.line{piContains(lightSources{ii}.line, 'AreaLightSource')};
        % Remove blank to avoid error
        txt = strrep(txt,'[ ','[');
        txt = strrep(txt,' ]',']');
        thisLineStr = textscan(txt, '%q');
        thisLineStr = thisLineStr{1};
        
        % nsamples
        int = find(piContains(thisLineStr, 'integer nsamples'));
        if int, lightSources{ii}.nsamples = piParseNumericString(thisLineStr{int+1});
        end       
        
        % two sided
        twoside = find(piContains(thisLineStr, 'bool twosided'));
        if twoside
            if strcmp(thisLineStr{int+1}, 'false')
                lightSources{ii}.twosided = 0;
            else
                lightSources{ii}.twosided = 1;
            end
        end
        
        % Parse ConcatTransform
        concatTrans = find(piContains(lightSources{ii}.line, 'ConcatTransform'));
        if concatTrans
            [rot, position] = piParseConcatTransform(lightSources{ii}.line{concatTrans});
            lightSources{ii}.rotate = rot;
            lightSources{ii}.position = position;
        end
        
        % Parse shape
        shp = find(piContains(lightSources{ii}.line, 'Shape'));
        if shp
            lightSources{ii}.shape = piParseShape(lightSources{ii}.line{shp});
        end
        
        
    else
        % Assign type
        lightType = lightSources{ii}.line{piContains(lightSources{ii}.line,'LightSource')};
        lightType = strsplit(lightType, ' ');
        lightSources{ii}.type = lightType{2}(2:end-1); % Remove the quote mark
        
        try
            % Zheng Lyu to have a look here
            % If this works, then we are C4D compatible
            txt = lightSources{ii}.line{piContains(lightSources{ii}.line, 'point from') |...
                                        piContains(lightSources{ii}.line, 'infinite')};
            compatibility = 'C4D';
            lightSources{ii}.cameracoordinate = false;
        catch
            % Exception happens when we use coordinate camera to place
            % the light at the from of the camera
            if any(piContains(lightSources{ii}.line, 'CoordSysTransform "camera"'))
                lightSources{ii}.cameracoordinate = true;
                txt = lightSources{ii}.line{piContains(lightSources{ii}.line, 'LightSource')};
                compatibility = 'ISET3d';
            else
                % We are not C4D compatible.  So we do this
                error('Cannot interpret this file.  Check for C4D and ISET3d compatibility.');
            end

        end        
        
        % Remove blank to avoid error
        txt = strrep(txt,'[ ','[');
        txt = strrep(txt,' ]',']');
        %  Get the string on the LightSource line
        thisLineStr = textscan(txt, '%q');
        thisLineStr = thisLineStr{1};

        % Start checking for key words about the light source
        if ~piContains(lightSources{ii}.type, 'infinite')
            switch compatibility
                case 'C4D'
                    % Find the from and to. If C4D compatible, then the
                    % number are on three consecutive. If not, we read the
                    % from and to info from the recipe.
                    from = find(piContains(thisLineStr, 'point from'));
                    lightSources{ii}.from = [piParseNumericString(thisLineStr{from+1});...
                        piParseNumericString(thisLineStr{from+2});...
                        piParseNumericString(thisLineStr{from+3})];
                    to = find(piContains(thisLineStr, 'point to'));
                    if to
                        lightSources{ii}.to = [piParseNumericString(thisLineStr{to+1});...
                            piParseNumericString(thisLineStr{to+2});...
                            piParseNumericString(thisLineStr{to+3})];
                    end
                case 'ISET3d'
                    lightSources{ii}.from = reshape(thisR.get('from'), [1, 3]);
                    lightSources{ii}.to = reshape(thisR.get('to'), [1, 3]);
                    
            end
                        
            % Set the cone angle 
            coneAngle = find(piContains(thisLineStr, 'float coneangle'));
            if coneAngle,lightSources{ii}.coneangle = piParseNumericString(thisLineStr{coneAngle+1});
            end
            
            coneDeltaAngle =  find(piContains(thisLineStr, 'float conedelataangle'));
            if coneDeltaAngle, lightSources{ii}.conedeltaangle = piParseNumericString(thisLineStr{coneDeltaAngle+1});
            end
        else
            % Two parameters acceptable by infinite light
            mapname = find(piContains(thisLineStr, 'string mapname'));
            if mapname, lightSources{ii}.mapname = thisLineStr{mapname+1};
            end
            
            int = find(piContains(thisLineStr, 'integer nsamples'));
            if int, lightSources{ii}.nsamples = piParseNumericString(thisLineStr{int+1});
            end
        end
    end
    
    % Find common parameters
    
    % Set spectrum
    % Look for spectrum L/I
    spectrum  = find(piContains(thisLineStr, 'spectrum L')+piContains(thisLineStr, 'spectrum I'));
    if spectrum
        if isnan(str2double(thisLineStr{spectrum+1}))
            thisSpectrum = thisLineStr{spectrum+1};
        else
            thisSpectrum = piParseNumericString(thisLineStr{spectrum+1});
        end
    end

    % Look for rgb/color L/I
    rgb = find(piContains(thisLineStr, 'color L') +...
               piContains(thisLineStr, 'rgb L')+...
               piContains(thisLineStr, 'color I') +...
               piContains(thisLineStr, 'rgb I'));
    if rgb
        if isnan(str2double(thisLineStr{rgb+1}))
            thisSpectrum = str2num([thisLineStr{rgb+1}, ' ',...
                            thisLineStr{rgb+2}, ' ',...
                            thisLineStr{rgb+3}]);
        else
            thisSpectrum = piParseNumericString([thisLineStr{rgb+1}, ' ',...
                            thisLineStr{rgb+2}, ' ',...
                            thisLineStr{rgb+3}]);
        end
    end

    % Look for blackbody L, the first parameter is the temperature in
    % Kelvin, and the second giving a scale factor.
    blk = find(piContains(thisLineStr, 'blackbody L'));
    if blk
        thisSpectrum = piParseNumericString([thisLineStr{blk+1}, ' ',...
            thisLineStr{blk+2}]);
    end
    
    if exist('thisSpectrum', 'var')
        lightSources{ii}.lightspectrum = thisSpectrum;
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

%% Helper functions

function val = piParseNumericString(str)
str = strrep(str,'[','');
str = strrep(str,']','');
val = str2num(str);
end
