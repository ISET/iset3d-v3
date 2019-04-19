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
%    roadType           - String. A string indicating the road type.
%                         Default 'city_cross_4lanes_002'. See piRoadTypes.
%    sceneType          - String. A string indicating the scene type.
%                         Default 'city'.
%    trafficflowDensity - String. A string indicating the density of the
%                         trafficflow. Default 'low'. Options are:
%                         'low', and 'high'.
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
%    04/18/19  JNM  Merge with master (Resolve conflicts) update params.

%% Initialization
p = inputParser;
p.addParameter('roadType', 'city_cross_4lanes_002');
p.addParameter('sceneType', 'city');
p.addParameter('trafficflowDensity', 'low');
p.addParameter('sessions', []);
p.addParameter('scitran', []);
p.addParameter('cloudRender', 1);
p.parse(varargin{:});

roadSession  = p.Results.session;
sceneType = p.Results.sceneType;
trafficflowDensity = p.Results.trafficflowDensity;
roadtype = p.Results.roadtype;
cloudRenderFlag = p.Results.cloudRender;
st = p.Results.scitran;
if isempty(st), st = scitran('stanfordlabs'); end

%% write out
piRoadInfo;

% load it
roadInfo = fullfile(piRootPath, 'local', 'configuration', 'roadInfo.mat');
load(roadInfo, 'roadinfo');

%%
vTypes = {'pedestrian', 'passenger', 'bus', 'truck', 'bicycle'};

switch sceneType
    case {'city', 'city2', 'city1', 'city3', 'city4', 'citymix'}
        sceneType_tmp = 'city';
        interval=[0.1, 0.5, 0.05, 0.05, 0.05];
        % if piContains(roadtype,'cross')
        %     roadname = sprintf('%s_%s_%dlanes', sceneType_tmp, ...
        %         roadtype, road.nlanes);
        % end
    case {'suburb'}
        sceneType_tmp = sceneType;
        interval=[0.05, 0.1, 0.01, 0.01, 0.03];
        % case'residential'
        %     road.nlanes = 2;
        %     interval = [0.6, 0.4, 0.02, 0.01, 0.05];
        % case 'highway'
        %     sceneType_tmp = sceneType;
        %     if randm == 1, road.nlanes = 6; else, road.nlanes = 8; end
        %     interval = [0, 0.9, 0.1, 0.5, 0];
        %     roadname = roadtype;
        % case 'bridge'
        %     sceneType_tmp = sceneType;
        %     if randm == 1,road.nlanes = 6; else, road.nlanes = 8; end
        %     interval = [0, 0.9, 0.1, 0.5, 0];
        %     roadname = sceneType;
end

%% Check the road type and downald road assets
acqs = roadSession.acquisitions.findOne(sprintf('label=%s', roadtype));

% This is the rendering recipe for the road session
% fileType_json = 'source code'; % json
% recipeFiles = st.dataFileList(roadSession, fileType_json);
% 
% fileType = 'CG Resource';
% [resourceFiles, resource_acqID] = st.dataFileList(roadSession, fileType);

% thisRoad_randm = randi(length(thisRoad), 1);
% roadname_update = thisRoad(thisRoad_randm);
% roadname_tmp = strsplit(roadname_update{1}, '.');
for ii = 1: length(roadinfo)
    % will change name from ***_construct_001 to ***_001_construct
    if piContains(roadtype, 'construct')
        roadname = strrep(roadtype, '_construct', '');
    else
        roadname = roadtype;
    end
    road.name = roadtype;
    if strcmp(roadinfo(ii).name,roadname)
        road.roadinfo = roadinfo(ii);
        break;
    end
end
% If cloudRenderFlag is true, then no resources will be downloaded
assetRecipe = piAssetDownload(roadSession, 1, 'acquisition', roadtype, ...
    'resources', ~cloudRenderFlag);

% Set the temporal sampling interval for the SUMO simulation.
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
thisR = piJson2Recipe(assetRecipe{1}.name);
% filename = strcat(sceneType, '_', roadtype);

% InputFile is used to create a cloudbucket, so we assign a predefined
% inputfile name to this Recipe.
% thisR.inputFile = fullfile(f, [filename, '.pbrt']);
% fileFolder = strrep(f, sceneType_tmp, sceneType);
% if exist(fileFolder, 'dir'), mkdir(fileFolder); end
% thisR.outputFile = fullfile(fileFolder, [filename, '.pbrt']);

data_acq = st.fw.lookup('wandell/Graphics assets/data/data/others');
thisResource = stFileSelect(acqs.files, 'type', 'CG Resource');
road.fwList = [data_acq.id, ' ', 'data.zip', ' ', acqs.id, ' ', ...
    thisResource{1}.name];
end
