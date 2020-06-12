function thisR = piTextureSet(thisR, textureIdx, param, val, varargin)
% Set the parameter of a texture (idx)
%
% Inputs
%   thisR
%   textureIdx
%   param
%   val
%
% Optional key/val
%
% Returns
%   thisR
% 
%
% See also


%% Parse inputs
param = ieParamFormat(param);
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('recipe', @(x)(isa(x, 'recipe')));
p.addRequired('textureIdx');
p.addRequired('param', @ischar);
p.addRequired('val');

p.parse(thisR, textureIdx, param, val, varargin{:});
idx = p.Results.textureIdx;

%% Conditions where we need to convert spectrum from numeric to char
if contains(param, ['spectrum', 'rgb', 'color']) && isnumeric(val)
    val = strrep(strcat('[', num2str(val), ']'), '  ', ' ');
end

%%

thisR.textures.list{idx}.(param) = val;

end