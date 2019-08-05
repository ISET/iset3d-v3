function [thisR_scene, road] = piSceneAuto(varargin)
% Generate scene(s) for Autonomous driving scenarios using SUMO/SUSO
%
% Syntax:
%   [thisR_scene, road] = piSceneAuto([varargin])
%
% Description:
%    Assembles assets from Flywheel and SUMO/SUSO into a city or suburban
%    street scene.
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
%                          Options are 'city', & 'suburban'. Default city.
%    treeDensity         - String. A string indicating the density of trees
%                          within the scene. Default 'random'. This
%                          variable is currently unused.
%    roadType            - String. A string indicating the type of road.
%                          See piRoadTypes for more information. Options
%                          are: 'crossroad', 'straight', 'merge',
%                          'roundabout', 'right turn', and 'left turn'.
%                          Default 'crossroad'.
%    trafficeFlowDensity - String. A string indicating the traffic flow
%                          density. Options include 'low', 'medium', and
%                          'high'. Default 'medium'.
%    timeStamp           - Numeric. The integer duration of time for the
%                          scene. (Ticks in SUMO simulation). Default 50.
%    cloudRender         - Boolean. A numeric boolean indicating whether or
%                          not to render on GCP. Default 1 (true).
%    scitran             - Object. A scitran object (Flywheel.io interface
%                          object). The default is [], and then pulls an
%                          instance of 'stanfordlabs'.
%
% See Also:
%   piRoadTypes, t_piDrivingScene_demo
%

% History:
%    XX/XX/XX  ZL   Created by Zhenyi Liu
%    04/05/19  JNM  Documentation pass, add Windows support.
%    04/19/19  JNM  Merge with Master (resolve conflicts)
%    05/09/19  JNM  Merge with Master again

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
p.addParameter('timestamp', 50, @isnumeric);
p.addParameter('cloudRender', 1);
p.addParameter('scitran', [], @(x)(isa(x, 'scitran')));
p.parse(varargin{:});

sceneType = p.Results.sceneType;
treeDensity = p.Results.treeDensity;  % Not yet used.
roadType = p.Results.roadType;
trafficflowDensity = p.Results.trafficflowDensity;
trafficflow = p.Results.trafficflow;
timestamp = p.Results.timestamp;
st = p.Results.scitran;
cloudRenderFlag = p.Results.cloudRender;

%% Flywheel initialization
if isempty(st), st = scitran('stanfordlabs'); end

%% Read a road from Flywheel that we will use with SUMO
% Lookup the flywheel project with all the Graphics auto
subject = st.lookup('wandell/Graphics auto/assets');

% Find the session with the road information
roadSession = subject.sessions.findOne('label=road');

% Assemble the road
[road, thisR_road] = piRoadCreate('roadtype', roadType, ...
    'trafficflowDensity', trafficflowDensity, 'session', roadSession, ...
    'sceneType', sceneType, 'cloudRender', cloudRenderFlag, 'scitran', st);
disp('Created road')

%% Read a local traffic flow if available
% This is where SUMO is called, or the local file is read
trafficflowPath = fullfile(piRootPath, 'local', 'trafficflow', ...
    sprintf('%s_%s_trafficflow.mat', roadType, trafficflowDensity));
trafficflowFolder = fileparts(trafficflowPath);

if ~exist(trafficflowFolder, 'dir'), mkdir(trafficflowFolder); end

if ~exist(trafficflowPath, 'file')
    trafficflow = piTrafficflowGeneration(road);
    save(trafficflowPath, 'trafficflow');
    disp('Generated traffic flow using SUMO')
elseif isempty(trafficflow)
    load(trafficflowPath, 'trafficflow');
    disp('Loaded local file of traffic flow')
end

%% SUSO Simulation of urban static objects
% Put the trees and other assets into the city or suburban street
tic
tree_interval = rand(1) * 4 + 2;
if piContains(sceneType, 'city') || piContains(sceneType, 'suburb')

    susoPlaced = piSidewalkPlan(road, st, trafficflow(timestamp), ...
        'tree_interval', tree_interval);
    disp('Sidewalk generated');

    % place parked cars
    if piContains(roadType, 'parking')
        trafficflow = piParkingPlace(road, trafficflow, ...
            'parallelParking', false);
        disp('Parked cars placed')
    end

    building_listPath = fullfile(piRootPath, 'local', 'AssetLists', ...
        sprintf('%s_building_list.mat', sceneType));

    if ~exist(building_listPath, 'file')
        building_list = piAssetListCreate('class', sceneType, ...
            'scitran', st);
        disp('Created building list and saved')
        save(building_listPath, 'building_list')
    else
        load(building_listPath, 'building_list');
        disp('Loaded local file of buildings')
    end
    buildingPosList = piBuildingPosList(building_list, thisR_road);
    susoPlaced.building = piBuildingPlace(building_list, buildingPosList);

    % Put the suso placed assets on the road
    thisR_road = piAssetAddBatch(thisR_road, susoPlaced);
    toc

    % Create a file ID & name strings for Flywheel to copy selected assets
    % over to VMs.
    road = fwInfoAppend(road, susoPlaced);
    disp('Assets placed on the road');
else
    disp('No SUSO assets placed.  Not city or suburban');
end

%% Place vehicles/pedestrians from  SUMO traffic flow data on the road
[sumoPlaced, ~] = piTrafficPlace(trafficflow, 'timestamp', timestamp, ...
    'resources', ~cloudRenderFlag, 'scitran', st);

for ii = 1: length(sumoPlaced)
    thisR_scene = piAssetAddBatch(thisR_road, sumoPlaced{ii});
end
% Update recipe material library.
thisR_scene.materials.lib = piMateriallib;

% Update the material lib to the recipe.
thisR_scene.materials.lib = piMateriallib;

road = fwInfoAppend(road, sumoPlaced{1}); % mobile objects

end

function road = fwInfoAppend(road, assets)
% List the selected fwInfo str with road.fwList
%
% Syntax:
%   road = fwInfoAppend(road, assets)
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
