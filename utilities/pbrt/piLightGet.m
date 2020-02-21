function lightSources = piLightGet(thisR, varargin)
% Read a light source struct based on the parameters in the recipe
%
% This routine only works for light sources that are exported from
% Cinema 4D.  It will not work in all cases.  We should fix that.
%
% Inputs
%   thisR:  Recipe
%
% Optional key/val pairs
%   print:   Printout the list of lights
%
% Returns
%   lightSources:  Cell array of light source structures
%
% Zhenyi, SCIEN, 2019
%
% See also
%   piLightDelete, piLightAdd


%% Parse inputs

varargin = ieParamFormat(varargin);
p  = inputParser;
p.addRequired('recipe', @(x)(isa(x,'recipe')));
p.addParameter('print',true);

p.parse(thisR, varargin{:});
%%   Find the indices of the lines the .world slot that are a LightSource

AttBegin  =  find(piContains(thisR.world,'AttributeBegin'));
AttEnd    =  find(piContains(thisR.world,'AttributeEnd'));
arealight =  piContains(thisR.world,'AreaLightSource');
light     =  piContains(thisR.world,'LightSource');
lightIdx  =  find(light);   % Find which lines have LightSource on them.

%% Parse the properties of the light in each line in the lightIdx list

if isequal(sum(lightIdx),0), lightSources = [];
else,                        lightSources = cell(length(lightIdx),1);
end

for ii = 1:length(lightIdx)
    % Initialize the light structure
    lightSources{ii} = lightInit;
    
    % Find the attributes sections of the world text
    if length(AttBegin) >= ii
        lightSources{ii}.line  = thisR.world(AttBegin(ii):AttEnd(ii));
        lightSources{ii}.range = [AttBegin(ii), AttEnd(ii)];
    else
        light(arealight) = 0;
        lightSources{ii}.line  = thisR.world(lightIdx(ii));
        lightSources{ii}.range = lightIdx(ii);
    end
    
    if find(piContains(lightSources{ii}.line, 'AreaLightSource'))
        lightSources{ii}.type = 'area';
        
        translate = strsplit(lightSources{ii}.line{piContains(lightSources{ii}.line, 'Translate')}, ' ');
        if ~isempty(translate) && numel(translate) == 4
            lightSources{ii}.position = [str2double(translate{2});...
                str2double(translate{3});...
                str2double(translate{4})];
        else
            warning('No translate parameter for AreaLightSource');
        end
        
        thisLineStr = textscan(lightSources{ii}.line{piContains(lightSources{ii}.line, 'AreaLightSource')}, '%q');
        thisLineStr = thisLineStr{1};
        spectrum  = find(piContains(thisLineStr, 'spectrum L'));
        if spectrum
            if isnan(str2double(thisLineStr{spectrum+1}))
                thisSpectrum = thisLineStr{spectrum+1};
            else
                thisSpectrum = piParseNumericString(thisLineStr{spectrum+1});
            end
            lightSources{ii}.spectrum = thisSpectrum;
        end
    else
        lightType = lightSources{ii}.line{piContains(lightSources{ii}.line,'LightSource')};
        lightType = strsplit(lightType, ' ');
        lightSources{ii}.type = lightType{2};
        if ~piContains(lightSources{ii}.type, 'infinite')
            try
                % Zheng Lyu to have a look here
                % If this works, then we are C4D compatible
                txt = lightSources{ii}.line{piContains(lightSources{ii}.line, 'point from')};
                compatability = 'C4D';
            catch
                % Exception happens when we use coordinate camera to place
                % the light at the position of the camera
                if any(piContains(lightSources{ii}.line, 'CoordSysTransform "camera"'))
                    txt = lightSources{ii}.line{piContains(lightSources{ii}.line, 'LightSource')};
                    compatability = 'ISET3d';
                else
                    % We are not C4D compatible.  So we do this
                    error('Cannot interpret this file.  Check for C4D and ISET3d compatibility.');
                end
                
            end
            
            %  Get the string on the LightSource line
            thisLineStr = textscan(txt, '%q');
            thisLineStr = thisLineStr{1};
            
            switch compatability
                case 'C4D'
                    % Find the from and to positions.  If C4D compatible, then
                    % do it this way.  If not, we need another approach to get
                    % these values.
                    from = find(piContains(thisLineStr, 'point from'));
                    lightSources{ii}.position = [piParseNumericString(thisLineStr{from+1});...
                        piParseNumericString(thisLineStr{from+2});...
                        piParseNumericString(thisLineStr{from+3})];
                    lightSources{ii}.from = from;
                    to = find(piContains(thisLineStr, 'point to'));
                    if to
                        lightSources{ii}.direction = [piParseNumericString(thisLineStr{to+1});...
                            piParseNumericString(thisLineStr{to+2});...
                            piParseNumericString(thisLineStr{to+3})] - from;
                    end
                case 'ISET3d'
                    lightSources{ii}.position = reshape(thisR.get('from'), [3, 1]);
                    lightSources{ii}.direction = reshape(thisR.get('to'), [3, 1]);
                    
            end
            
            % Set the cone angle 
            coneAngle = find(piContains(thisLineStr, 'float coneangle'));
            if coneAngle,lightSources{ii}.coneangle = piParseNumericString(thisLineStr{coneAngle+1});
            end
            coneDeltaAngle =  find(piContains(thisLineStr, 'float conedelataangle'));
            if coneDeltaAngle, lightSources{ii}.conedeltaangle = piParseNumericString(thisLineStr{coneDeltaAngle+1});
            end
            
            % Adjust the spectrum
            spectrum  = find(piContains(thisLineStr, 'spectrum L') + piContains(thisLineStr, 'spectrum I'));
            if spectrum
                if isnan(str2double(thisLineStr{spectrum+1}))
                    thisSpectrum = thisLineStr{spectrum+1};
                else
                    thisSpectrum = piParseNumericString(thisLineStr{spectrum+1});
                end
                lightSources{ii}.spectrum = thisSpectrum;
            end
            
            
            % Set the light area
            if numel(thisR.lights) >= ii
                if isfield(thisR.lights{ii}, 'area')
                    lightSources{ii}.area = thisR.lights{ii}.area;
                end
                if isfield(thisR.lights{ii}, 'name')
                    lightSources{ii}.name = thisR.lights{ii}.name;
                end
            end
        end
    end
end

if p.Results.print
    disp('---------------------')
    disp('*****Light Type******')
    for ii = 1:length(lightSources)
        fprintf('%d: %s \n', ii, lightSources{ii}.type);
    end
end

end

%% Helper functions

function val = piParseNumericString(str)
str = strrep(str,'[','');
str = strrep(str,']','');
val = str2double(str);
end

function light = lightInit
light.name           = [];
% light.type           = [];
% light.spectrum       = [];
% light.range          = [];
% light.position       = [];
% light.direction      = [];
% light.conedeltaangle = [];
% light.coneangle      = [];
% light.area           = [];
% light.line           = [];
end