function thisR_scene = piSceneAuto(varargin)
%% Automatically generate scene(s) for Autonomous driving scenarios for Automotives.
p = inputParser;
varargin = ieParamFormat(varargin);
p.addParameter('sceneType','city',@ischar);
p.addParameter('treeDensity','random',@ischar);
p.addParameter('roadType','crossroad',@ischar);
p.addParameter('trafficDensity','medium',@ischar);
p.addParameter('weatherType','clear',@ischar);
p.addParameter('dayTime','day',@ischar);
p.addParameter('timestamp',50);
p.addParameter('nScene',1);

inputs = p.parse(varargin{:});

sceneType = p.Results.sceneType;
treeDensity = p.Results.treeDensity;
roadType = p.Results.roadType;
trafficDensity = p.Results.trafficDensity;
weatherType = p.Results.weatherType;
dayTime = p.Results.dayTime;
timestamp = p.Results.timestamp;
p.addParameter('scitran','',@(x)(isa(x,'scitran')));

st= p.Results.scitran;
inputs = p.parse(varargin{:});
%% flywheel init
if isempty(st), st = scitran('stanfordlabs'); end
hierarchy = st.projectHierarchy('Graphics assets');

projects     = hierarchy.project;
sessions     = hierarchy.sessions;
acquisitions = hierarchy.acquisitions;
%% Create a road
[road,thisR_road] = piRoadCreate('name',roadType,'trafficDensity',trafficDensity,...
    'sessions',sessions,'sceneType',sceneType);
% Add a skymap
thisR_road = piSkymapAdd(thisR_road,dayTime);
trafficflow = piTrafficflowGeneration(sceneType,road);
% for jj = 1:inputs.nScene
%% todo: create building and tree lib

[assetsPlaced,assetsunPlaced] = piAssetPlace(trafficflow,'timestamp',timestamp);
for ii = 1: length(assetsPlaced)
    % thisR_scene{ii} = piAssetAdd(thisR_treeAndSL,assetsPlaced{ii});
    thisR_scene{ii} = piAssetAdd(thisR_road,assetsPlaced{ii});
end
% end
end
    
    
    
    