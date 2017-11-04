function camera = piCameraSet(camera,param,val)
% Camera set value
%
%   camera = piCameraSet(camera,param,val)
%
% BW, SCIEN Team 2017

% Programming TODO
%  Should this be a class?

%% Set up
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

      
