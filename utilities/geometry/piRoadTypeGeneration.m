function RoadType = piRoadTypeGeneration(varargin)
% Generate a roadtype struct for Sumo TrafficFlow generation

% Zhenyi, 2018
%% 
p = inputParser;
p.addParameter('name','straight');
p.addParameter('nlane',2);

% p.addParameter('trafficlight',[]);

p.parse(varargin{:});

RoadType.name = p.Results.name;
RoadType.nlane = p.Results.nlane;

% RoadType.trafficlight = p.Results.trafficlight;
switch RoadType.name
    case 'straight'
    case 'cross'
    case 'merge'
    case 'roundabout'
    case 'right turn'
    case 'left turn'
end