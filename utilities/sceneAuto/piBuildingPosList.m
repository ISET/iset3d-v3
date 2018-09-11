%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: Random put buildings in one given region.
%
% Given the info of spare region(lenth in x axis, lenth in y axis and 
% coordinate origin) and a building list including the
% building name and size. Return a settle list, record the settle positions
% and building name.
%
% Input:
%       objects: recipe of assets.      e.g. thisR
%       biulding_list: including the building size and name

% input of subfunction:(generated according to Input)
%       lenx_tmp: lenth of spare region in x axis
%       leny_tmp: lenth of spare region in y axis
%       coordinate: origin coordinate(lower left point of building, when 
%       face to the building).
%       type: define what kind of batch the region is.
%               including:'front','left','right','back', means the building
%               area in front/left/right/back of the road.
%
% Output:
%       settle_list: record how to settle buildings on the given region,
%       including building position and building name(position refer to the
%       lower left point.
%
% Parameter:
%       offset: adjust the interval between the buildings. default is 2
%
%
% Jiaqi Zhang
% 08.08.2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [buildingPosList] = piBuildingPosList(buildingList, objects)
buildingPosList = struct;
for ii = 1:length(buildingList)
    building_list.size(ii, 1) = buildingList(ii).geometry.size.l;
    building_list.size(ii, 2) = buildingList(ii).geometry.size.w;
    building_list.name{ii} = buildingList(ii).geometry.name;
end
count = 0;
tmp = 0;
buildingPosList_tmp = struct;

for kk = 1:length(objects.assets)
    name = strsplit(objects.assets(kk).name, '_'); 
    if strcmp(name{1}, 'Plane') % if the object is a building region.
        count_before = count+1;
        type = name{2};     % extract region information
        lenx_tmp = objects.assets(kk).size.l;
        leny_tmp = objects.assets(kk).size.w;
        coordination = objects.assets(kk).position;
        y_up = coordination(2);
        coordination = [coordination(1),coordination(3)];
        [buildingPosList_tmp, count] = buildingPlan(building_list, lenx_tmp, leny_tmp, coordination, buildingPosList_tmp, count, type);
%% change the structure of the output data
        for jj = count_before:length(buildingPosList_tmp)
            buildingPosList(jj).name = buildingPosList_tmp(jj).name;
            buildingPosList(jj).position = [buildingPosList_tmp(jj).position(1),y_up,...
            buildingPosList_tmp(jj).position(2)];
            buildingPosList(jj).rotate = buildingPosList_tmp(jj).rotate;
        end
%% test algotithm. Comment this part when using.
        figure(1);hold on;xlim([-130, 130]);ylim([-30, 280]);hold on;
switch type
    case 'front'
        % test algorithm for 'front' situation

            for jj = count_before:length(buildingPosList_tmp)
                for ii = 1:size(building_list.name, 2)
                    if strcmpi(building_list.name(ii), buildingPosList_tmp(jj).name)
                        xx = building_list.size(ii, 1);
                        yy = building_list.size(ii, 2);
                    end
                end
                rectangle('Position',[buildingPosList_tmp(jj).position,xx,yy]);title('front');
            end
    case 'right'
        % test algorithm for 'right' situation

            for jj = count_before:length(buildingPosList_tmp)
                for ii = 1:size(building_list.name, 2)
                    if strcmpi(building_list.name(ii), buildingPosList_tmp(jj).name)
                        xx = building_list.size(ii, 1);
                        yy = building_list.size(ii, 2);
                    end
                end
                rectangle('Position',[buildingPosList_tmp(jj).position-[0, xx],yy,xx]);title('right');
            end
    case 'left'
        % test algorithm for 'left' situation

            for jj = count_before:length(buildingPosList_tmp)
                for ii = 1:size(building_list.name, 2)
                    if strcmpi(building_list.name(ii), buildingPosList_tmp(jj).name)
                        xx = building_list.size(ii, 1);
                        yy = building_list.size(ii, 2);
                    end
                end
                rectangle('Position',[buildingPosList_tmp(jj).position-[yy,0],yy,xx]);title('left');
            end
        % test algorithm for 'back' situation
    case 'back'
            for jj = count_before:length(buildingPosList_tmp)
                for ii = 1:size(building_list.name, 2)
                    if strcmpi(building_list.name(ii), buildingPosList_tmp(jj).name)
                        xx = building_list.size(ii, 1);
                        yy = building_list.size(ii, 2);
                    end
                end
                rectangle('Position',[buildingPosList_tmp(jj).position-[xx,yy],xx,yy]);title('back');
            end
end
tmp = tmp + 1;
disp(tmp);
%close(figure(1))

    end

end

end


function [settle_list, count] = buildingPlan(building_list, lenx_tmp, leny_tmp, coordination, settle_list, count, type)
offset = 2; % adjust the interval berween the buildings.
%% calculate the parameter in spare region.
switch type
    case 'front'
        A = [coordination(1), coordination(2)+leny_tmp];  % ABCD are 4 vertexes of spare region
        B = coordination;
        C = [coordination(1)+lenx_tmp, coordination(2)];
        D = [coordination(1)+lenx_tmp, coordination(2)+leny_tmp];
        lenx = lenx_tmp;    % lenx is the lenth of spare region in x direction
        leny = leny_tmp;    % leny is the lenth of spare region in y direction
        
    case 'right'
        A = [coordination(1), coordination(2)-leny_tmp];  % ABCD are 4 vertexes of spare region
        B = coordination;
        C = [coordination(1)+lenx_tmp, coordination(2)];
        D = [coordination(1)+lenx_tmp, coordination(2)-leny_tmp];
        leny = lenx_tmp;    % lenx is the lenth of spare region in x direction
        lenx = leny_tmp;    % leny is the lenth of spare region in y direction
        
    case 'left'
        A = [coordination(1)-lenx_tmp, coordination(2)];  % ABCD are 4 vertexes of spare region
        B = coordination;
        C = [coordination(1), coordination(2)+leny_tmp];
        D = [coordination(1)-lenx_tmp, coordination(2)+leny_tmp];
        leny = lenx_tmp;    % lenx is the lenth of spare region in x direction
        lenx = leny_tmp;    % leny is the lenth of spare region in y direction
        
    case 'back'
        A = [coordination(1), coordination(2)-leny_tmp];  % ABCD are 4 vertexes of spare region
        B = coordination;
        C = [coordination(1)-lenx_tmp, coordination(2)];
        D = [coordination(1)-lenx_tmp, coordination(2)-leny_tmp];
        lenx = lenx_tmp;    % lenx is the lenth of spare region in x direction
        leny = leny_tmp;    % leny is the lenth of spare region in y direction
end



% selectx record the index of buildings that can be put in spare region in x direction
selectx = find(building_list.size(:,1)<=lenx);
selecty = find(building_list.size(:,2)<=leny);  
sel = intersect(selectx, selecty);  % sel record the index of buildings that can be put in spare region
% disp(sel)

%% judge if there is building can be put in spare region
% if it is possiple, put it in spare region, record the position and id of
% the building in spare region. And update the new spare region, then recursion.

if ~isempty(sel)    % it is possible to put a new building on spare region
    count = count + 1;  % count the building amount
    building_idx = sel(randi([1,size(sel,1)],1,1)); % randomly get index of proper building
    id = building_list.name{building_idx}; % get name and size of the proper building
    build_x = building_list.size(building_idx, 1) + offset;
    build_y = building_list.size(building_idx, 2) + offset;
    switch type
        case 'front'
            % calculate info of spare region 1
            A1 = A; 
            B1 = B + [0, build_y];
            C1 = B + [build_x, build_y];
            D1 = [B(1)+build_x, A(2)];
            next_x1 = build_x;
            next_y1 = A1(2) - B1(2);
    
            % calculate info of spare region 2
            A2 = D1;
            B2 = B + [build_x, 0];
            C2 = C;
            D2 = D;
            next_x2 = C2(1) - B2(1);
            next_y2 = D2(2) - C2(2);
    
            % record the info of new biulding, including id, x and y coordinates
            settle_list(count).name = id;
            settle_list(count).position(1, 1) = B(1);
            settle_list(count).position(1, 2) = B(2);
            settle_list(count).rotate = 0;
    
            % recursion, spare region 1 is priority
            [settle_list, count] = buildingPlan(building_list, next_x1, next_y1, B1, settle_list, count, type);
            [settle_list, count] = buildingPlan(building_list, next_x2, next_y2, B2, settle_list, count, type);
            
        case 'right'
            A1 = A; 
            B1 = B + [0, -build_x];
            C1 = B + [build_y, -build_x];
            D1 = [B(1)+build_y, A(2)];
            next_x1 = build_y;
            next_y1 = B1(2) - A1(2);
    
            A2 = D1;
            B2 = B + [build_y, 0];
            C2 = C;
            D2 = D;
            next_x2 = C2(1) - B2(1);
            next_y2 = C2(2) - D2(2);
    
            settle_list(count).name = id;
            settle_list(count).position(1, 1) = B(1);
            settle_list(count).position(1, 2) = B(2);
            settle_list(count).rotate = 90;
            % recursion, spare region 1 is priority
            [settle_list, count] = buildingPlan(building_list, next_x1, next_y1, B1, settle_list, count, type);
            [settle_list, count] = buildingPlan(building_list, next_x2, next_y2, B2, settle_list, count, type);
            
        case 'left'
            % calculate info of spare region 1
            A1 = A; 
            B1 = B + [-build_y, 0];
            C1 = B + [-build_y, build_x];
            D1 = A + [0, build_x];
            next_x1 = B1(1) - A1(1);
            next_y1 = build_x;
    
            % calculate info of spare region 2
            A2 = D1;
            B2 = B + [0, build_x];
            C2 = C;
            D2 = D;
            next_x2 = C2(1) - D2(1);
            next_y2 = C2(2) - B2(2);
    
            % record the info of new biulding, including id, x and y coordinates
            settle_list(count).name = id;
            settle_list(count).position(1, 1) = B(1);
            settle_list(count).position(1, 2) = B(2);
            settle_list(count).rotate = 270;
    
            % recursion, spare region 1 is priority
            [settle_list, count] = buildingPlan(building_list, next_x1, next_y1, B1, settle_list, count, type);
            [settle_list, count] = buildingPlan(building_list, next_x2, next_y2, B2, settle_list, count, type);
        case 'back'
            % calculate info of spare region 1
            A1 = A; 
            B1 = B + [0, -build_y];
            C1 = B + [-build_x, -build_y];
            D1 = [B(1)-build_x, A(2)];
            next_x1 = build_x;
            next_y1 = B1(2) - A1(2);
    
            % calculate info of spare region 2
            A2 = D1;
            B2 = B + [-build_x, 0];
            C2 = C;
            D2 = D;
            next_x2 = B2(1) - C2(1);
            next_y2 = C2(2) - D2(2);
    
            % record the info of new biulding, including id, x and y coordinates
            settle_list(count).name = id;
            settle_list(count).position(1, 1) = B(1);
            settle_list(count).position(1, 2) = B(2);
            settle_list(count).rotate = 180;

            % recursion, spare region 1 is priority
            [settle_list, count] = buildingPlan(building_list, next_x1, next_y1, B1, settle_list, count, type);
            [settle_list, count] = buildingPlan(building_list, next_x2, next_y2, B2, settle_list, count, type);
            
    end
else
        % it is not possible to put a new building on spare region, sign out the recursion
end


            
end