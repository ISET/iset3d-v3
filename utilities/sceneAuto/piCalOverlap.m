function [remain_list, total_list] = piCalOverlap(delete_list, total_list)
% Determine if there is object overlap
%
% Syntax:
%   [remain_list, total_list] = piCalOverlap(delete_list, total_list)
%
% Description:
%    Decide whether objects overlap, delete objects in delet_list that are
%    intersect with objects in total_list.
%
% Inputs:
%    delete_list - Array. The list of structures to be deleted if there is
%                  any overlap.
%    total_list  - Array. The list of all of the structures.
%
% Outputs:
%    remain_list: consists objects in delete_list that don't overlap
%         objects in total_list.
%         total_list: objects in original total_list & objects in
%         remain_list.

% History:
%    08/XX/18  SL   Created by SL 2018.8
%    04/11/19  JNM  DOcumentation pass

if isfield(delete_list, 'name') && isfield(total_list, 'name')
    count_total = size(total_list, 2);
    count_remain = 0;
    for jj = 1:size(delete_list, 2)
        TF = zeros(2, 2);
        TF = piCalOverlap1(delete_list(jj), total_list);
        if TF(1, 2) == 0 % no overlap
            count_remain = count_remain + 1;
            count_total = count_total + 1;
            remain_list(count_remain) = delete_list(jj);
            total_list(count_total) = delete_list(jj);
        end
    end
    if count_remain == 0, remain_list = []; end

end
if isfield(delete_list, 'name') == 1 && isfield(total_list, 'name') == 0
    remain_list = delete_list;
    total_list = delete_list;
end
if isfield(delete_list, 'name') == 0 && isfield(total_list, 'name') == 1
    remain_list = [];
    total_list = total_list;
end
if isfield(delete_list, 'name') == 0 && isfield(total_list, 'name') == 0
    remain_list = [];
    total_list = [];
end

end

function TF = piCalOverlap1(delete_obj, total_list)
%  Calculate overlap from within the provided lists
%
% Syntax:
%   TF = piCalOverlap1(delete_obj, total_list)
%
% Description:
%    Using the provided information, calculate whether or not there is
%    overlap between the lists.
%
% Inputs:
%    delete_obj - Struct. A structure with all of the objects to be deleted
%    total_list - Struct. A structure with all of the objects in the set.
%
% Outputs:
%    TF         - Matrix. a 2x2 matrix containing whether or not there is
%                 overlap between the provided input structures.
%
% Optional key/value pairs:
%    None.
%

TF = zeros(2, 2);
width_delete = delete_obj.size.w;
length_delete = delete_obj.size.l;

%   Use affine transformation to calculate the coordinate after rotation
Ax2 = delete_obj.position(1) + ...
    cosd(-delete_obj.rotate) * width_delete / 2 + ...
    sind(-delete_obj.rotate) * length_delete / 2;
Bx2 = delete_obj.position(1) + ...
    cosd(-delete_obj.rotate) * width_delete / 2 + ...
    sind(-delete_obj.rotate) * (-length_delete / 2);
Cx2 = delete_obj.position(1) + ...
    cosd(-delete_obj.rotate) * (-width_delete / 2) + ...
    sind(-delete_obj.rotate) * (-length_delete / 2);
Dx2 = delete_obj.position(1) + ...
    cosd(-delete_obj.rotate) * (-width_delete / 2) + ...
    sind(-delete_obj.rotate) * length_delete / 2;

Ay2 = delete_obj.position(3) + ...
    cosd(-delete_obj.rotate) * length_delete / 2 - ...
    sind(-delete_obj.rotate) * width_delete / 2;
By2 = delete_obj.position(3) + ...
    cosd(-delete_obj.rotate) * (-length_delete) / 2 - ...
    sind(-delete_obj.rotate) * width_delete / 2;
Cy2 = delete_obj.position(3) + ...
    cosd(-delete_obj.rotate) * (-length_delete) / 2 - ...
    sind(-delete_obj.rotate) * (-width_delete) / 2;
Dy2 = delete_obj.position(3) + ...
    cosd(-delete_obj.rotate) * length_delete / 2 - ...
    sind(-delete_obj.rotate) * (-width_delete) / 2;
p2 = polyshape([Ax2 Bx2 Cx2 Dx2], [Ay2 By2 Cy2 Dy2]);

% Calculate overlap between objects in delete_list and total_list.
for ii = 1:size(total_list, 2)
    Ax1 = total_list(ii).position(1) + ...
        cosd(-total_list(ii).rotate) * total_list(ii).size.w / 2 + ...
        sind(-total_list(ii).rotate) * total_list(ii).size.l / 2;
    Bx1 = total_list(ii).position(1) + ...
        cosd(-total_list(ii).rotate) * total_list(ii).size.w / 2 + ...
        sind(-total_list(ii).rotate) * (-total_list(ii).size.l / 2);
    Cx1 = total_list(ii).position(1) + ...
    cosd(-total_list(ii).rotate) * (-total_list(ii).size.w / 2) + ...
    sind(-total_list(ii).rotate) * (-total_list(ii).size.l / 2);
    Dx1 = total_list(ii).position(1) + ...
    cosd(-total_list(ii).rotate) * (-total_list(ii).size.w / 2) + ...
    sind(-total_list(ii).rotate) * total_list(ii).size.l / 2;

    Ay1 = total_list(ii).position(3) + ...
        cosd(-total_list(ii).rotate) * total_list(ii).size.l / 2 - ...
        sind(-total_list(ii).rotate) * total_list(ii).size.w / 2;
    By1 = total_list(ii).position(3) + ...
        cosd(-total_list(ii).rotate) * (-total_list(ii).size.l) / 2 - ...
        sind(-total_list(ii).rotate) * total_list(ii).size.w / 2;
    Cy1 = total_list(ii).position(3) + ...
        cosd(-total_list(ii).rotate) * (-total_list(ii).size.l) / 2 - ...
        sind(-total_list(ii).rotate) * (-total_list(ii).size.w) / 2;
    Dy1 = total_list(ii).position(3) + ...
        cosd(-total_list(ii).rotate) * total_list(ii).size.l / 2 - ...
        sind(-total_list(ii).rotate) * (-total_list(ii).size.w) / 2;
    p1 = polyshape([Ax1 Bx1 Cx1 Dx1], [Ay1 By1 Cy1 Dy1]);
    ployvec = [p1 p2];
    % figure;
    % patch([Ax1 Bx1 Cx1 Dx1], [Ay1 By1 Cy1 Dy1], 'blue');
    % patch([Ax2 Bx2 Cx2 Dx2], [Ay2 By2 Cy2 Dy2], 'red');

    TF_tmp = overlaps(ployvec);
    TF = TF | TF_tmp;
    if TF(1, 2), break; end
end
end
