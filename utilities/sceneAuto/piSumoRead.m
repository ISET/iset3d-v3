function trafficflow = piSumoRead(varargin)
%% Parse a Sumo exported xml file, return a struct of objects with location information.
%
% We use a terminal command "sumo -c xxx.cfg --fcd-output <FILENAME>" to
% export contains location and speed along with other information for every 
% vehicle in the network at every time step.
% fcd is floating car data.
% 
% Input: there are two possible imputs.
%       'flowFile','xxx.xml': full path of .xml file.(records info. of vihecles and persons)
%       'lightFile','xxx.xml': full path of .xml file.(records info. of traffic lights)
% 
% Output: a structure with information of the objects(vehicles/people/trafficlight status) 
% in the scene.
%   
% Output structure:
%
%   scene---|---timestamp: the time stamp of traffic simulation
%           |                 |---class:vehicle/pedestrian
%           |---objects--car--|---name: sumo assigned ID
%           |             |   |---type: police/emergency/...
%           |             |   |---pos : 3d position;
%           |             |   |---speed : m/s
%           |             |   |---orientation:The angle of the vehicle in 
%           |             |               navigational standard (0-360 
%           |             |               degrees, going clockwise with 0 
%           |             |               at the 12'o clock position)
%           |             |
%           |     pedestrian--|---class:pedestrian
%           |             |   |---name: sumo assigned ID
%           |             |   |---type: []
%           |             |   |---pos : 3d position;
%           |             |   |---speed : m/s
%           |             |   |---orientation:same as 'car' class
%           |             |
%           |            bus---same as 'car' class
%           |             |
%           |             |
%           |           truck---same as 'car' class
%           |             |
%           |             |
%           |           bicycle---same as 'car' class
%           |             |
%           |             |
%           |         motorcycle---same as 'car' class
%           |
%           |           |--Name: trafficlights' name
%           |---light---|
%                       |--State: green/yellow/red
%
% Now, we have 6 classes totally.
% P.S. In Sumo, pedestrian class doesn't have 'type', type of pedestrian is empty.
% Jiaqi Zhang, VISTALAB, 2018

%% Parse input parameters
p = inputParser;
p.addParameter('flowFile',[]);
p.addParameter('lightFile',[]);

p.parse(varargin{:});
inputs = p.Results;

flowFile = inputs.flowFile;
lightFile = inputs.lightFile;

%%
if ~isempty(flowFile)
[~,~,e]= fileparts(flowFile);
if ~isequal(e,'.xml'), error('Only xml file supported');end
end
if ~isempty(lightFile)
[~,~,e]= fileparts(lightFile);
if ~isequal(e,'.xml'), error('Only xml file supported');end
end
%% Get all the information of vehicles and persons and store them as a struct
tic 
%{
% read xml file
% isetL3 and isetauto include 3rd-party functions with the same name, here
% we use the matlab build-in one.

% xmlstruct = xml2struct(flowFile);toc 
% xChildren = xmlstruct(2).Children;
% step = 0;   % count the timestamp
% obj_car = 0;
% obj_ped = 0;
% obj_bus = 0;
% obj_truck = 0;
% obj_bicycle = 0;
% obj_motorcycle = 0;
% trafficflow = struct;
% sum = size(xChildren, 2);
% 
% for i = 1:sum
%     if strcmpi(xChildren(i).Name, 'timestep') && isstruct(xChildren(i).Children)
%         step = step + 1;
%         trafficflow(step).timestamp = str2double(xChildren(i).Attributes.Value);
%         for j = 1:size(xChildren(i).Children, 2)
%             if strcmpi(xChildren(i).Children(j).Name, 'vehicle')    % transfer all the vehicles
%                 switch xChildren(i).Children(j).Attributes(7).Value
%                     case 'bus'      % transfer all the buses
%                     obj_bus = obj_bus + 1;
%                     trafficflow(step).objects.bus(obj_bus).class = 'bus';
%                     trafficflow(step).objects.bus(obj_bus).name = xChildren(i).Children(j).Attributes(2).Value;
%                     trafficflow(step).objects.bus(obj_bus).type = xChildren(i).Children(j).Attributes(7).Value;
%                     trafficflow(step).objects.bus(obj_bus).pos = [str2double(xChildren(i).Children(j).Attributes(8).Value),...
%                         0, str2double(xChildren(i).Children(j).Attributes(9).Value)];
%                     trafficflow(step).objects.bus(obj_bus).speed = str2double(xChildren(i).Children(j).Attributes(6).Value);
%                     trafficflow(step).objects.bus(obj_bus).orientation = str2double(xChildren(i).Children(j).Attributes(1).Value);
%                
%                     case 'truck'    % transfer all the trucks
%                     obj_truck = obj_truck + 1;
%                     trafficflow(step).objects.truck(obj_truck).class = 'truck';
%                     trafficflow(step).objects.truck(obj_truck).name = xChildren(i).Children(j).Attributes(2).Value;
%                     trafficflow(step).objects.truck(obj_truck).type = xChildren(i).Children(j).Attributes(7).Value;
%                     trafficflow(step).objects.truck(obj_truck).pos = [str2double(xChildren(i).Children(j).Attributes(8).Value),...
%                         0, str2double(xChildren(i).Children(j).Attributes(9).Value)];
%                     trafficflow(step).objects.truck(obj_truck).speed = str2double(xChildren(i).Children(j).Attributes(6).Value);
%                     trafficflow(step).objects.truck(obj_truck).orientation = str2double(xChildren(i).Children(j).Attributes(1).Value);
%                 
%                     case 'bicycle'  % transfer all the bicycles
%                     obj_bicycle = obj_bicycle + 1;
%                     trafficflow(step).objects.bicycle(obj_bicycle).class = 'bicycle';
%                     trafficflow(step).objects.bicycle(obj_bicycle).name = xChildren(i).Children(j).Attributes(2).Value;
%                     trafficflow(step).objects.bicycle(obj_bicycle).type = xChildren(i).Children(j).Attributes(7).Value;
%                     trafficflow(step).objects.bicycle(obj_bicycle).pos = [str2double(xChildren(i).Children(j).Attributes(8).Value),...
%                         0, str2double(xChildren(i).Children(j).Attributes(9).Value)];
%                     trafficflow(step).objects.bicycle(obj_bicycle).speed = str2double(xChildren(i).Children(j).Attributes(6).Value);
%                     trafficflow(step).objects.bicycle(obj_bicycle).orientation = str2double(xChildren(i).Children(j).Attributes(1).Value);
%                 
%                     case 'motorcycle'   % transfer all the motorcycles
%                     obj_motorcycle = obj_motorcycle + 1;
%                     trafficflow(step).objects.motorcycle(obj_motorcycle).class = 'motorcycle';
%                     trafficflow(step).objects.motorcycle(obj_motorcycle).name = xChildren(i).Children(j).Attributes(2).Value;
%                     trafficflow(step).objects.motorcycle(obj_motorcycle).type = xChildren(i).Children(j).Attributes(7).Value;
%                     trafficflow(step).objects.motorcycle(obj_motorcycle).pos = [str2double(xChildren(i).Children(j).Attributes(8).Value),...
%                         0, str2double(xChildren(i).Children(j).Attributes(9).Value)];
%                     trafficflow(step).objects.motorcycle(obj_motorcycle).speed = str2double(xChildren(i).Children(j).Attributes(6).Value);
%                     trafficflow(step).objects.motorcycle(obj_motorcycle).orientation = str2double(xChildren(i).Children(j).Attributes(1).Value);
%                     otherwise    % transfer all the cars
%                     obj_car = obj_car + 1;
%                     trafficflow(step).objects.car(obj_car).class = 'car';
%                     trafficflow(step).objects.car(obj_car).name = xChildren(i).Children(j).Attributes(2).Value;
%                     trafficflow(step).objects.car(obj_car).type = xChildren(i).Children(j).Attributes(7).Value;
%                     trafficflow(step).objects.car(obj_car).pos = [str2double(xChildren(i).Children(j).Attributes(8).Value),...
%                         0, str2double(xChildren(i).Children(j).Attributes(9).Value)];
%                     trafficflow(step).objects.car(obj_car).speed = str2double(xChildren(i).Children(j).Attributes(6).Value);
%                     trafficflow(step).objects.car(obj_car).orientation = str2double(xChildren(i).Children(j).Attributes(1).Value);
%                 end
%             
%             if strcmpi(xChildren(i).Children(j).Name, 'person')     % transfer all the pedestrian class
%                 obj_ped = obj_ped + 1;
%                 trafficflow(step).objects.pedestrian(obj_ped).class = 'pedestrian';
%                 trafficflow(step).objects.pedestrian(obj_ped).name = xChildren(i).Children(j).Attributes(3).Value;
%                 trafficflow(step).objects.pedestrian(obj_ped).type = [];
%                 trafficflow(step).objects.pedestrian(obj_ped).pos = [str2double(xChildren(i).Children(j).Attributes(7).Value),...
%                     0, str2double(xChildren(i).Children(j).Attributes(8).Value)];
%                 trafficflow(step).objects.pedestrian(obj_ped).speed = str2double(xChildren(i).Children(j).Attributes(6).Value);
%                 trafficflow(step).objects.pedestrian(obj_ped).orientation = str2double(xChildren(i).Children(j).Attributes(1).Value);
%             end
%             end
%         end
%             
%     end
%     obj_car = 0;
%     obj_ped = 0;
%     obj_bus = 0;
%     obj_truck = 0;
%     obj_bicycle = 0;
%     obj_motorcycle = 0;
% end
%}
pyScriptPath=fullfile(piRootPath,'data','sumo_input','generateJSON.py');
genJsonCmd="python "+pyScriptPath+" -f ";
outputCmd=" -o vehicleState";
sysCmd=genJsonCmd+flowFile+outputCmd;
system(sysCmd)
trafficflow=jsonread('vehicleState.json');

%% Get all the information of traffic lights and store them into the struct
tic
if ~isempty(lightFile)
    lightstruct = xml2struct(lightFile);toc
    lightChildren = lightstruct(2).Children;
    sum = size(lightChildren, 2);
    for i = 1:sum
        if strcmpi(lightChildren(i).Name, 'tlsState')
            count = str2double(lightChildren(i).Attributes(5).Value)+1;
            trafficflow(count).light(1).Name = 'trafficlight_001_1';    % the name end of 1 is light for pedestrian
            trafficflow(count).light(2).Name = 'trafficlight_002_1';
            trafficflow(count).light(3).Name = 'trafficlight_003_1';
            trafficflow(count).light(4).Name = 'trafficlight_004_1';
            trafficflow(count).light(5).Name = 'trafficlight_001_2';    % the name end of 2 is light for vehicle
            trafficflow(count).light(6).Name = 'trafficlight_002_2';
            trafficflow(count).light(7).Name = 'trafficlight_003_2';
            trafficflow(count).light(8).Name = 'trafficlight_004_2';
            phase = lightChildren(i).Attributes(2).Value;
            switch phase    % assign different states according to the phase.
                case '0'
                    trafficflow(count).light(1).State = 'green';
                    trafficflow(count).light(2).State = 'red';
                    trafficflow(count).light(3).State = 'green';
                    trafficflow(count).light(4).State = 'red';
                    trafficflow(count).light(5).State = 'green';
                    trafficflow(count).light(6).State = 'red';
                    trafficflow(count).light(7).State = 'green';
                    trafficflow(count).light(8).State = 'red';
                case '1'
                    trafficflow(count).light(1).State = 'red';
                    trafficflow(count).light(2).State = 'red';
                    trafficflow(count).light(3).State = 'red';
                    trafficflow(count).light(4).State = 'red';
                    trafficflow(count).light(5).State = 'green';
                    trafficflow(count).light(6).State = 'red';
                    trafficflow(count).light(7).State = 'green';
                    trafficflow(count).light(8).State = 'red';
                case '2'
                    trafficflow(count).light(1).State = 'red';
                    trafficflow(count).light(2).State = 'red';
                    trafficflow(count).light(3).State = 'red';
                    trafficflow(count).light(4).State = 'red';
                    trafficflow(count).light(5).State = 'yellow';
                    trafficflow(count).light(6).State = 'red';
                    trafficflow(count).light(7).State = 'yellow';
                    trafficflow(count).light(8).State = 'red';
                case '3'
                    trafficflow(count).light(1).State = 'red';
                    trafficflow(count).light(2).State = 'red';
                    trafficflow(count).light(3).State = 'red';
                    trafficflow(count).light(4).State = 'red';
                    trafficflow(count).light(5).State = 'yellow';
                    trafficflow(count).light(6).State = 'red';
                    trafficflow(count).light(7).State = 'yellow';
                    trafficflow(count).light(8).State = 'red';
                case '4'
                    trafficflow(count).light(1).State = 'red';
                    trafficflow(count).light(2).State = 'red';
                    trafficflow(count).light(3).State = 'red';
                    trafficflow(count).light(4).State = 'red';
                    trafficflow(count).light(5).State = 'yellow';
                    trafficflow(count).light(6).State = 'red';
                    trafficflow(count).light(7).State = 'yellow';
                    trafficflow(count).light(8).State = 'red';
                case '5'
                    trafficflow(count).light(1).State = 'red';
                    trafficflow(count).light(2).State = 'green';
                    trafficflow(count).light(3).State = 'red';
                    trafficflow(count).light(4).State = 'green';
                    trafficflow(count).light(5).State = 'red';
                    trafficflow(count).light(6).State = 'green';
                    trafficflow(count).light(7).State = 'red';
                    trafficflow(count).light(8).State = 'green';
                case '6'
                    trafficflow(count).light(1).State = 'red';
                    trafficflow(count).light(2).State = 'red';
                    trafficflow(count).light(3).State = 'red';
                    trafficflow(count).light(4).State = 'red';
                    trafficflow(count).light(5).State = 'red';
                    trafficflow(count).light(6).State = 'green';
                    trafficflow(count).light(7).State = 'red';
                    trafficflow(count).light(8).State = 'green';
                case '7'
                    trafficflow(count).light(1).State = 'red';
                    trafficflow(count).light(2).State = 'red';
                    trafficflow(count).light(3).State = 'red';
                    trafficflow(count).light(4).State = 'red';
                    trafficflow(count).light(5).State = 'red';
                    trafficflow(count).light(6).State = 'yellow';
                    trafficflow(count).light(7).State = 'red';
                    trafficflow(count).light(8).State = 'yellow';
                case '8'
                    trafficflow(count).light(1).State = 'red';
                    trafficflow(count).light(2).State = 'red';
                    trafficflow(count).light(3).State = 'red';
                    trafficflow(count).light(4).State = 'red';
                    trafficflow(count).light(5).State = 'red';
                    trafficflow(count).light(6).State = 'yellow';
                    trafficflow(count).light(7).State = 'red';
                    trafficflow(count).light(8).State = 'yellow';
                case '9'
                    trafficflow(count).light(1).State = 'red';
                    trafficflow(count).light(2).State = 'red';
                    trafficflow(count).light(3).State = 'red';
                    trafficflow(count).light(4).State = 'red';
                    trafficflow(count).light(5).State = 'red';
                    trafficflow(count).light(6).State = 'yellow';
                    trafficflow(count).light(7).State = 'red';
                    trafficflow(count).light(8).State = 'yellow';
            end
        end
    end
end
end
    