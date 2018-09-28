function [thisR_scene,road] = piSceneAuto(varargin)
% Automatically generate scene(s) for Autonomous driving scenarios for Automotives.
%    
%
p = inputParser;
varargin = ieParamFormat(varargin);
p.addParameter('sceneType','city',@ischar);
p.addParameter('treeDensity','random',@ischar);
p.addParameter('roadType','crossroad',@ischar);
p.addParameter('trafficflowDensity','medium',@ischar);
p.addParameter('weatherType','clear',@ischar);
p.addParameter('dayTime','day',@ischar);
p.addParameter('timestamp',50,@isnumeric);
p.addParameter('nScene',1,@isnumeric);
p.addParameter('cloudRender',1);
p.addParameter('scitran',[],@(x)(isa(x,'scitran')));
inputs = p.parse(varargin{:});

sceneType      = p.Results.sceneType;
treeDensity    = p.Results.treeDensity;
roadType       = p.Results.roadType;
trafficflowDensity = p.Results.trafficflowDensity;
weatherType    = p.Results.weatherType;
dayTime        = p.Results.dayTime;
timestamp      = p.Results.timestamp;
st             = p.Results.scitran;
cloudRenderFlag= p.Results.cloudRender;

%% flywheel init
if isempty(st), st = scitran('stanfordlabs'); end
hierarchy = st.projectHierarchy('Graphics assets');
sessions     = hierarchy.sessions;
%% Create a road
% return a road contains road information and Flyweel asset list: road.fwList;
[road,thisR_road] = piRoadCreate('type',roadType,...
                                 'trafficflowDensity',trafficflowDensity,...
                                 'sessions',sessions,...
                                 'sceneType',sceneType,...
                                 'cloudRender',cloudRenderFlag,...
                                 'scitran',st);
% Add a skymap

% It takes about 6 mins to generate a trafficflow, so for each scene, we'd
% like generate the trafficflow only once.
roadFolder = fileparts(thisR_road.inputFile);
roadFolder = strsplit(roadFolder,'/');
roadName = roadFolder{length(roadFolder)};
trafficflowPath = fullfile(piRootPath,'local','trafficflow',sprintf('%s_trafficflow.mat',roadName));
trafficflowFolder = fileparts(trafficflowPath);
if ~exist(trafficflowFolder,'dir'),mkdir(trafficflowFolder);end
if ~exist(trafficflowPath,'file')
    trafficflow = piTrafficflowGeneration(road);
    save(trafficflowPath,'trafficflow');
else
    load(trafficflowPath,'trafficflow');
end

%% todo: create building and tree lib

tic
tree_interval = rand(1)*20+2;

%% tmp
assetsPlaced = piSidewalkPlan(road,st,trafficflow(timestamp),'tree_interval',tree_interval);
% place parked cars
if contains(roadType,'parking')
    trafficflow = piParkingPlace(road, trafficflow);
end
building_listPath = fullfile(piRootPath,'local','AssetLists',sprintf('%s_building_list.mat',sceneType));

if ~exist(building_listPath,'file')
    building_list = piAssetListCreate('class',sceneType,...
        'scitran',st);
    save(building_listPath,'building_list')
else
    load(building_listPath,'building_list');
end
buildingPosList = piBuildingPosList(building_list,thisR_road);
assetsPlaced.building = piBuildingPlace(building_list,buildingPosList);
%% Cat fwInfo str with road.fwList
road = fwInfoCat(road,assetsPlaced);
%% Assign label to geometry name, so that we can have consistent names in label.txt
for jj = 1:length(assetsPlaced.building)
    if ~isequal(lower(assetsPlaced.building(jj).geometry.name),'camera') && ...
            ~contains(lower(assetsPlaced.building(jj).geometry.name),'light')
        assetsPlaced.building(jj).geometry.name = 'building';
    end
end
% Add All placed assets
thisR_road = piAssetAdd(thisR_road, assetsPlaced);
% thisR_scene = piAssetAdd(thisR_road, assetsPlaced);
toc
%% Place vehicles/pedestrians
[trafficPlaced,~] = piTrafficPlace(trafficflow,...
                                               'timestamp',timestamp,...
                                               'resources',~cloudRenderFlag,...
                                               'scitran',st);
for ii = 1: length(trafficPlaced)
    thisR_scene = piAssetAdd(thisR_road,trafficPlaced{ii});
end

road = fwInfoCat(road,trafficPlaced{1});
end
function road = fwInfoCat(road,assets)
%% cat selected fwInfo str with road.fwList
assetFields = fieldnames(assets);
for jj = 1:length(assetFields)
    for kk = 1: length(assets.(assetFields{jj}))
        road.fwList = [road.fwList,' ',assets.(assetFields{jj})(kk).fwInfo];
    end
end

end
    
    
    
    