function road = piRoadCreate(varargin)
% Generate a roadtype struct for Sumo TrafficFlow generation

% Zhenyi, 2018
%% 
p = inputParser;
varargin = ieParamFormat(varargin);
p.addParameter('name','crossroad');
p.addParameter('sceneType','city');


inputs = p.parse(varargin{:});

road.name = p.Results.name;
randm = randi(2,1);
switch inputs.sceneType
case 'city'
if randm ==1,road.nlanes = 4;else road.nlanes = 8;end
case 'suburb'
if randm ==1,road.nlanes = 4;else road.nlanes = 2;end
case'residential'
 road.nlanes = 2;
case 'highway'
if randm ==1,road.nlanes = 6;else road.nlanes = 8;end 
end
% check the road type and get road assets from flywheel
switch road.name
    case 'straightroad'
        
    case 'crossroad'
        
    case 'merge'
        
    case 'roundabout'
        
    case 'right turn'
        
    case 'left turn'

    case 'T junction'
        
end