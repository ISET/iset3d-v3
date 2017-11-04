function camera = piCameraSet(camera,param,val)
% Deprecated - using recipeSet() instead.
% 
% I left this here because we might call this from recipeSet() for the camera
% types.  We will see.
%
%   camera = piCameraSet(camera,param,val)
%
% BW, SCIEN Team 2017

% Programming TODO
%  Should this be a class?

%% Parameter set up

p = inputParser;
p.addRequired('camera',@isstruct);
p.addRequired('param',@ischar);
p.addRequired('val');

p.parse(camera,param,val);

param = ieParamFormat(param);

%% Act

switch param
    case ''
    otherwise
        error('Unknown parameter %s\n');
end

end

      
