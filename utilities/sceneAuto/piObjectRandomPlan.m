function [objectPosition_list] = piObjectRandomPlan(sidewalk_list, ...
    object_list, object_number, offset)
% A function to randomly place objects on sidewalks
%
% Syntax:
%   [objectPosition_list] = piObjectRandomPlan(sidewalk_list, ...
%       object_list, object_number, offset)
%
% Description:
%    Use this function to randomly place specified objects on sidewalks.
%
%    Within the sidewalk_list structure (described below in Inputs
%    section), the outside edge of sidewalk ABCD, is side AB, adjacent to
%    the road. Orientation of sidewalk is as follows:
%       D----A
%       |    |
%       |    | road
%       |    |
%       |    |
%       C----B
%
% Inputs:
%    sidewalk_list          - Struct. A structure that includes the
%                             information of each sidewalk(length, width,
%                             rotate, coordinate). Some of the information
%                             within the structure is as follows:
%           length:     Numeric. The length of edge AB
%           width:      Numeric. The length of DA
%           direction:  Numeric. The clockwise rotating angle of sidework,
%                       based on this position.
%           coordinate: Numeric. The coordinate of B.
%       object_list         - generated from function
%       object_number       - the number of objects on each sidewalk
%       offset              - the distance from object to edge AB
%
% Outputs:
%       objectPosition_list - Struct. A structure including name, position,
%                             rotate and size of each object.
%
% Optional key/value pairs:
%    None.
%

% History:
%    08/XX/18  SL   Authored by SL 2018.8
%    05/06/19  JNM  Documentation pass

%% generate the list of objects' position information
x = size(sidewalk_list, 2);
count = 0;
remain_length = 9;
num = size(object_list, 2);
for jj = 1 : x
    start_point = sidewalk_list(jj).coordinate - [...
        cos(sidewalk_list(jj).direction * pi / 180) * offset, ...
        -sin(sidewalk_list(jj).direction * pi / 180) * offset];
    for ii = 1 : object_number
        %randomly choose position
        rand_length = randi(floor(sidewalk_list(jj).length - ...
            2 * remain_length)) + remain_length;
        coordinate_rand(1, 1) = (rand_length * ...
            sin(sidewalk_list(jj).direction * pi / 180));
        coordinate_rand(1, 2) = (cos(sidewalk_list(jj).direction * ...
            pi / 180) * rand_length);
        %randomly choose serial number of objects
        rand_num = randi(num);
        %got the list  of specific objects
        for kk = 1: size(object_list(rand_num).geometry, 2)
            count = count + 1;
            objectPosition_list(count).name = ...
                object_list(rand_num).geometry(kk).name;
            objectPosition_list(count).size = ...
                object_list(rand_num).geometry(kk).size;
            objectPosition_list(count).position = [...
                start_point(1) + coordinate_rand(1), ...
                sidewalk_list(jj).height, ...
                start_point(2) + coordinate_rand(2)];
            objectPosition_list(count).rotate = ...
                sidewalk_list(jj).direction;
        end
    end
end
