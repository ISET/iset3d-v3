function thisR_scene = piSceneAuto(varargin)
%% Automatically generate scene(s) for Autonomous driving scenarios for Automotives.
p = inputParser;
varargin = ieParamFormat(varargin);
p.addParameter('sceneType','city',@ischar);
p.addParameter('treeDensity','random',@ischar);
p.addParameter('roadType','crossroad',@ischar);
p.addParameter('trafficflowDensity','medium',@ischar);
p.addParameter('weatherType','clear',@ischar);
p.addParameter('dayTime','day',@ischar);
p.addParameter('timestamp',50);
p.addParameter('nScene',1);
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



%% flywheel init
if isempty(st), st = scitran('stanfordlabs'); end
hierarchy = st.projectHierarchy('Graphics assets');

projects     = hierarchy.project;
sessions     = hierarchy.sessions;
acquisitions = hierarchy.acquisitions;
%% Create a road
[road,thisR_road] = piRoadCreate('type',roadType,'trafficflowDensity',trafficflowDensity,...
    'sessions',sessions,'sceneType',sceneType,'scitran',st);
% Add a skymap
thisR_road = piSkymapAdd(thisR_road,dayTime);
trafficflowPath = fullfile(piRootPath,'local','trafficflow.mat');
if ~exist(trafficflowPath,'file')
    trafficflow = piTrafficflowGeneration(sceneType,road);
    save('trafficflow.mat','trafficflow');
    movefile('trafficflow.mat',fullfile(piRootPath,'local'));
else
    load(trafficflowPath,'-mat');
end


% for jj = 1:inputs.nScene
%% todo: create building and tree lib
asset = piSidewalkPlan(road,'addTree',false);
% Combine building/tree/streetlights place function

%% Place vehicles/pedestrians
[assetsPlaced,assetsunPlaced] = piAssetPlace(trafficflow,'timestamp',timestamp);
for ii = 1: length(assetsPlaced)
    % thisR_scene{ii} = piAssetAdd(thisR_treeAndSL,assetsPlaced{ii});
    thisR_scene{ii} = piAssetAdd(thisR_road,assetsPlaced{ii});
end
% end
end
    
    
    
    