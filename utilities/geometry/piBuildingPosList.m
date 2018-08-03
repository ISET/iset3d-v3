%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: Random put buildings in one given region.
%
% Given the info of spare region(lenth in x axis, lenth in y axis and 
% coordinate origin) and a building list including the
% building name and size. Return a settle list, record the settle positions
% and building name.
%
% Input:
%       biulding_list: including the building size and name
%       lenx_tmp: lenth of spare region in x axis
%       leny_tmp: lenth of spare region in y axis
%       coordinate: origin coordinate(lower left point of building, when 
%       face to the building).
%
% Output:
%       settle_list: record how to settle buildings on the given region,
%       including building position and building name(position refer to the
%       lower left point.
%
% Jiaqi Zhang
% 08.01.2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [buildingPosList] = piBuildingPosList(buildingList, lenx_tmp, leny_tmp, coordination)
% lenx_tmp = 10;
% leny_tmp = 10;
% cordination = [0, 0];
for ii=1:size(buildingList, 2)
    building_list.size(ii, 1) = buildingList(ii).geometry.size.l;
    building_list.size(ii, 2) = buildingList(ii).geometry.size.w;
    building_list.name{ii} = buildingList(ii).geometry.name;
end
y_up = coordination(2);
coordination = [coordination(1),coordination(3)];
count = 0;
buildingPosList_tmp = struct;
buildingPosList_tmp = buildingPlan(building_list, lenx_tmp, leny_tmp, coordination, buildingPosList_tmp, count);
for jj = 1:length(buildingPosList_tmp)
    buildingPosList(jj).name = buildingPosList_tmp(jj).name;
    buildingPosList(jj).position = [buildingPosList_tmp(jj).position(1),y_up,...
        buildingPosList_tmp(jj).position(2)];
end



end


function [settle_list] = buildingPlan(building_list, lenx_tmp, leny_tmp, coordination, settle_list, count)
%% calculate the parameter in spare region.
A = [coordination(1), coordination(2)+leny_tmp];  % ABCD are 4 vertexes of spare region
B = coordination;
C = [coordination(1)+lenx_tmp, coordination(2)];
D = [coordination(1)+lenx_tmp, coordination(2)+leny_tmp];
lenx = lenx_tmp;    % lenx is the lenth of spare region in x direction
leny = leny_tmp;    % leny is the lenth of spare region in y direction

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
    build_x = building_list.size(building_idx, 1);
    build_y = building_list.size(building_idx, 2);
    
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
    
    % recursion, spare region 1 is priority
    settle_list = buildingPlan(building_list, next_x1, next_y1, B1, settle_list, count);
    settle_list = buildingPlan(building_list, next_x2, next_y2, B2, settle_list, count);
else
       % it is not possible to put a new building on spare region, sign out the recursion
end
end