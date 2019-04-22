function assetsplaced = piSidewalkPlan(road,st,trafficflow,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Place objects at equal intervals on sidewalks.
%
% Syntax
%
% Description:
%
% Use ABCD to represent a sidewalk
%       D---A
%       |   |
%       |   | face
%       |   |
%       |   |
%       C---B
%
% Inputs
%  road
%  st
%  trafficflow
%
% Optional key/value parameters?
%    road_type: 'cross'/
%    tree_interval:  interval distance of each tree
%    tree_offset:    distance from object to edge AB
%    tree_type:      'T' or 'S'(represents tall or short)
%    streetlight_interval: interval distance of each streetlight
%    streetlight_offset:   distance from object to edge AB
%    streetlight_type:     'T' or 'S'(represents tall or short)
%    trashcan_number: number of trash cans on each sidewalk
%    trashcan_offset: distance from object to edge AB
%    station_number:  number of stations on each sidewalk
%    station_offset:  distance from object to edge AB
% 
% Output structure: 
%    assetsplaced
%       asset----streetlightPosition_list----name
%            |                            |--position
%            |                            |--rotate
%            |                            |--size
%            |
%            |---treePosition_list-----------name
%            |                            |--position
%            |                            |--rotate
%            |                            |--size
%            |
%            |---trashcanPosition_list------...
%            |---stationPosition_list-------...
%
% by SL, 2018.8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load sidewalk information according to the type of road

sidewalk_list = road.roadinfo.sidewalk_list;

%% Parse input parameters
p = inputParser;
p.addParameter('addTree',true);
p.addParameter('tree_interval',4);
p.addParameter('tree_offset',1);
p.addParameter('tree_type','T');% used to be T
p.addParameter('streetlight_interval',12);
p.addParameter('streetlight_offset',1);
p.addParameter('streetlight_type','T');
p.addParameter('addStreetlight',true);
p.addParameter('trashcan_number',5);
p.addParameter('trashcan_offset',1);
p.addParameter('station_number',1);
p.addParameter('station_offset',sidewalk_list(1).width/2);

p.addParameter('bikerack_number',1);
p.addParameter('bikerack_offset',sidewalk_list(1).width/2);
p.addParameter('bench_number',1);
p.addParameter('bench_offset',1);
p.addParameter('billboard_number',1);
p.addParameter('billboard_offset',2);
p.addParameter('callbox_number',1);
p.addParameter('callbox_offset',3);



p.parse(varargin{:});
inputs = p.Results;

addTree = inputs.addTree;
tree_interval = inputs.tree_interval;
tree_offset = inputs.tree_offset;
tree_type = inputs.tree_type;
addStreetlight = inputs.addStreetlight;
streetlight_interval = inputs.streetlight_interval;
streetlight_offset = inputs.streetlight_offset;
streetlight_type = inputs.streetlight_type;
trashcan_number = inputs.trashcan_number;
trashcan_offset = inputs.trashcan_offset;
station_number = inputs.station_number;
station_offset = inputs.station_offset;

bikerack_number = inputs.bikerack_number;
bikerack_offset = inputs.bikerack_offset;
bench_number = inputs.bench_number;
bench_offset = inputs.bench_offset;
billboard_number = inputs.billboard_number;
billboard_offset = inputs.billboard_offset;
callbox_number = inputs.callbox_number;
callbox_offset = inputs.callbox_offset;

%% Flywheel init
if isempty(st), st = scitran('stanfordlabs');end

%% generate list of assets(not finished) from flywheel, unfinished
if (addStreetlight ==true)
    streetlight_listPath = fullfile(piRootPath,'local','AssetLists','streetlight_list.mat');
    if ~exist(streetlight_listPath,'file')
        streetlight_list = piAssetListCreate('class','others',...
                                             'subclass','streetlight_tall',...
                                             'scitran',st);
        save(streetlight_listPath,'streetlight_list')
    else
        load(streetlight_listPath,'streetlight_list');
    end
end

if (addTree ==true)
    tree_listPath = fullfile(piRootPath,'local','AssetLists','tree_list.mat');
    if ~exist(tree_listPath,'file')
        tree_list = piAssetListCreate('class','tree',...
                                      'scitran',st);
        save(tree_listPath,'tree_list');
    else
        load(tree_listPath,'tree_list');
    end
end

% offset_garbage= 0.8;
if ~(trashcan_number==0)
    trashcan_listPath = fullfile(piRootPath,'local','AssetLists','trashcan_list.mat');
    if ~exist(trashcan_listPath,'file')
        trashcan_list = piAssetListCreate('class','others',...
                                          'subclass','trashcan',...
                                          'scitran',st);
        save(trashcan_listPath,'trashcan_list');
    else
        load(trashcan_listPath,'trashcan_list');
    end
end

if ~(station_number==0)
    station_listPath = fullfile(piRootPath,'local','AssetLists','station_list.mat');
    if ~exist(station_listPath,'file')
        station_list = piAssetListCreate('class','others',...
                                         'subclass','station',...
                                         'scitran',st);
        save(station_listPath,'station_list');
    else
        load(station_listPath,'station_list');
    end
end

if ~(bench_number==0)
    bench_listPath = fullfile(piRootPath,'local','AssetLists','bench_list.mat');
    if ~exist(bench_listPath,'file')
        bench_list = piAssetListCreate('class','others',...
                                       'subclass','bench',...
                                       'scitran',st);
        save(bench_listPath,'bench_list');
    else
        load(bench_listPath,'bench_list');
    end
end

if ~(billboard_number==0)
    billboard_listPath = fullfile(piRootPath,'local','AssetLists','billboard_list.mat');
    if ~exist(billboard_listPath,'file')
        billboard_list = piAssetListCreate('class','others',...
                                           'subclass','billboard',...
                                           'scitran',st);
        save(billboard_listPath,'billboard_list');
    else
        load(billboard_listPath,'billboard_list');
    end
end

if ~(callbox_number==0)
    callbox_listPath = fullfile(piRootPath,'local','AssetLists','callbox_list.mat');
    if ~exist(callbox_listPath,'file')
        callbox_list = piAssetListCreate('class','others',...
                                         'subclass','callbox',...
                                         'scitran',st);
        save(callbox_listPath,'callbox_list');
    else
        load(callbox_listPath,'callbox_list');
    end
end

if ~(bikerack_number==0)
    bikerack_listPath = fullfile(piRootPath,'local','AssetLists','bikerack_list.mat');
    if ~exist(bikerack_listPath,'file')    
    bikerack_list = piAssetListCreate('class','others',...
                                         'subclass','bikerack',...
                                         'scitran',st);
        save(bikerack_listPath,'bikerack_list');
    else
        load(bikerack_listPath,'bikerack_list');
    end                                     
end




%% get position lists of objects
if (addTree ==true)
    treePosition = piObjectIntervalPlan(sidewalk_list, tree_list, tree_interval, tree_offset, tree_type);
else
    treePosition = struct;
end

if (addStreetlight ==true)
   streetlightPosition = piObjectIntervalPlan(sidewalk_list, streetlight_list, streetlight_interval, streetlight_offset, streetlight_type);
else
    streetlightPosition = struct;
end

if(trashcan_number==0)
    trashcanPosition=struct;
else
trashcanPosition = piObjectRandomPlan(sidewalk_list, trashcan_list, trashcan_number, trashcan_offset);
end

if(station_number==0)
    stationPosition=struct;
else
    stationPosition = piObjectRandomPlan(sidewalk_list, station_list, station_number, station_offset);
end

if(bikerack_number==0)
    bikerackPosition_list=struct;
else
    bikerackPosition_list = piObjectRandomPlan(sidewalk_list, bikerack_list, bikerack_number, bikerack_offset);
end

if(bench_number==0)
    benchPosition=struct;
else
    benchPosition = piObjectRandomPlan(sidewalk_list, bench_list, bench_number, bench_offset);
end

if(billboard_number==0)
    billboardPosition=struct;
else
    billboardPosition = piObjectRandomPlan(sidewalk_list, billboard_list, billboard_number, billboard_offset);
end

if(callbox_number==0)
    callboxPosition=struct;
else
    callboxPosition = piObjectRandomPlan(sidewalk_list, callbox_list, callbox_number, callbox_offset);
end



%% get the position list of pedstrian
if isfield(trafficflow.objects,'pedestrian')
    pedestrianPosition=struct;
    PedNum = size(trafficflow.objects.pedestrian,2);
    if PedNum~=0
        for ii = 1:length(trafficflow.objects.pedestrian)
            pedestrianPosition(ii).name = trafficflow.objects.pedestrian(ii).name;
            pedestrianPosition(ii).position = trafficflow.objects.pedestrian(ii).pos;
            pedestrianPosition(ii).size.w = 1;
            pedestrianPosition(ii).size.l = 1;
            pedestrianPosition(ii).rotate = trafficflow.objects.pedestrian(ii).orientation;
        end
    end
    [~, total_list] = piCalOverlap(pedestrianPosition, bikerackPosition_list);
else
    PedNum = 0;
    total_list = bikerackPosition_list;
end
%% consider overlap and obtain the position list of each object
[streetlightPosition_list, total_list] = piCalOverlap(streetlightPosition, total_list);
[treePosition_list, total_list]        = piCalOverlap(treePosition, total_list);
[callboxPosition_list, total_list]     = piCalOverlap(callboxPosition, total_list);
[billboardPosition_list, total_list]   = piCalOverlap(billboardPosition, total_list);

[benchPosition_list, total_list]    = piCalOverlap(benchPosition, total_list);
[trashcanPosition_list, total_list] = piCalOverlap(trashcanPosition, total_list);
[stationPosition_list, total_list]  = piCalOverlap(stationPosition, total_list);

%% Place them
if addTree ==true && ~isempty(treePosition_list)
    assetsplaced.tree = piSidewalkPlace(tree_list,treePosition_list);end
if billboard_number ~= 0 && ~isempty(billboardPosition_list)
    assetsplaced.billboard = piSidewalkPlace(billboard_list,billboardPosition_list);end
if callbox_number ~= 0 && ~isempty(callboxPosition_list)
    assetsplaced.callbox = piSidewalkPlace(callbox_list,callboxPosition_list);end
if bench_number ~=0 && ~isempty(benchPosition_list)
    assetsplaced.bench = piSidewalkPlace(bench_list,benchPosition_list);end
if trashcan_number ~=0 && ~isempty(trashcanPosition_list)
    assetsplaced.trashcan = piSidewalkPlace(trashcan_list,trashcanPosition_list);end
if station_number ~=0 && ~isempty(stationPosition_list)
    assetsplaced.station = piSidewalkPlace(station_list,stationPosition_list);end
if bikerack_number ~=0 && ~isempty(bikerackPosition_list)
    assetsplaced.bikerack = piBikerackPlace(bikerack_list,bikerackPosition_list);end % Change bikerackPlace
if addStreetlight ==true && ~isempty(streetlightPosition_list)
    assetsplaced.streetlight= piStreetlightPlace(streetlight_list,streetlightPosition_list);end
end



        




            



