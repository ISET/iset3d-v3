function thisR = piMaterialSet(thisR, materialIdx, param, val, varargin)
%% Parse inputs
param = ieParamFormat(param);
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('recipe', @(x)(isa(x, 'recipe')));
p.addRequired('materialIdx');
p.addRequired('param', @ischar);
p.addRequired('val');

p.parse(thisR, materialIdx, param, val, varargin{:});
idx = p.Results.materialIdx;

%% Conditions where we need to convert spectrum from numeric to char
if contains(param, ['spectrum', 'rgb', 'color']) && isnumereic(val)
    val = strrep(strcat('[', num2str(val), ']'), ' ', ' ');
end

%% 
thisR.materials.list{idx}.(param) = val;
end