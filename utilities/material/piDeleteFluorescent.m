function thisR = piDeleteFluorescent(thisR, matName, varargin)
% Delete the fluorescent effect on a material

%% Parse input
p = inputParser;

vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addRequired('matName',@ischar);

p.parse(thisR, matName, varargin{:});
thisR = p.parse.Results.thisR;
matName = p.parse.Results.matName;

%%
if ~isfield(thisR.materials.list, matName)
    error('Unknown material name %s\n', matName);
end

thisR.materials.list.(matName).photolumifluorescence = '';
thisR.materials.list.(matName).floatconcentration = [];
end