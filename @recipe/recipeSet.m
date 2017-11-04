function recipeSet(thisR, param, val, varargin)
% Set a recipe entry
%
% 
%
% BW ISETBIO Team, 2017

p = inputParser;
p.addRequired('thisR',isequal(class(thisR),'recipe'));
p.addRequired('param',@ischar);
p.addRequired('val');

p.parse(thisR,param,val,varargin{:});

param = ieParamFormat(p.Results.param);

switch param
    case 'help'
        disp('NYI')
    case 'pixelsamples'
        thisR.sampler.pixelsamples.value = val;
    otherwise 
        error('Unknown parameter %s\n',param);
end
