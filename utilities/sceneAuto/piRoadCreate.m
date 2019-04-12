function [road,thisR] = piRoadCreate(varargin)
% Generate a roadtype struct for Sumo TrafficFlow generation
%
% Syntax
%
% Brief description
%
% Input
%  N/A
% Key/value pairs
%  roadtype - See piRoadTypes
%  sceneType  
%  trafficflowDensity - low or high
%  sessions
%  scitran
%  cloudRender
%
% Zhenyi, 2018

%%

% varargin = ieParamFormat(varargin);

p = inputParser;

p.addParameter('roadtype','cross');
p.addParameter('sceneType','city');
p.addParameter('trafficflowDensity','medium');
p.addParameter('session',[]);
p.addParameter('scitran',[]);
p.addParameter('cloudRender',1);
p.parse(varargin{:});

roadSession  = p.Results.session;
sceneType    = p.Results.sceneType;
trafficflowDensity = p.Results.trafficflowDensity;
roadtype        = p.Results.roadtype;
cloudRenderFlag = p.Results.cloudRender;
st = p.Results.scitran;

if isempty(st), st = scitran('stanfordlabs'); end

%% write out

piRoadInfo;

% load it
load(fullfile(piRootPath,'local','configuration','roadInfo.mat'),'roadinfo');
%%
vTypes={'pedestrian','passenger','bus','truck','bicycle'};

% randm = randi(2,1);
% randm = 1;% tmp 0915 zhenyi
switch sceneType
    case {'city','city2','city1','city3','city4','citymix'}
        sceneType_tmp = 'city';
        %         if randm ==1,road.nlanes = 4;else, road.nlanes = 6;end
        interval=[0.1,0.5,0.05,0.05,0.05];
        %         if piContains(roadtype,'cross')
        %             roadname = sprintf('%s_%s_%dlanes',sceneType_tmp,roadtype,road.nlanes);
        %         else
        roadname = roadtype;
        %         end
    case {'suburb'}
        sceneType_tmp = sceneType;
        interval=[0.05,0.1,0.01,0.01,0.03];
        roadname = roadtype;
        %     case'residential'
        %         road.nlanes = 2;
        %         interval=[0.6,0.4,0.02,0.01,0.05];
        %     case 'highway'
        %         sceneType_tmp = sceneType;
        %         if randm ==1,road.nlanes = 6;else, road.nlanes = 8;end
        %         interval=[0,0.9,0.1,0.5,0];
        %         roadname = roadtype;
        %     case 'bridge'
        %         sceneType_tmp = sceneType;
        %         if randm ==1,road.nlanes = 6;else, road.nlanes = 8;end
        %         interval=[0,0.9,0.1,0.5,0];
        %         roadname = sceneType;
end

%% Check the road type and downald road assets


acqs = roadSession.acquisitions.findOne(sprintf('label=%s',roadtype));


% This is the rendering recipe for the road session
fileType_json ='source code'; % json
recipeFiles = st.dataFileList(roadSession,fileType_json);

fileType = 'CG Resource';
[resourceFiles, resource_acqID] = st.dataFileList(roadSession, fileType);


thisRoad_randm = randi(length(thisRoad),1);
roadname_update = thisRoad(thisRoad_randm);
roadname_tmp = strsplit(roadname_update{1},'.');
for ii = 1: length(roadinfo)
    if piContains(roadname_tmp{1},'construct') % will change name from ***_construct_001 to ***_001_construct
        roadname=strrep(roadname_tmp{1},'_construct','');
    else
        roadname = roadname_tmp{1};
    end
    road.name = roadname_tmp{1};
    if strcmp(roadinfo(ii).name,roadname)
        road.roadinfo =  roadinfo(ii);
        break;
    end
end

assetRecipe = piAssetDownload(roadSession,1,...
    'acquisition',roadname_update{1},...
    'resources',~cloudRenderFlag,...
    'scitran',st);

% Set the temporal sampling interval for the SUMO simulation.  Seconds.
switch trafficflowDensity
    case 'low'
        interval=interval*0.5;
    case 'high'
        interval=interval*1.5;
    otherwise
end

% Map key/value pairs
road.vTypes=containers.Map(vTypes,interval);

%% Read out a road render recipe
thisR_tmp = jsonread(assetRecipe.name);
fds = fieldnames(thisR_tmp);
thisR = recipe;
% Assign the struct to a recipe class
for dd = 1:length(fds)
    thisR.(fds{dd})= thisR_tmp.(fds{dd});
end
[f,n,~]=fileparts(assetRecipe.name);
if piContains(sceneType,'city')
    filename = strrep(n,sceneType_tmp,sceneType);
else
    filename = strcat(sceneType,'_',n);
end
% InputFile is used to create a cloudbucket, so we assign a predefined
% inputfile name to this Recipe.
thisR.inputFile = fullfile(f,[filename,'.pbrt']);
fileFolder =  strrep(f,sceneType_tmp,sceneType);
if exist(fileFolder,'dir'),mkdir(fileFolder);end
thisR.outputFile = fullfile(fileFolder,[filename,'.pbrt']);

% Add rendering resources
%{
files = st.search('acquisition',...
% Add rendering resources
files = st.search('file',...
   'project label exact','Graphics assets',...
   'session label exact','data',...
   'acquisition label exact','others');
dataId = files{1}.parent.id;
%}
% Add rendering resources
st          = scitran('stanfordlabs');
acquisition = st.fw.lookup('wandell/Graphics assets/data/data/others');
dataId      = acquisition.id;
dataName = 'data.zip';

road.fwList = [dataId,' ',dataName,' ',...
    resource_acqID{index{thisRoad_randm}},' ',...
    resourceFiles{index{thisRoad_randm}}{1}.name];
end


