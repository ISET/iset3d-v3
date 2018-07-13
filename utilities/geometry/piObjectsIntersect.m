function [ intersect ] = piObjectsIntersect( refObj, objs)

refbox = refObj.







refBox = refObj.bndbox + repmat(refObj.position(:),[1, 2])*1000;

intersect = false;
for i=1:length(objs)
    
    targetBox = objs(i).bndbox + repmat(objs(i).position(:), [1, 2])*1000;
    int = bboxIntersect(refBox, targetBox);
    
    if int,
        intersect = true;
        break;
    end
end



end

function intersect = bboxIntersect(bbox1, bbox2)

bbox1center = sum(bbox1,2)*0.5;
bbox1dims = abs(diff(bbox1,1,2));
bbox1size = max(bbox1dims(1:2));

bbox2center = sum(bbox2,2)*0.5;
bbox2dims = abs(diff(bbox2,1,2));
bbox2size = max(bbox2dims(1:2));

newBbox1 = [bbox1center - bbox1size/2, bbox1center + bbox1size/2];
newBbox2 = [bbox2center - bbox2size/2, bbox2center + bbox2size/2];

%{
figure;
plot(bbox1center(1),bbox1center(2),'rx');
rectangle('Position',[bbox1(1,1) bbox1(2,1) bbox1(1,2)-bbox1(1,1) bbox1(2,2) - bbox1(2,1)],'edgecolor','red')
rectangle('Position',[newBbox1(1,1) newBbox1(2,1) bbox1size bbox1size],'edgecolor','red','linestyle','--');
rectangle('Position',[bbox2(1,1) bbox2(2,1) bbox2(1,2)-bbox2(1,1) bbox2(2,2) - bbox2(2,1)],'edgecolor','green')
rectangle('Position',[newBbox2(1,1) newBbox2(2,1) bbox2size bbox2size],'edgecolor','green','linestyle','--');
%}


%% Check overlap along x and y
xoverlap = false;
if newBbox1(1,2) > newBbox2(1,1) && newBbox1(1,1) < newBbox2(1,2)
    xoverlap = true;
end

yoverlap = false;
if newBbox1(2,2) > newBbox2(2,1) && newBbox1(2,1) < newBbox2(2,2)
    yoverlap = true;
end

intersect = xoverlap & yoverlap;

end