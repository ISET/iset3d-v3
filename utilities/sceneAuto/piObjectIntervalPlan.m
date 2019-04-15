function [objectPosition_list] = piObjectIntervalPlan(sidewalk_list, object_list, interval, offset, type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: Place objects at equal intervals on sidewalks.
% Input:
%       sidewalk_list: include the information of each sidewalk(length, width, rotate, coordinate)
%       D----A
%       |    |
%       |    | face
%       |    |
%       |    |
%       C----B
%        For a sidewalk ABCD above, AB is the outside edge of the sidewalk.
%            length: the length of edge AB
%            width: the length of DA
%            direction: the clockwise rotating angle of sidework, base on this position.
%            coordinate: the coordinate of B.
%       object_list: generate from function piTreeListCreate() or
%       piStreetlightListCreate
%
% Optional key/value parameters?
%       interval: the interval distance of each light
%       object_type: 'T' or 'S'(represents tall or short)
%       offset: the distance from object to edge AB
%       remain_length: the length from the beginning that you want to start to place the light
%       edgeSize: since the size of tree and light is much larger than
%               their foundation, set a certain value as their size to calculate
%               overlap
%
% Output:
%       objectPosition_list: include name, position, rotate and size of each object
% by SL, 2018.8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set parameters
remain_length=randi(5);
edgeSize=0.3;

%% calculate the number of objects of each type
x = size(sidewalk_list,2);
num1=0;
num2=0;
objname_idx = strfind(object_list(1).name,'_');
objname = object_list(1).name(1:objname_idx(1)-1);
type1_name = sprintf('%s_tall',objname);
type2_name = sprintf('%s_short',objname);
for mm=1:size(object_list,2)
    for nn=1:size(object_list(mm).geometry,2)
        tmp1=strfind(object_list(mm).geometry(nn).name, type1_name);
        tmp2=strfind(object_list(mm).geometry(nn).name, type2_name);
        if (tmp1)
            num1=num1+1;
        else if(tmp2)
                num2=num2+1;
            end
        end
    end
end

%% script used for tree
if piContains(object_list(1).name,'tree')
    % generate the list of objects' position information
    count = 0;
    x = size(sidewalk_list,2);
    for jj = 1 : x
        %number of objects
        num = round((sidewalk_list(jj).length-(2*remain_length))/interval);
        % 'start_point' represents the beginning place of the object in a sidewalk
        start_point = sidewalk_list(jj).coordinate - [cos(sidewalk_list(jj).direction*pi/180)*offset, -sin(sidewalk_list(jj).direction*pi/180)*offset];
        % 'coordinate_interval' represents the coordinate interval of each object
        coordinate_interval(1,1) = (interval * sind(sidewalk_list(jj).direction));
        coordinate_interval(1,2) = (cosd(sidewalk_list(jj).direction) * interval);
        for ii = 1 : num
            count = count + 1;
            start_point = start_point + coordinate_interval;
            objectPosition_list(count).position = [start_point(1), sidewalk_list(jj).height, start_point(2)];
            objectPosition_list(count).size.w = edgeSize;
            objectPosition_list(count).size.l = edgeSize;
            objectPosition_list(count).rotate = sidewalk_list(jj).direction;
            
            % generate random number for tree_list
            randnum1 = 0; randnum2 = 0;
            if (num1==1),    randnum1=1;
            elseif (num1>1), randnum1=randi(num1);
            end
            
            if (num2==1),     randnum2=1;
            elseif (num2>1),  randnum2=randi(num2);
            end
            
            switch(type)
                case 'T'
                    objectPosition_list(count).name = sprintf('%s_tall_%03d',objname, randnum1);
                case 'S'
                    objectPosition_list(count).name = sprintf('%s_short_%03d',objname, randnum2);
                case 'Mix'
                    tmp=randi(2);
                    if (tmp==1)
                        objectPosition_list(count).name = sprintf('%s_tall_%03d',objname, randnum1);
                    else if (tmp==2)
                            objectPosition_list(count).name = sprintf('%s_short_%03d',objname, randnum2);
                        end
                    end
            end
        end
    end
end


%% script used for streetlight
if piContains(object_list(1).name,'streetlight')
    count = 0;
    x = size(sidewalk_list,2);
    for jj = 1 : x
        %number of lights
        num = round((sidewalk_list(jj).length-(2*remain_length))/interval);
        % 'start_point' represents the beginning place of the object in a sidewalk
        start_point = sidewalk_list(jj).coordinate - [cos(sidewalk_list(jj).direction*pi/180)*offset, -sin(sidewalk_list(jj).direction*pi/180)*offset];
        % 'coordinate_interval' represents the coordinate interval of each object
        coordinate_interval(1,1) = (interval * sin(sidewalk_list(jj).direction * pi/180));
        coordinate_interval(1,2) = (cos(sidewalk_list(jj).direction * pi/180) * interval);
        for ii = 1 : num
            start_point = start_point + coordinate_interval;
            for kk=1:size(object_list(mm).geometry,2)
                count = count + 1;
                objectPosition_list(count).name = object_list(mm).geometry(kk).name;
                if ~piContains(object_list(mm).geometry(kk).name,'_light')
                    objectPosition_list(count).position = [start_point(1), sidewalk_list(jj).height, start_point(2)];
                    objectPosition_list(count).rotate = sidewalk_list(jj).direction;
                    objectPosition_list(count).size.w = edgeSize;
                    objectPosition_list(count).size.l = edgeSize;
                end
                
                
            end
        end
    end
end


end

