function [objectPosition_list] = piObjectRandomPlan(sidewalk_list,object_list, object_number, offset)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: This function randomly places objects on sidewalks
%
% Input:
%       sidewalk_list: include the information of each sidewalk(length, width, rotate, coordinate)
%       D----A
%       |    |
%       |    | road
%       |    |
%       |    |
%       C----B
%        For a sidewalk ABCD above, AB is the outside edge of the sidewalk.
%            length: the length of edge AB
%            width: the length of DA
%            direction: the clockwise rotating angle of sidework, base on this position.
%            coordinate: the coordinate of B.
%       object_list: generated from function
%       object_number: the number of objects on each sidewalk
%       offset: the distance from object to edge AB
%
% Output:
%       objectPosition_list: include name, position, rotate and size of each object
% by SL, 2018.8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% generate the list of objects' position information
x = size(sidewalk_list,2);
count = 0;
remain_length=9;
num = size(object_list,2);
for jj = 1 : x
    start_point = sidewalk_list(jj).coordinate - [cos(sidewalk_list(jj).direction*pi/180)*offset, -sin(sidewalk_list(jj).direction*pi/180)*offset];
    for ii = 1 : object_number
        
        %randomly choose position
        rand_length = randi(floor(sidewalk_list(jj).length-2*remain_length))+remain_length;
        coordinate_rand(1,1) = (rand_length * sin(sidewalk_list(jj).direction * pi/180));
        coordinate_rand(1,2) = (cos(sidewalk_list(jj).direction * pi/180) * rand_length);
        %randomly choose serial number of objects
        rand_num = randi(num);
        %got the list  of specific objects
        for kk = 1: size(object_list(rand_num).geometry,2)
            count = count + 1;
            objectPosition_list(count).name     =object_list(rand_num).geometry(kk).name;
            objectPosition_list(count).size     = object_list(rand_num).geometry(kk).size;
            objectPosition_list(count).position = [start_point(1) + coordinate_rand(1), sidewalk_list(jj).height, start_point(2) + coordinate_rand(2)];
            objectPosition_list(count).rotate   = sidewalk_list(jj).direction;
        end
    end
end

