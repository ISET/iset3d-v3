function [road,thisR] = piRoadCreate(varargin)
% Generate a roadtype struct for Sumo TrafficFlow generation
%   roadname options: 'crossroad',
%                     'straight',
%                     'merge',
%                     'roundabout',
%                     'right turn',
%                     'left turn'.
%
% Zhenyi, 2018
%%
p = inputParser;
varargin = ieParamFormat(varargin);
p.addParameter('type','crossroad');
p.addParameter('sceneType','city');
p.addParameter('trafficflowDensity','medium');
p.addParameter('sessions',[]);
p.addParameter('scitran',[]);

inputs = p.parse(varargin{:});

sessions = p.Results.sessions;
sceneType = p.Results.sceneType;
trafficflowDensity = p.Results.trafficflowDensity;
roadtype = p.Results.type;

st = p.Results.scitran;

if isempty(st)
    st = scitran('stanfordlabs');
end
for ii=1:length(sessions)
    if isequal(lower(sessions{ii}.label),'road')
        roadSession = sessions{ii};
        break;
    end
end
%% write out
piRoadInfo;
% load it
load(fullfile(piRootPath,'configuration','roadInfo.mat'),'roadinfo');
%%
vTypes={'pedestrian','passenger','bus','truck'};

randm = randi(2,1);
switch sceneType
    case 'city'
%         if randm ==1,road.nlanes = 4;else, road.nlanes = 8;end
        if randm ==1,road.nlanes = 4;else, road.nlanes = 4;end % temp 08/15
        interval=[1,2,10,20];
    case 'suburb'
        if randm ==1,road.nlanes = 4;else, road.nlanes = 2;end
        interval=[3,3,20,20];
    case'residential'
        road.nlanes = 2;interval=[0.5,4,50,100];
    case 'highway'
        if randm ==1,road.nlanes = 6;else, road.nlanes = 8;end
        interval=[200,0.5,5,5];
end
% check the road type and get road assets from flywheel
for jj = 1: length(roadinfo.(roadtype))
    if isequal(roadinfo.(roadtype)(jj).scenetype,sceneType) &&...
            isequal(roadinfo.(roadtype)(jj).nlanes,road.nlanes)
        road.roadinfo = roadinfo.(roadtype)(jj);
        break;
    end
end
roadname = sprintf('%s_%s_%dlanes',roadtype,sceneType,road.nlanes);
road.name = roadname;
assetRecipe = piAssetDownload(roadSession,'road',1,'acquisition',roadname,'scitran',st);

switch trafficflowDensity
    case 'low'
        interval=interval*1.2;
    case 'high'
        interval=interval*0.8;
    otherwise
end

% Map key/value pairs
road.vTypes=containers.Map(vTypes,interval);
%% Read out a road render recipe
thisR_tmp = jsonread(assetRecipe.name);
fds = fieldnames(thisR_tmp);
thisR = recipe;
% assign the struct to a recipe class
for dd = 1:length(fds)
    thisR.(fds{dd})= thisR_tmp.(fds{dd});
end
end