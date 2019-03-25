function [thisR_scene,road] = piSceneAuto(varargin)
% Generate scene(s) for Autonomous driving scenarios using SUMO/SUSO
%
% Syntax
%
% Description
%
% Inputs
%  N/A
%
% Optional key/value pairs
%   scene type
%   tree density
%   road type
%   traffice flow density (Default 'medium')
%   weather type
%   day time
%   time stamp (Default: 50)
%   nScene
%   cloud render
%   scitran   (Default is 'stanfordlabs')
%
% Returns:
%  thisR_scene - Scene recipe
%  road  - A struct containing the list of flywheel objects and road
%          information. To list this out use road.fwList;
%
% Author:
%   ZL
%
% See also
%

%% Read input parameters
p = inputParser;
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin =ieParamFormat(varargin);
end

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
p.addParameter('thisR',[]);
p.addParameter('road',[]);
p.parse(varargin{:});

sceneType      = p.Results.sceneType;
treeDensity    = p.Results.treeDensity;
roadType       = p.Results.roadType;
trafficflowDensity = p.Results.trafficflowDensity;
weatherType    = p.Results.weatherType;
timestamp      = p.Results.timestamp;
st             = p.Results.scitran;
cloudRenderFlag= p.Results.cloudRender;
thisR_road     = p.Results.thisR;
road           = p.Results.road;
%% Flywheel init

if isempty(st), st = scitran('stanfordlabs'); end


hierarchy  = st.projectHierarchy('Graphics assets');
sessions   = hierarchy.sessions;
%% Create a road using SUMO
%
% return a road contains road information and Flyweel asset list: road.fwList;
[road,thisR_road] = piRoadCreate('type',roadType,...
    'trafficflowDensity',trafficflowDensity,...
    'sessions',sessions,...
    'sceneType',sceneType,...
    'cloudRender',cloudRenderFlag,...
    'scitran',st);

roadFolder = fileparts(thisR_road.inputFile);
roadFolder = strsplit(roadFolder,'/');
roadName   = roadFolder{length(roadFolder)};
trafficflowPath   = fullfile(piRootPath,'local','trafficflow',sprintf('%s_%s_trafficflow.mat',roadName,trafficflowDensity));
trafficflowFolder = fileparts(trafficflowPath);

if ~exist(trafficflowFolder,'dir'),mkdir(trafficflowFolder);end

% This is where SUMO is called.  Or maybe the file already exists.
if ~exist(trafficflowPath,'file')
    trafficflow = piTrafficflowGeneration(road);
    save(trafficflowPath,'trafficflow');
else
    load(trafficflowPath,'trafficflow');
end

%% SUSO setting

% Uncomment when SUSO runs
%
tic
% tree_interval = rand(1)*20+5;
tree_interval = 10;
if piContains(sceneType,'city')||piContains(sceneType,'suburb')
    
     susoPlaced = piSidewalkPlan(road,st,trafficflow(timestamp),'tree_interval',tree_interval);
    % place parked cars
    if piContains(roadType,'parking')
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
    susoPlaced.building = piBuildingPlace(building_list,buildingPosList);

    
    %     save(savedSusoPlaced,'susoPlaced');
    
    %% tmp disable suso randomization
%     savedSusoPlaced = fullfile(piRootPath,'local','Assets_tmp','susoPlaced');
%     susoPlaced = load(savedSusoPlaced,'susoPlaced'); 
%     susoPlaced = susoPlaced.susoPlaced;
    %%
    % Add All placed assets
    thisR_road = piAssetAdd(thisR_road, susoPlaced);
    % thisR_scene = piAssetAdd(thisR_road, assetsPlaced);
    toc
    % create a file ID & name strings for Flywheel to copy selected assets
    % over to VMs.
    % static objects
    road = fwInfoCat(road,susoPlaced);
end

%%
% It takes about 6 mins to generate a trafficflow, so for each scene, we'd
% like generate the trafficflow only once.
roadFolder = fileparts(thisR_road.inputFile);
roadFolder = strsplit(roadFolder,'/');
roadName   = roadFolder{length(roadFolder)};
trafficflowPath   = fullfile(piRootPath,'local','trafficflow',sprintf('%s_%s_trafficflow.mat',roadName,trafficflowDensity));
trafficflowFolder = fileparts(trafficflowPath);


if ~exist(trafficflowFolder,'dir'),mkdir(trafficflowFolder);end

% This is where SUMO is called.  Or maybe the file already exists.
if ~exist(trafficflowPath,'file')
    trafficflow = piTrafficflowGeneration(road);
    save(trafficflowPath,'trafficflow');
else
    load(trafficflowPath,'trafficflow');
end
%% Place vehicles/pedestrians using the SUMO data

[sumoPlaced, ~] = piTrafficPlace(trafficflow,...
    'timestamp',timestamp,...
    'resources',~cloudRenderFlag,...
    'scitran',st);

for ii = 1: length(sumoPlaced)
    thisR_scene = piAssetAdd(thisR_road,sumoPlaced{ii});
end

road = fwInfoCat(road,sumoPlaced{1}); % mobile objects




end

% Maybe a better name and maybe attached to the relevant object.
function road = fwInfoCat(road,assets)
%% List the selected fwInfo str with road.fwList

assetFields = fieldnames(assets);
for jj = 1:length(assetFields)
    for kk = 1: length(assets.(assetFields{jj}))
        road.fwList = [road.fwList,' ',assets.(assetFields{jj})(kk).fwInfo];
    end
end

end
