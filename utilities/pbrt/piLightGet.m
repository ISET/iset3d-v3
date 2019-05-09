function lightSources = piLightGet(thisR, varargin)
% Read light sources struct from thisR
% 
% Zhenyi, SCIEN, 2019
% 
varargin = ieParamFormat(varargin);
p  = inputParser;
p.addRequired('recipe', @(x)(isa(x,'recipe')));
p.addParameter('print',true);
p.parse(thisR, varargin{:});

AttBegin = find(piContains(thisR.world,'AttributeBegin'));
AttEnd   = find(piContains(thisR.world,'AttributeEnd'));
if length(AttBegin) ==1
    lightSources{1}.line = thisR.world(AttBegin:AttEnd);
    lightSources{1}.range = [AttBegin, AttEnd];
else
    for ii = 1:length(AttBegin)
        lightSources{ii}.line = thisR.world(AttBegin(ii):AttEnd(ii));
        lightSources{ii}.range = [AttBegin(ii), AttEnd(ii)];
    end
end
if p.Results.print
    disp('---------------------')
    disp('*****Light Type******')
    for ii = 1:length(lightSources)
        lightType = lightSources{ii}.line{piContains(lightSources{ii}.line,'LightSource')};
        lightType = strsplit(lightType, ' ');
        fprintf('%d: %s \n', ii, lightType{2});
    end
end
end