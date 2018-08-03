function trafficflow = piSumoRead(filename)
%% Parse a Sumo exported xml file, return a struct of objects with location information.
%
% We use a terminal command "sumo -c xxx.cfg --fcd-output <FILENAME>" to
% export contains location and speed along with other information for every 
% vehicle in the network at every time step.
% fcd is floating car data.
% 
% Input: full path of .xml file.
% 
% 
% Output: a structure with information of the objects(vehicles/people/trafficlight status) 
% in the scene.
%   
% Output structure:
%
%   scene---|---timestamp:
%           |                 |---class:vehicle/pedestrian
%           |---objects--Car--|---name: sumo assigned ID
%                         |   |---type: police/emergency/...
%                         |   |---pos : 3d position;
%                         |   |---speed : m/s
%                         |   |---orientation:The angle of the vehicle in 
%                         |               navigational standard (0-360 
%                         |               degrees, going clockwise with 0 
%                         |               at the 12'o clock position)
%                         |
%                 Pedestrian--|---name: sumo assigned ID
%                             |---type: []
%                             |---pos : 3d position;
%                             |---speed : m/s
%                             |---orientation:same as 'Car' class
%
% P.S. In Sumo, pedestrian class doesn't have 'type', type of pedestrian is empty.
% Jiaqi Zhang, VISTALAB, 2018

%%
[~,~,e]= fileparts(filename);
if ~isequal(e,'.xml'), error('Only xml file supported');end
tic  
% read xml file
% isetL3 and isetauto include 3rd-party functions with the same name, here
% we use the matlab build-in one.
xmlstruct = xml2struct(filename);toc 
xChildren = xmlstruct(2).Children;
step = 0;
obj_car = 0;
obj_ped = 0;
sum = size(xChildren, 2);

for i = 1:sum
    if strcmpi(xChildren(i).Name, 'timestep') && isstruct(xChildren(i).Children)
        step = step + 1;
        trafficflow(step).timestamp = str2double(xChildren(i).Attributes.Value);
        for j = 1:size(xChildren(i).Children, 2)
            if strcmpi(xChildren(i).Children(j).Name, 'vehicle')    % transfer all the car class
                obj_car = obj_car + 1;
                trafficflow(step).objects.Car(obj_car).class = 'Car';
                trafficflow(step).objects.Car(obj_car).name = xChildren(i).Children(j).Attributes(2).Value;
                trafficflow(step).objects.Car(obj_car).type = xChildren(i).Children(j).Attributes(7).Value;
                trafficflow(step).objects.Car(obj_car).pos = [str2double(xChildren(i).Children(j).Attributes(8).Value),...
                    0, str2double(xChildren(i).Children(j).Attributes(9).Value)];
                trafficflow(step).objects.Car(obj_car).speed = str2double(xChildren(i).Children(j).Attributes(6).Value);
                trafficflow(step).objects.Car(obj_car).orientation = str2double(xChildren(i).Children(j).Attributes(1).Value);
            end
            
            if strcmpi(xChildren(i).Children(j).Name, 'person')     % transfer all the pedestrian class
                obj_ped = obj_ped + 1;
                trafficflow(step).objects.Pedestrian(obj_ped).class = 'Pedestrian';
                trafficflow(step).objects.Pedestrian(obj_ped).name = xChildren(i).Children(j).Attributes(3).Value;
                trafficflow(step).objects.Pedestrian(obj_ped).type = [];
                trafficflow(step).objects.Pedestrian(obj_ped).pos = [str2double(xChildren(i).Children(j).Attributes(7).Value),...
                    0, str2double(xChildren(i).Children(j).Attributes(8).Value)];
                trafficflow(step).objects.Pedestrian(obj_ped).speed = str2double(xChildren(i).Children(j).Attributes(6).Value);
                trafficflow(step).objects.Pedestrian(obj_ped).orientation = str2double(xChildren(i).Children(j).Attributes(1).Value);
            end
        end
            
    end
    obj_car = 0;
    obj_ped = 0;
end
end
    