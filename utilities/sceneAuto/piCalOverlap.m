function [remain_list, total_list] = piCalOverlap(delete_list, total_list)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function:
% Decide whether objects overlap, delete objects in delet_list that are
% intersect with objects in total_list.

% Input--delete_list: the list of objects to be deleted if overlap.
%        total_list: the list of objects used to calculate overlap.
% Output--remain_list: consists objects in delete_list that don't overlap
%         objects in total_list.
%         total_list: objects in original total_list & objects in
%         remain_list.
% by SL, 2018.8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
if (isfield(delete_list,'name')&&isfield(total_list,'name'))
for mm = 1: size(delete_list,2)
    width_delete(mm) = delete_list(mm).size.w;
    length_delete(mm) = delete_list(mm).size.l;
end
count_total=size(total_list,2);
count_remain=0;
for jj = 1:size(delete_list,2)
    TF=zeros(2,2);
    for mm = 1: size(total_list,2)
        width_total(mm) = total_list(mm).size.w;
        length_total(mm) = total_list(mm).size.l;
    end
%   Use affine transformation to calculate the coordinate after rotation 
    Ax2 = delete_list(jj).position(1)+cosd(-delete_list(jj).rotate)*width_delete(jj)/2+sind(-delete_list(jj).rotate)*length_delete(jj)/2;
    Bx2 = delete_list(jj).position(1)+cosd(-delete_list(jj).rotate)*width_delete(jj)/2+sind(-delete_list(jj).rotate)*(-length_delete(jj)/2);
    Cx2 = delete_list(jj).position(1)+cosd(-delete_list(jj).rotate)*(-width_delete(jj)/2)+sind(-delete_list(jj).rotate)*(-length_delete(jj)/2);
    Dx2 = delete_list(jj).position(1)+cosd(-delete_list(jj).rotate)*(-width_delete(jj)/2)+sind(-delete_list(jj).rotate)*length_delete(jj)/2;
    
    Ay2 = delete_list(jj).position(3)+cosd(-delete_list(jj).rotate)*length_delete(jj)/2-sind(-delete_list(jj).rotate)*width_delete(jj)/2;
    By2 = delete_list(jj).position(3)+cosd(-delete_list(jj).rotate)*(-length_delete(jj))/2-sind(-delete_list(jj).rotate)*width_delete(jj)/2;
    Cy2 = delete_list(jj).position(3)+cosd(-delete_list(jj).rotate)*(-length_delete(jj))/2-sind(-delete_list(jj).rotate)*(-width_delete(jj))/2;
    Dy2 = delete_list(jj).position(3)+cosd(-delete_list(jj).rotate)*length_delete(jj)/2-sind(-delete_list(jj).rotate)*(-width_delete(jj))/2;
    p2 = polyshape([Ax2 Bx2 Cx2 Dx2], [Ay2 By2 Cy2 Dy2]);
% Calculate whether the object in delete_list overlaps objects in total_list
    for ii = 1:size(total_list,2)
        Ax1 = total_list(ii).position(1)+cosd(-total_list(ii).rotate)*width_total(ii)/2+sind(-total_list(ii).rotate)*length_total(ii)/2;
        Bx1 = total_list(ii).position(1)+cosd(-total_list(ii).rotate)*width_total(ii)/2+sind(-total_list(ii).rotate)*(-length_total(ii)/2);
        Cx1 = total_list(ii).position(1)+cosd(-total_list(ii).rotate)*(-width_total(ii)/2)+sind(-total_list(ii).rotate)*(-length_total(ii)/2);
        Dx1 = total_list(ii).position(1)+cosd(-total_list(ii).rotate)*(-width_total(ii)/2)+sind(-total_list(ii).rotate)*length_total(ii)/2;
        
        Ay1 = total_list(ii).position(3)+cosd(-total_list(ii).rotate)*length_total(ii)/2-sind(-total_list(ii).rotate)*width_total(ii)/2;
        By1 = total_list(ii).position(3)+cosd(-total_list(ii).rotate)*(-length_total(ii))/2-sind(-total_list(ii).rotate)*width_total(ii)/2;
        Cy1 = total_list(ii).position(3)+cosd(-total_list(ii).rotate)*(-length_total(ii))/2-sind(-total_list(ii).rotate)*(-width_total(ii))/2;
        Dy1 = total_list(ii).position(3)+cosd(-total_list(ii).rotate)*length_total(ii)/2-sind(-total_list(ii).rotate)*(-width_total(ii))/2;
        p1 = polyshape([Ax1 Bx1 Cx1 Dx1], [Ay1 By1 Cy1 Dy1]); 
        ployvec = [p1 p2];
%         figure;
%         patch([Ax1 Bx1 Cx1 Dx1], [Ay1 By1 Cy1 Dy1],'blue');
%         patch([Ax2 Bx2 Cx2 Dx2], [Ay2 By2 Cy2 Dy2],'red');

        TF_tmp = overlaps(ployvec);
        TF = TF|TF_tmp;
        
    end
    if TF(1,2)==0 % no overlap
        count_remain = count_remain+1;
        count_total= count_total+1;
        remain_list(count_remain)=delete_list(jj);
        total_list(count_total)=delete_list(jj);
    end
end
if count_remain ==0
    remain_list=[];
end

end 
if(isfield(delete_list,'name')==1&&isfield(total_list,'name')==0)
    remain_list = delete_list;
    total_list = delete_list;
end
if(isfield(delete_list,'name')==0&&isfield(total_list,'name')==1)
    remain_list = [];
    total_list = total_list;
end
if(isfield(delete_list,'name')==0&&isfield(total_list,'name')==0)
    remain_list = [];
    total_list = [];
end
    
end