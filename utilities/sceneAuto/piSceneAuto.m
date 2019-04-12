function [thisR_scene, road] = piSceneAuto(varargin)
% Generate scene(s) for Autonomous driving scenarios using SUMO/SUSO
%
% Syntax:
%   [thisR_scene, road] = piSceneAuto([varargin])
%
% Description:
%    Generate scene(s) for Autonomous driving scenarios using SUMO/SUSO.
%
% Inputs
%  None.
%
% Outputs:
%    thisR_scene         - Object. A scene recipe object.
%    road                - Struct. A road structure, containing the list of
%                          flywheel objects and road information. To list
%                          our, use the command road.fwList.
%
% Optional key/value pairs:
%    sceneType           - String. A string indicating the city type.
%                          Options are 'city', & 'suburb'. Default 'city'.
%    treeDensity         - String. A string indicating the density of trees
%                          within the scene. Default 'random'.
%    roadType            - String. A string indicating the type of road.
%                          Options are: 'crossroad', 'straight', 'merge',
%                          'roundabout', 'right turn', and 'left turn'.
%                          Default 'crossroad'.
%    trafficeFlowDensity - String. A string indicating the traffic flow
%                          density. Default 'medium'.
%    weatherType         - String. A string indicating the weather
%                          conditions. Default 'clear'.
%    dayTime             - String. A string indicating the time of day.
%                          Options include 'day' & 'night'. Default 'day'.
%    timeStamp           - Numeric. The duration of time for the traffic
%                          scene. Default 50.
%    nScene              - Numeric. The scene number. Default 1.
%    cloudRender         - Boolean. A numeric boolean indicating whether or
%                          not to render clouds. Default 1 (true).
%    scitran             - Object. A scitran object. The default is [], and
%                          then pulls an instance of 'stanfordlabs'.
%

% History:
%    XX/XX/XX  ZL   Created
%    04/05/19  JNM  Documentation pass, add Windows support.

%% Read input parameters
p = inputParser;
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}) | ...
                isobject(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin = ieParamFormat(varargin);
end

p.addParameter('sceneType', 'city', @ischar);
p.addParameter('treeDensity', 'random', @ischar);
p.addParameter('roadType', 'crossroad', @ischar);
p.addParameter('trafficflowDensity', 'medium', @ischar);
p.addParameter('weatherType', 'clear', @ischar);
p.addParameter('dayTime', 'day', @ischar);
p.addParameter('timestamp', 50, @isnumeric);
p.addParameter('nScene', 1, @isnumeric);
p.addParameter('cloudRender', 1);
p.addParameter('scitran', [], @(x)(isa(x, 'scitran')));
p.parse(varargin{:});

sceneType = p.Results.sceneType;
treeDensity = p.Results.treeDensity;
roadType = p.Results.roadType;
trafficflowDensity = p.Results.trafficflowDensity;
weatherType = p.Results.weatherType;
dayTime = p.Results.dayTime;
timestamp = p.Results.timestamp;
st = p.Results.scitran;
cloudRenderFlag = p.Results.cloudRender;

%% Flywheel initialization
if isempty(st), st = scitran('stanfordlabs'); end
hierarchy = st.projectHierarchy('Graphics assets');
sessions = hierarchy.sessions;

%% Create a road using SUMO
% This function call returns a road structure and a road recipe object. The
% structure contains road information and Flyweel asset list: road.fwList;
[road, thisR_road] = piRoadCreate('type', roadType, ...
    'trafficflowDensity', trafficflowDensity, 'sessions', sessions, ...
    'sceneType', sceneType, 'cloudRender', cloudRenderFlag, 'scitran', st);

% It takes about 6 mins to generate a trafficflow, so for each scene, we'd
% like generate the trafficflow only once.
roadFolder = fileparts(thisR_road.inputFile);
if ispc
    roadFolder = strsplit(roadFolder, '\');
else
    roadFolder = strsplit(roadFolder, '/');
end
roadName = roadFolder{length(roadFolder)};
trafficflowPath = fullfile(piRootPath, 'local', 'trafficflow', ...
    sprintf('%s_%s_trafficflow.mat', roadName, trafficflowDensity));
trafficflowFolder = fileparts(trafficflowPath);

if ~exist(trafficflowFolder, 'dir'), mkdir(trafficflowFolder); end

% This is where SUMO is called.  Or maybe the file already exists.
if ~exist(trafficflowPath, 'file')
    trafficflow = piTrafficflowGeneration(road);
    save(trafficflowPath, 'trafficflow');
else
    load(trafficflowPath, 'trafficflow');
end

%% SUSO setting
% %{
% Uncomment when SUSO runs
tic
tree_interval = rand(1) * 20 + 5;
if piContains(sceneType, 'city') || piContains(sceneType, 'suburb')
    susoPlaced = piSidewalkPlan(road, st, trafficflow(timestamp), ...
        'tree_interval', tree_interval);
    % place parked cars
    if piContains(roadType, 'parking')
        trafficflow = piParkingPlace(road, trafficflow);
    end
    building_listPath = fullfile(piRootPath, 'local', 'AssetLists', ...
        sprintf('%s_building_list.mat', sceneType));

    if ~exist(building_listPath, 'file')
        building_list = piAssetListCreate('class', sceneType, ...
            'scitran', st);
        save(building_listPath, 'building_list')
    else
        load(building_listPath, 'building_list');
    end
    buildingPosList = piBuildingPosList(building_list, thisR_road);
    susoPlaced.building = piBuildingPlace(building_list, buildingPosList);

    % Add All placed assets
    thisR_road = piAssetAdd(thisR_road, susoPlaced);
    % thisR_scene = piAssetAdd(thisR_road, assetsPlaced);
    toc
    % create a file ID & name strings for Flywheel to copy selected assets
    % over to VMs. The below is static objects.
    road = fwInfoCat(road, susoPlaced);
end
%}

%% Place vehicles/pedestrians using the SUMO data
[sumoPlaced, ~] = piTrafficPlace(trafficflow, 'timestamp', timestamp, ...
    'resources', ~cloudRenderFlag, 'scitran', st);
for ii = 1: length(sumoPlaced)
    thisR_scene = piAssetAdd(thisR_road, sumoPlaced{ii});
end

road = fwInfoCat(road, sumoPlaced{1}); % mobile objects

end

% Maybe a better name and maybe attached to the relevant object.
function road = fwInfoCat(road, assets)
% List the selected fwInfo str with road.fwList
%
% Syntax:
%   road = fwInfoCat(roat, assets)
%
% Description:
%   List the selected fwInfo string with road.fwList.
%
% Inputs:
%    road   - Struct. A road structure containing the flywheel assets.
%    assets - Struct. A structure containing all of the assets and their
%             positions, including streetlights and trash cans.
%
% Outputs:
%    road  - Struct. The modified road structure.
%
% Optional key/value pairs:
%    None.
%

assetFields = fieldnames(assets);
for jj = 1:length(assetFields)
    for kk = 1: length(assets.(assetFields{jj}))
        road.fwList = ...
            [road.fwList, ' ', assets.(assetFields{jj})(kk).fwInfo];
    end
end

end
