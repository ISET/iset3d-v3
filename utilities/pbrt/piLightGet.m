function lightSources = piLightGet(thisR, varargin)
% Read a light source struct based on the parameters in the recipe
%
% This routine only works for light sources that are exported from
% Cinema 4D.  It will not work in all cases.  We should fix that.
%
% Zhenyi, SCIEN, 2019
%

%% Parse inputs

varargin = ieParamFormat(varargin);
p  = inputParser;
p.addRequired('recipe', @(x)(isa(x,'recipe')));
p.addParameter('print',true);

p.parse(thisR, varargin{:});
lightSources = [];
%%   Find the indices of the lines the .world slot that are a LightSource

AttBegin  =  find(piContains(thisR.world,'AttributeBegin'));
AttEnd    =  find(piContains(thisR.world,'AttributeEnd'));
arealight =  piContains(thisR.world,'AreaLightSource');
light     =  piContains(thisR.world,'LightSource');
lightIdx  =  find(light);

%%
for ii = 1:length(lightIdx)
        lightSources{ii} = lightInit;
    if length(AttBegin)>=ii
        lightSources{ii}.line  = thisR.world(AttBegin(ii):AttEnd(ii));
        lightSources{ii}.range = [AttBegin(ii), AttEnd(ii)];
    else
        light(arealight)=0;
        lightSources{ii}.line  = thisR.world(lightIdx(ii));
        lightSources{ii}.range = lightIdx(ii);
    end
    
    if find(piContains(lightSources{ii}.line, 'AreaLightSource'))
        lightSources{ii}.type = 'area';
        translate = strsplit(lightSources{ii}.line{piContains(lightSources{ii}.line, 'Translate')}, ' ');
        lightSources{ii}.position = [str2double(translate{2});...
                                     str2double(translate{3});...
                                     str2double(translate{4})];
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
                txt = lightSources{ii}.line{piContains(lightSources{ii}.line, 'point from')};
            catch
                error('Cannot interpret this file.  Check for C4D compatibility.');
            end
            thisLineStr = textscan(txt, '%q');
            thisLineStr = thisLineStr{1};
            from = find(piContains(thisLineStr, 'point from'));
            lightSources{ii}.position = [piParseNumericString(thisLineStr{from+1});...
                piParseNumericString(thisLineStr{from+2});...
                piParseNumericString(thisLineStr{from+3})];
            to = find(piContains(thisLineStr, 'point to'));
            if to, lightSources{ii}.direction = [piParseNumericString(thisLineStr{to+1});...
                    piParseNumericString(thisLineStr{to+2});...
                    piParseNumericString(thisLineStr{to+3})];
            end
            coneAngle = find(piContains(thisLineStr, 'float coneangle'));
            if coneAngle,lightSources{ii}.coneangle = piParseNumericString(thisLineStr{coneAngle+1});
            end
            coneDeltaAngle =  find(piContains(thisLineStr, 'float conedelataangle'));
            if coneDeltaAngle, lightSources{ii}.conedeltaangle = piParseNumericString(thisLineStr{coneDeltaAngle+1});
            end
            spectrum  = find(piContains(thisLineStr, 'spectrum L'));
            if spectrum
                if isnan(str2double(thisLineStr{spectrum+1}))
                    thisSpectrum = thisLineStr{spectrum+1};
                else
                    thisSpectrum = piParseNumericString(thisLineStr{spectrum+1});
                end
                lightSources{ii}.spectrum = thisSpectrum;
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

function val = piParseNumericString(str)
str = strrep(str,'[','');
str = strrep(str,']','');
val = str2double(str);
end
function light = lightInit
light.type           = [];
light.spectrum       = [];
light.range          = [];
light.position       = [];
light.direction      = [];
light.conedeltaangle = [];
light.coneangle      = [];
light.line           = [];
end