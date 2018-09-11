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
% varargin = ieParamFormat(varargin);
p.addParameter('type','cross');
p.addParameter('sceneType','city');
p.addParameter('trafficflowDensity','medium');
p.addParameter('sessions',[]);
p.addParameter('scitran',[]);
p.addParameter('cloudRender',1);
p.parse(varargin{:});

sessions = p.Results.sessions;
sceneType = p.Results.sceneType;
trafficflowDensity = p.Results.trafficflowDensity;
roadtype = p.Results.type;
cloudRenderFlag= p.Results.cloudRender;
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
vTypes={'pedestrian','passenger','bus','truck','bicycle'};

% randm = randi(2,1);
randm = 1;
switch sceneType
    case {'city','city2','city1','city3','city4'}
        sceneType_tmp = 'city';
%         if randm ==1,road.nlanes = 4;else, road.nlanes = 6;end
        if randm ==1,road.nlanes = 4;else, road.nlanes = 4;end % temp 08/15
        interval=[0.5,0.8,0.1,0.05,0.05];
    case 'suburb'
        sceneType_tmp = sceneType;
        if randm ==1,road.nlanes = 4;else, road.nlanes = 2;end
        interval=[0.6,0.6,0.05,0.03,0.06];
    case'residential'
        road.nlanes = 2;interval=[0.6,0.4,0.02,0.01,0.05];
    case 'highway'
        sceneType_tmp = sceneType;
        if randm ==1,road.nlanes = 6;else, road.nlanes = 8;end
        interval=[0,0.9,0.1,0.5,0];
end
% check the road type and get road assets from flywheel
roadname = sprintf('%s_%s_%dlanes',sceneType_tmp,roadtype,road.nlanes);
kk =1;
for jj = 1: length(roadinfo)
    if contains(roadinfo(jj).name,roadname) 
        thisRoad(kk) = roadinfo(jj);
        kk = kk+1;
    end
end
% thisRoad_randm = randi(length(thisRoad),1);
thisRoad_randm = 2;% tmp for test 09/07
road.roadinfo = thisRoad(thisRoad_randm);
assetRecipe = piAssetDownload(roadSession,1,...
                              'acquisition',road.roadinfo.name,...
                              'resources',~cloudRenderFlag,...
                              'scitran',st);
switch trafficflowDensity
    case 'low'
        interval=interval*0.5;
    case 'high'
        interval=interval*1.5;
    otherwise
end

% Map key/value pairs
road.vTypes=containers.Map(vTypes,interval);
%% Read out a road render recipe
thisR_tmp = jsonread(assetRecipe.name);
fds = fieldnames(thisR_tmp);
thisR = recipe;
% Assign the struct to a recipe class
for dd = 1:length(fds)
    thisR.(fds{dd})= thisR_tmp.(fds{dd});
end
[f,n,~]=fileparts(assetRecipe.name);
filename = strrep(n,sceneType_tmp,sceneType);
% InputFile is used to create a cloudbucket, so we assign a predefined 
% inputfile name to this Recipe.
thisR.inputFile = fullfile(f,[filename,'.pbrt']); 
fileFolder =  strrep(f,sceneType_tmp,sceneType);
if exist(fileFolder,'dir'),mkdir(fileFolder);end
thisR.outputFile = fullfile(fileFolder,[filename,'.pbrt']);

end














