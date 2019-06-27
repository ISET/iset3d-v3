function [thisR_scene,road] = piSceneAuto(varargin)
% Generate scene(s) for Autonomous driving scenarios using SUMO/SUSO
%
% Syntax
%
% Description
%  Assembles assets from Flywheel and SUMO into a city or suburban street
%  scene.
%
% Inputs
%  N/A
%
% Optional key/value pairs
%   scene type     - 'city' or 'suburban'
%   road type      - See piRoadTypes
%   traffice flow density -  Traffic density (Default 'medium')
%   time stamp (Default: 50) - Ticks in the SUMO simulation.  Integer
%   cloud render   - Render on GCP (default, 1)
%   scitran        - Flywheel interface object (Default is 'stanfordlabs')
%   tree density   - Not currently used
%
% Returns:
%  thisR_scene - Scene recipe
%  road  - A struct containing the list of flywheel objects and road
%          information. To list this out use road.fwList;
%
% Author:
%   Zhenyi Liu
%
% See also
%   piRoadTypes, t_piDrivingScene_demo
%

%% Read input parameters

varargin =ieParamFormat(varargin);

p = inputParser;
p.addParameter('sceneType','city',@ischar);
p.addParameter('treeDensity','random',@ischar);
p.addParameter('roadType','crossroad',@ischar);
p.addParameter('trafficflow',[]);
p.addParameter('trafficflowDensity','medium',@ischar);
p.addParameter('timestamp',50,@isnumeric);
p.addParameter('scitran',[],@(x)(isa(x,'scitran')));
p.addParameter('cloudRender',1);   % Default is on the cloud

p.parse(varargin{:});

sceneType      = p.Results.sceneType;
treeDensity    = p.Results.treeDensity;  % Not yet used
roadType       = p.Results.roadType;
trafficflowDensity = p.Results.trafficflowDensity;
trafficflow    = p.Results.trafficflow;
timestamp      = p.Results.timestamp;
st             = p.Results.scitran;
cloudRenderFlag= p.Results.cloudRender;

%% Flywheel init

if isempty(st), st = scitran('stanfordlabs'); end

%% Read a road from Flywheel that we will use with SUMO

% Lookup the flywheel project with all the Graphics auto
subject = st.lookup('wandell/Graphics auto/assets');

% Find the session with the road information
roadSession = subject.sessions.findOne('label=road');

% Assemble the road
[road,thisR_road] = piRoadCreate('roadtype',roadType,...
    'trafficflowDensity',trafficflowDensity,...
    'session',roadSession,...
    'sceneType',sceneType,...
    'cloudRender',cloudRenderFlag,...
    'scitran',st);

disp('Created road')

%% Read a local traffic flow if available
% This is where SUMO is called, or the local file is read

trafficflowPath   = fullfile(piRootPath,'local',...
    'trafficflow',sprintf('%s_%s_trafficflow.mat',roadType,trafficflowDensity));
trafficflowFolder = fileparts(trafficflowPath);

if ~exist(trafficflowFolder,'dir'),mkdir(trafficflowFolder);end

if ~exist(trafficflowPath,'file')
    trafficflow = piTrafficflowGeneration(road);
    save(trafficflowPath,'trafficflow');
    disp('Generated traffic flow using SUMO')
elseif isempty(trafficflow)
    load(trafficflowPath,'trafficflow');
    disp('Loaded local file of traffic flow')
end

%% SUSO Simulation of urban static objects
% Put the trees and other assets into the city or suburban street

tic
tree_interval = rand(1)*4+2;
if piContains(sceneType,'city')|| piContains(sceneType,'suburb')
    
    susoPlaced = piSidewalkPlan(road,st,trafficflow(timestamp),'tree_interval',tree_interval);
    disp('Sidewalk generated');
    
    % place parked cars
    if piContains(roadType,'parking')
        trafficflow = piParkingPlace(road, trafficflow, 'parallelParking',false);
        disp('Parked cars placed')
    end
    building_listPath = fullfile(piRootPath,'local','AssetLists',sprintf('%s_building_list.mat',sceneType));
    
    if ~exist(building_listPath,'file')
        building_list = piAssetListCreate('class',sceneType,...
            'scitran',st);
        disp('Created building list and saved')
        save(building_listPath,'building_list')
    else
        load(building_listPath,'building_list');
        disp('Loaded local file of buildings')
    end
    buildingPosList     = piBuildingPosList(building_list,thisR_road);
    susoPlaced.building = piBuildingPlace(building_list,buildingPosList);
  
    % Put the suso placed assets on the road
    thisR_road = piAssetAddBatch(thisR_road, susoPlaced);
    toc
        
    % Create a file ID & name strings for Flywheel to copy selected assets
    % over to VMs. 
    road = fwInfoAppend(road,susoPlaced);

    disp('Assets placed on the road');
else
    disp('No SUSO assets placed.  Not city or suburban');
end

%% Place vehicles/pedestrians from  SUMO traffic flow data on the road

[sumoPlaced, ~] = piTrafficPlace(trafficflow,...
    'timestamp',timestamp,...
    'resources',~cloudRenderFlag,...
    'scitran',st);

for ii = 1: length(sumoPlaced)
    thisR_scene = piAssetAddBatch(thisR_road,sumoPlaced{ii});
end
% Update recipe material library.
thisR_scene.materials.lib = piMateriallib;

% Update the material lib to the recipe.
thisR_scene.materials.lib = piMateriallib;

road = fwInfoAppend(road,sumoPlaced{1}); % mobile objects

disp('Completed SUMO combined with SUSO');

end

%-------------------------------
%% List the selected fwInfo str with road.fwList
function road = fwInfoAppend(road,assets)

assetFields = fieldnames(assets);
for jj = 1:length(assetFields)
    for kk = 1: length(assets.(assetFields{jj}))
        road.fwList = [road.fwList,' ',assets.(assetFields{jj})(kk).fwInfo];
    end
end

end
