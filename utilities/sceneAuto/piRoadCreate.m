function [road, thisR] = piRoadCreate(varargin)
% Generate a roadtype struct for Sumo TrafficFlow generation
%
% Syntax:
%   [road, thisR] = piRoadCreate([varargin])
%
% Description:
%    Generate a roadtype struct for SUMO TrafficFlow generation. The
%    roadname options include: 'crossroad', 'straight', 'merge',
%    'roundabout', 'right turn', and 'left turn'.
%
% Inputs:
%    None.
%
% Outputs:
%    road - Struct. A structure describing the created road.
%    thisR - Object. A recipe object.
%
% Optional key/value pairs:
%    type               - String. A string indicating the road type.
%                         Default 'cross'.
%    sceneType          - String. A string indicating the scene type.
%                         Default 'city'.
%    trafficflowDensity - String. A string indicating the density of the
%                         trafficflow. Default 'medium'.
%    sessions           - Object. A sessions object. Default [] (empty).
%    scitran            - Object. A scitran object. Default [] (empty). If
%                         using the default, an instance of 'stanfordlabs'
%                         is initiated.
%    cloudRender        - Boolean. A numeric boolean indicating whether or
%                         not to render clouds.
%

% History:
%    XX/XX/18   Z   Created: Zhenyi, 2018
%    04/12/19  JNM  Documentation pass

%%
p = inputParser;
% varargin = ieParamFormat(varargin);
p.addParameter('type', 'cross');
p.addParameter('sceneType', 'city');
p.addParameter('trafficflowDensity', 'medium');
p.addParameter('sessions', []);
p.addParameter('scitran', []);
p.addParameter('cloudRender', 1);
p.parse(varargin{:});

sessions = p.Results.sessions;
sceneType = p.Results.sceneType;
trafficflowDensity = p.Results.trafficflowDensity;
roadtype = p.Results.type;
cloudRenderFlag = p.Results.cloudRender;
st = p.Results.scitran;

if isempty(st), st = scitran('stanfordlabs'); end

for ii = 1:length(sessions)
    if isequal(lower(sessions{ii}.label), 'road')
        roadSession = sessions{ii};
        break;
    end
end
%% write out
piRoadInfo;
% load it
roadInfo = fullfile(piRootPath, 'local', 'configuration', 'roadInfo.mat');
load(roadInfo, 'roadinfo');

%%
vTypes = {'pedestrian', 'passenger', 'bus', 'truck', 'bicycle'};

randm = randi(2, 1);
% randm = 2;  % tmp 0915 zhenyi
switch sceneType
    case {'city', 'city2', 'city1', 'city3', 'city4'}
        sceneType_tmp = 'city';
        if randm == 1, road.nlanes = 4; else, road.nlanes = 6; end
        interval = [0.1, 0.5, 0.05, 0.05, 0.05];
        if piContains(roadtype, 'cross')
            roadname = sprintf('%s_%s_%dlanes', sceneType_tmp, ...
                'cross', road.nlanes);
        else
            roadname = roadtype;
        end
    case {'suburb', 'suburb1'}
        sceneType_tmp = sceneType;
        interval = [0.05, 0.1, 0.01, 0.01, 0.03];
        roadname = roadtype;
    case'residential'
        road.nlanes = 2;
        interval = [0.6, 0.4, 0.02, 0.01, 0.05];
    case 'highway'
        sceneType_tmp = sceneType;
        if randm == 1, road.nlanes = 6; else, road.nlanes = 8; end
        interval = [0, 0.9, 0.1, 0.5, 0];
        roadname = roadtype;
    case 'bridge'
        sceneType_tmp = sceneType;
        if randm == 1, road.nlanes = 6; else, road.nlanes = 8; end
        interval = [0, 0.9, 0.1, 0.5, 0];
        roadname = sceneType;
end
% check the road type and get road assets from flywheel
containerID = idGet(roadSession, 'data type', 'session');
fileType_json = 'source code'; % json
[recipeFiles, ~] = st.dataFileList('session', containerID, fileType_json);
fileType = 'CG Resource';
[resourceFiles, resource_acqID] = ...
    st.dataFileList('session', containerID, fileType);
kk = 1;
for dd = 1:length(recipeFiles)
   if contains(recipeFiles{dd}{1}.name, roadname)
       thisRoad{kk} = recipeFiles{dd}{1}.name;
       index{kk} = dd;
       kk = kk + 1;
   end
end
thisRoad_randm = randi(length(thisRoad), 1);
roadname_update = thisRoad(thisRoad_randm);
roadname_tmp = strsplit(roadname_update{1}, '.');
for ii = 1: length(roadinfo)
    % will change name from ***_construct_001 to ***_001_construct
    if piContains(roadname_tmp{1}, 'construct')
        roadname = strrep(roadname_tmp{1}, '_construct', '');
    else
        roadname = roadname_tmp{1};
    end
    road.name = roadname_tmp{1};
    if strcmp(roadinfo(ii).name, roadname)
       road.roadinfo = roadinfo(ii);
       break;
    end
end
assetRecipe = piAssetDownload(roadSession, 1, ...
    'acquisition', roadname_update{1}, 'resources', ~cloudRenderFlag, ...
    'scitran', st);

switch trafficflowDensity
    case 'low'
        interval = interval * 0.5;
    case 'high'
        interval = interval * 1.5;
    otherwise
end

% Map key/value pairs
road.vTypes = containers.Map(vTypes, interval);

%% Read out a road render recipe
thisR_tmp = jsonread(assetRecipe.name);
fds = fieldnames(thisR_tmp);
thisR = recipe;

% Assign the struct to a recipe class
for dd = 1:length(fds)
    thisR.(fds{dd}) = thisR_tmp.(fds{dd});
end
[f, n, ~] = fileparts(assetRecipe.name);
if piContains(sceneType, 'city')
    filename = strrep(n, sceneType_tmp, sceneType);
else
    filename = strcat(sceneType, '_', n);
end

% InputFile is used to create a cloudbucket, so we assign a predefined
% inputfile name to this Recipe.
thisR.inputFile = fullfile(f, [filename, '.pbrt']);
fileFolder = strrep(f, sceneType_tmp, sceneType);
if exist(fileFolder, 'dir'), mkdir(fileFolder); end
thisR.outputFile = fullfile(fileFolder, [filename, '.pbrt']);

% Add rendering resources
%{
files = st.search('acquisition', ...
% Add rendering resources
files = st.search('file', 'project label exact', 'Graphics assets', ...
   'session label exact', 'data', 'acquisition label exact', 'others');
dataId = files{1}.parent.id;
%}
% Add rendering resources
st = scitran('stanfordlabs');
acquisition = st.fw.lookup('wandell/Graphics assets/data/others');
dataId = acquisition.id;
dataName = 'data.zip';

road.fwList = [dataId, ' ', dataName, ' ', ...
    resource_acqID{index{thisRoad_randm}}, ' ', ...
    resourceFiles{index{thisRoad_randm}}{1}.name];
end
