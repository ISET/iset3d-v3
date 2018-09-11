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
[road,thisR_road] = piRoadCreate('type',roadType,...
                                 'trafficflowDensity',trafficflowDensity,...
                                 'sessions',sessions,...
                                 'sceneType',sceneType,...
                                 'cloudRender',cloudRenderFlag,...
                                 'scitran',st);
% Add a skymap

% It takes about 6 mins to generate a trafficflow, so for each scene, we'd
% like generate the trafficflow only once.
trafficflowPath = fullfile(piRootPath,'local','trafficflow',sprintf('%s_trafficflow.mat',road.roadinfo.name));
trafficflowFolder = fileparts(trafficflowPath);
if ~exist(trafficflowFolder,'dir'),mkdir(trafficflowFolder);end
if ~exist(trafficflowPath,'file')
    trafficflow = piTrafficflowGeneration(road);
    save(trafficflowPath,'trafficflow');
else
    load(trafficflowPath,'trafficflow');
end


% for jj = 1:inputs.nScene
%% todo: create building and tree lib

tic
% Check how many subtypes there is in One type of scene;
% index = 1; % will give a random number
% sceneName = sprintf('%s_%d',sceneType,index);
% Create building library list
assetsPlaced = piSidewalkPlan(road,st);

building_listPath = fullfile(piRootPath,'local','AssetLists','building_list.mat');
if ~exist(building_listPath,'file')
    building_list = piAssetListCreate('class','city_2',...
        'scitran',st);
    save(building_listPath,'building_list')
else
    load(building_listPath,'building_list');
end
buildingPosList = piBuildingPosList(building_list,thisR_road);
assetsPlaced.building = piBuildingPlace(building_list,buildingPosList);


% Add All placed assets
thisR_road = piAssetAdd(thisR_road, assetsPlaced);

toc
% Download and Combine all building/tree/streetlights resouces

%% Place vehicles/pedestrians
% piTrafficPlace
[trafficPlaced,~] = piTrafficPlace(trafficflow,...
                                               'timestamp',timestamp,...
                                               'resources',~cloudRenderFlag,...
                                               'scitran',st);
for ii = 1: length(trafficPlaced)
    % thisR_scene{ii} = piAssetAdd(thisR_treeAndSL,assetsPlaced{ii});
    thisR_scene = piAssetAdd(thisR_road,trafficPlaced{ii});
end

end
    
    
    
    