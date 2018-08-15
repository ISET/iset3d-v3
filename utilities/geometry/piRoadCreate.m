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
p.addParameter('name','crossroad');
p.addParameter('sceneType','city');
p.addParameter('trafficflowDensity','medium');
p.addParameter('sessions',[]);
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

road.name = p.Results.name;
randm = randi(2,1);
switch inputs.sceneType
    case 'city'
        if randm ==1,road.nlanes = 4;else, road.nlanes = 8;end
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
for ii = 1: length(roadinfo.(road.name))
    if isequal(roadinfo.(road.name)(ii).scenetype,inputs.sceneType) &&...
            isequal(roadinfo.(road.name)(ii).nlanes,road.nlanes)
        road.roadinfo = roadinfo.(road.name)(ii);
        break;
    end
end
assetRecipe = piAssetDownload(roadSession,road.name,1,'scitran',st);

switch inputs.trafficflowDensity
    case 'low'
        interval=interval*1.2;
    case 'high'
        interval=interval*0.8;
    otherwise
end

vTypes=vTypes(2:end);
interval=interval(2:end);

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
piMaterialGroupAssign(thisR_road);
end