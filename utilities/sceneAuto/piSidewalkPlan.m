function asset = piSidewalkPlan(road,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: Place objects at equal intervals on sidewalks.
% use ABCD to represent a sidewalk
%       D---A
%       |   |
%       |   | face
%       |   |
%       |   |
%       C---B

% Optional key/value parameters?
%       road_type: 'cross'/
%       tree_interval: the interval distance of each tree
%       tree_offset: the distance from object to edge AB
%       tree_type: 'T' or 'S'(represents tall or short)
%       streetlight_interval: the interval distance of each streetlight
%       streetlight_offset: the distance from object to edge AB
%       streetlight_type: 'T' or 'S'(represents tall or short)
%       trashcan_number: the number of trash cans on each sidewalk
%       trashcan_offset: the distance from object to edge AB
%       station_number: the number of stations on each sidewalk
%       station_offset: the distance from object to edge AB
% 
% Output structure: 
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
%% Parse input parameters
p = inputParser;
p.addParameter('addTree',true);
p.addParameter('tree_interval',4);
p.addParameter('tree_offset',1);
p.addParameter('tree_type','T');
p.addParameter('streetlight_interval',12);
p.addParameter('streetlight_offset',1);
p.addParameter('streetlight_type','T');
p.addParameter('addStreetlight',true);
p.addParameter('trashcan_number',2);
p.addParameter('trashcan_offset',1);
p.addParameter('station_number',1);
p.addParameter('station_offset',3);

p.parse(varargin{:});
inputs = p.Results;

road_type = road.roadinfo.roadtype;
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

%% load sidewalk information according to the type of road

sidewalk_list = road.roadinfo.sidewalk_list;
%% generate list of assets(not finished) from flywheel, unfinished
if (addStreetlight ==true)
streetlight_list = piStreetlightListCreate();
end

if (addTree ==true)
tree_list = piTreeListCreate();
end

% offset_garbage= 0.8;
if ~(trashcan_number==0)
trashcanlist = struct;
trashcanlist.name = 'garbage';
trashcanlist.geometry.size.l=4;
trashcanlist.geometry.size.w=5;
trashcanlist.geometry.name='garbage_001';

trashcanlist(2).name = 'garbage';
trashcanlist(2).geometry.name='garbage_002';
trashcanlist(2).geometry.size.l=3;
trashcanlist(2).geometry.size.w=5;
end
%%%%%%%%%%%%%%%%
if ~(station_number==0)
stationlist.name='station';
stationlist.geometry.name='station_001';
stationlist.geometry.size.l=3;
stationlist.geometry.size.w=1;

stationlist(2).name='station';
stationlist(2).geometry.name='station_002';
stationlist(2).geometry.size.l=4;
stationlist(2).geometry.size.w=1;
end
%% place objects on sidewalks
if (addTree ==true)
    treePosition = objectIntervalPlan(sidewalk_list, tree_list, tree_interval, tree_offset, tree_type);
else
    treePosition = struct;
end

if (addStreetlight ==true)
    asset.streetlightPosition_list = objectIntervalPlan(sidewalk_list, streetlight_list, streetlight_interval, streetlight_offset, streetlight_type);
else
    asset.streetlightPosition_list = struct;
end

if(trashcan_number==0)
    trashcanPosition=struct;
else
trashcanPosition = objectRandomPlan(sidewalk_list, trashcanlist, trashcan_number, trashcan_offset);
end

if(station_number==0)
    stationPosition=struct;
else
    stationPosition = objectRandomPlan(sidewalk_list, stationlist, station_number, station_offset);
end

%% consider overlap and obtain the position list of each object
[asset.treePosition_list, total_list] = piCalOverlap(treePosition, asset.streetlightPosition_list);
[asset.trashcanPosition_list, total_list] = piCalOverlap(trashcanPosition, total_list);
[asset.stationPosition_list, total_list] = piCalOverlap(stationPosition, total_list);



        




            



