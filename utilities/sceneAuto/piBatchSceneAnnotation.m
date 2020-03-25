function ieObject=piBatchSceneAnnotation(ieObject)
% Read primitive ID from _mesh.txt
%
% We could really use some comments here
%
%
% ZL?? 2019??
%
% See also

objects = ieObject.metadata.objects; 
%% Generate class map and instance map
% check isetObj size, resize depthmap and meshImage accordingly

%%
if strcmp(ieObject.type,'opticalimage')
depthmap = ieObject.depthMap;
else
    depthmap = ieObject.metadata.depthMap;
end
meshImage = ieObject.metadata.meshImage;
label = ieObject.metadata.meshtxt;
[scenelabel,objectList]=instanceSeg(meshImage,label,objects,depthmap);
%
if ~isempty(objectList)
    fds = fieldnames(objectList);
    for hh = 1: length(fds)
        nameList={};
        for ll = 1:length(objectList.(fds{hh}))
            nameList{ll} = objectList.(fds{hh}){ll}.name;
        end
        uniqueList = unique(nameList);
        for kk = 1:length(uniqueList)
            tmp_index = find(count(nameList,uniqueList{kk}));
            for ll = 1:length(tmp_index)
                objectList.(fds{hh}){tmp_index(ll)}.position = objectList.(fds{hh}){tmp_index(ll)}.position(:,1);
                objectList.(fds{hh}){tmp_index(ll)}.rotate  = objectList.(fds{hh}){tmp_index(ll)}.rotate(:,1:3);
            end
        end
    end
end

ieObject.metadata.bbox2d = objectList;
ieObject.metadata.Seg = scenelabel;


end

%%
function [occluded,occludedRate,truncated,bbox2d,ignore] = getBBox(scene_mesh,index,depthmap)

indicator = (scene_mesh==index);   
xSpread = sum(indicator);
xIndices = find(xSpread > 0);
ySpread = sum(indicator,2);
yIndices = find(ySpread > 0);
bbox2d.xmin = min(xIndices);
bbox2d.xmax = max(xIndices);
bbox2d.ymin = min(yIndices);
bbox2d.ymax = max(yIndices);
w = size(scene_mesh,2);
h = size(scene_mesh,1);
objDepth = zeros(size(indicator));
for irows = 1:size(indicator,1) 
    for icols = 1:size(indicator,2)
        if indicator(irows, icols) == 1
            objDepth(irows,icols) = depthmap(irows,icols);
        else
            objDepth(irows,icols) = 0;
        end
    end
end
% Find the object position in depthmap
posDepth = [bbox2d.xmin bbox2d.ymin bbox2d.xmax-bbox2d.xmin bbox2d.ymax-bbox2d.ymin];
depthCrop = imcrop(depthmap,posDepth);
% check how far is the car
% depthCrop_tmp = imcrop(depthmap,[posDepth(1)-20,posDepth(2),posDepth(3)+40,posDepth(4)]);
% Check mesh_image
meshCrop = imcrop(scene_mesh,posDepth);
objDist = min(objDepth(objDepth>0));

% ignore target if objDist larger than 150m
% Occlusions
ccomp = bwconncomp(indicator);
if ccomp.NumObjects > 1 
   occluded = 1;
   % approximate percentage of occluded pixels
   occludedRate = 1-sum(indicator(:))/length(depthCrop(:)); 
   %elseif check discontinuity in depth
else
    occluded = 0;
    occludedRate = 0;
end

% Truncations
if (bbox2d.xmin == 1 || bbox2d.ymin == 1 || ...
        bbox2d.xmax == w || bbox2d.ymax == h)
    truncated = 1;
else
    truncated = 0;
end
% will not be annotated in the end
ignore = 0;
if objDist > 150 || occludedRate > 0.8 || sum(indicator(:))<10
    ignore =1;
end

end


%%
function [scenelabel,objectList] = instanceSeg(scene_mesh,label,objects,depthmap)
%% Create class and instacne label map for training, and colorize them for visulization
% labelPath: save the path for generated labels
% colors for visulization uses the same color scheme with cityscape
% dataset:
%        
%       https://github.com/ISET/iset3d/blob/zhenyi/utilities/sceneAuto/Notes.md
%
% objectList: visible objects list
objectList = [];
% data=importdata(label);
% s = regexp(data, '\s+', 'split');
s = label;
ClassMap= ones(size(scene_mesh));
InstanceMap= ones(size(scene_mesh));
l=size(scene_mesh,1);
w=size(scene_mesh,2);
ClassColorMap= zeros(l,w,3);
InstanceColorMap= zeros(l,w,3);
C_1=ones(l,w)*70;
C_2=ones(l,w)*130;
C_3=ones(l,w)*180;
I_1=ones(l,w)*70;
I_2=ones(l,w)*130;
I_3=ones(l,w)*180;
count_car=0;
count_truck=0;
count_bus=0;
count_rider=0;
count_bicycle=0;
count_motor=0;
count_pedestrian=0;


%% generate label image and instance image
for ii = 1:size(s,1)
    a=str2double(s{ii}{1});% change from str2num to str2double
    if piContains(s{ii}{2},'sky')
        ClassMap(scene_mesh==a)=1;
        C_1(scene_mesh==a)=70;
        C_2(scene_mesh==a)=130;
        C_3(scene_mesh==a)=180;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if piContains(lower(s{ii}{2}),'car')
        ClassMap(scene_mesh==a)=2;
        C_1(scene_mesh==a)=0;
        C_2(scene_mesh==a)=0;
        C_3(scene_mesh==a)=142;
        if ~isempty(C_1(scene_mesh==a))
            count_car=count_car+1;
            objectList.car{count_car}.name = s{ii}{2};
            [objectList.car{count_car}.occluded,...
                objectList.car{count_car}.occludedrate,...
                objectList.car{count_car}.truncated,...
                objectList.car{count_car}.bbox2d,...
                objectList.car{count_car}.ignore] = getBBox(scene_mesh,a,depthmap);
            % get size and orientation infomation
            for jj = 1: length(objects)
                if strcmp(objects(jj).name,s{ii}{2})
                    break;
                end
            end
            objectList.car{count_car}.size  = objects(jj).size;
            objectList.car{count_car}.position = objects(jj).position;
            objectList.car{count_car}.rotate   = objects(jj).rotate;
            
        end
        InstanceMap(scene_mesh==a)=2000+count_car;

        I_1(scene_mesh==a)=randi(255);
        I_2(scene_mesh==a)=randi(255);
        I_3(scene_mesh==a)=randi(255);

    end
    
    if piContains(lower(s{ii}{2}),'truck')
        ClassMap(scene_mesh==a)=3;
        C_1(scene_mesh==a)=0;
        C_2(scene_mesh==a)=0;
        C_3(scene_mesh==a)=70;
        if ~isempty(C_1(scene_mesh==a))
            count_truck=count_truck+1;
            objectList.truck{count_truck}.name = s{ii}{2};
            [objectList.truck{count_truck}.occluded,...
                objectList.truck{count_truck}.occludedrate,...
                objectList.truck{count_truck}.truncated,...
                objectList.truck{count_truck}.bbox2d,...
                objectList.truck{count_truck}.ignore] = getBBox(scene_mesh,a,depthmap);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name,s{ii}{2})
                    break;
                end
            end
            objectList.truck{count_truck}.size     = objects(jj).size;
            objectList.truck{count_truck}.position = objects(jj).position;
            objectList.truck{count_truck}.rotate   = objects(jj).rotate;
        end
        InstanceMap(scene_mesh==a)=3000+count_truck;

        I_1(scene_mesh==a)=randi(255);
        I_2(scene_mesh==a)=randi(255);
        I_3(scene_mesh==a)=randi(255);
    end
    
    if piContains(lower(s{ii}{2}),'bus')
        ClassMap(scene_mesh==a)=4;
        C_1(scene_mesh==a)=0;
        C_2(scene_mesh==a)=60;
        C_3(scene_mesh==a)=100;
        if ~isempty(C_1(scene_mesh==a))
            count_bus=count_bus+1;
            objectList.bus{count_bus}.name= s{ii}{2};
            [objectList.bus{count_bus}.occluded,...
                objectList.bus{count_bus}.occludedrate,...
                objectList.bus{count_bus}.truncated,...
                objectList.bus{count_bus}.bbox2d,...
                objectList.bus{count_bus}.ignore] = getBBox(scene_mesh,a,depthmap);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name,s{ii}{2})
                    break;
                end
            end
            objectList.bus{count_bus}.size     = objects(jj).size;
            objectList.bus{count_bus}.position = objects(jj).position;
            objectList.bus{count_bus}.rotate   = objects(jj).rotate;           
        end
        InstanceMap(scene_mesh==a)=4000+count_bus;

        I_1(scene_mesh==a)=randi(255);
        I_2(scene_mesh==a)=randi(255);
        I_3(scene_mesh==a)=randi(255);
    end
    if piContains(lower(s{ii}{2}),'_rider')||piContains(lower(s{ii}{2}),'_people')
        ClassMap(scene_mesh==a)=5;
        C_1(scene_mesh==a)=255;
        C_2(scene_mesh==a)=0;
        C_3(scene_mesh==a)=0;
        
        InstanceMap(scene_mesh==a)=5000+count_rider;
        if ~isempty(C_1(scene_mesh==a))
            count_rider=count_rider+1;
            objectList.rider{count_rider}.name= s{ii}{2};
            [objectList.rider{count_rider}.occluded,...
                objectList.rider{count_rider}.occludedrate,...
                objectList.rider{count_rider}.truncated,...
                objectList.rider{count_rider}.bbox2d,...
                objectList.rider{count_rider}.ignore] = getBBox(scene_mesh,a,depthmap);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name,s{ii}{2})
                    break;
                end
            end
            objectList.rider{count_rider}.size     = objects(jj).size;
            objectList.rider{count_rider}.position = objects(jj).position;
            objectList.rider{count_rider}.rotate   = objects(jj).rotate;         
        end
        I_1(scene_mesh==a)=randi(255);
        I_2(scene_mesh==a)=randi(255);
        I_3(scene_mesh==a)=randi(255);
    end
    if piContains(lower(s{ii}{2}),'bicycle')||(piContains(lower(s{ii}{2}),'bike_')...
            &&~piContains(lower(s{ii}{2}),'_people')&&~piContains(lower(s{ii}{2}),'_rider'))
        ClassMap((scene_mesh==a))=6;
        C_1(scene_mesh==a)=119;
        C_2(scene_mesh==a)=11;
        C_3(scene_mesh==a)=32;
        if ~isempty(C_1(scene_mesh==a))
            count_bicycle=count_bicycle+1;
            objectList.bicycle{count_bicycle}.name= s{ii}{2};
            [objectList.bicycle{count_bicycle}.occluded,...
                objectList.bicycle{count_bicycle}.occludedrate,...
                objectList.bicycle{count_bicycle}.truncated,...
                objectList.bicycle{count_bicycle}.bbox2d,...
                objectList.bicycle{count_bicycle}.ignore] = getBBox(scene_mesh,a,depthmap);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name,s{ii}{2})
                    break;
                end
            end
            objectList.bicycle{count_bicycle}.size     = objects(jj).size;
            objectList.bicycle{count_bicycle}.position = objects(jj).position;
            objectList.bicycle{count_bicycle}.rotate   = objects(jj).rotate;
        end
        InstanceMap(scene_mesh==a)=6000+count_bicycle;

        I_1(scene_mesh==a)=randi(255);
        I_2(scene_mesh==a)=randi(255);
        I_3(scene_mesh==a)=randi(255);
    end
    if piContains(lower(s{ii}{2}),'motor')
        ClassMap(scene_mesh==a)=7;
        C_1(scene_mesh==a)=0;
        C_2(scene_mesh==a)=0;
        C_3(scene_mesh==a)=230;
        if ~isempty(C_1(scene_mesh==a))
            count_motor=count_motor+1;
            objectList.motor{count_motor}.name= s{ii}{2};
            [objectList.motor{count_motor}.occluded,...
                objectList.motor{count_motor}.occludedrate,...
                objectList.motor{count_motor}.truncated,...
                objectList.motor{count_motor}.bbox2d,...
                objectList.motor{count_motor}.ignore] = getBBox(scene_mesh,a,depthmap);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name,s{ii}{2})
                    break;
                end
            end
            objectList.motor{count_motor}.size     = objects(jj).size;
            objectList.motor{count_motor}.position = objects(jj).position;
            objectList.motor{count_motor}.rotate   = objects(jj).rotate;
        end        
        InstanceMap(scene_mesh==a)=7000+count_motor;

        I_1(scene_mesh==a)=randi(255);
        I_2(scene_mesh==a)=randi(255);
        I_3(scene_mesh==a)=randi(255);
    end
    if piContains(lower(s{ii}{2}),'pedestrian')
        ClassMap(scene_mesh==a)=8;
        C_1(scene_mesh==a)=220;
        C_2(scene_mesh==a)=20;
        C_3(scene_mesh==a)=60;
        if ~isempty(C_1(scene_mesh==a))
            count_pedestrian=count_pedestrian+1;
            objectList.pedestrian{count_pedestrian}.name= s{ii}{2};
%             disp(s{ii}{2});
%             disp(a);
            [objectList.pedestrian{count_pedestrian}.occluded,...
                objectList.pedestrian{count_pedestrian}.occludedrate,...
                objectList.pedestrian{count_pedestrian}.truncated,...
                objectList.pedestrian{count_pedestrian}.bbox2d,...
                objectList.pedestrian{count_pedestrian}.ignore] = getBBox(scene_mesh,a,depthmap);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name,s{ii}{2})
                    break;
                end
            end
            objectList.pedestrian{count_pedestrian}.size     = objects(jj).size;
            objectList.pedestrian{count_pedestrian}.position = objects(jj).position;
            objectList.pedestrian{count_pedestrian}.rotate   = objects(jj).rotate;
        end        
        InstanceMap(scene_mesh==a)=8000+count_pedestrian;

        I_1(scene_mesh==a)=randi(255);
        I_2(scene_mesh==a)=randi(255);
        I_3(scene_mesh==a)=randi(255);
    end
    if piContains(s{ii}{2},'tree_')
        ClassMap(scene_mesh==a)=9;
        C_1(scene_mesh==a)=107;
        C_2(scene_mesh==a)=142;
        C_3(scene_mesh==a)=35;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if piContains(s{ii}{2},'building')
        ClassMap(scene_mesh==a)=10;
        C_1(scene_mesh==a)=70;
        C_2(scene_mesh==a)=70;
        C_3(scene_mesh==a)=70;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if piContains(s{ii}{2},'streetlight')
        ClassMap(scene_mesh==a)=11;
        C_1(scene_mesh==a)=153;
        C_2(scene_mesh==a)=153;
        C_3(scene_mesh==a)=153;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if piContains(s{ii}{2},'trafficlight')
        ClassMap(scene_mesh==a)=12;
        C_1(scene_mesh==a)=250;
        C_2(scene_mesh==a)=170;
        C_3(scene_mesh==a)=30;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if piContains(s{ii}{2},'trafficsign')
        ClassMap(scene_mesh==a)=13;
        C_1(scene_mesh==a)=220;
        C_2(scene_mesh==a)=220;
        C_3(scene_mesh==a)=0;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if (piContains(s{ii}{2},'bikerack')&&~piContains(s{ii}{2},'_bike'))...
            ||piContains(s{ii}{2},'trashcan')||piContains(s{ii}{2},'callbox')...
            ||piContains(s{ii}{2},'bench')||piContains(s{ii}{2},'billboard')...
            ||piContains(s{ii}{2},'station')
        ClassMap(scene_mesh==a)=14;
        C_1(scene_mesh==a)=111;
        C_2(scene_mesh==a)=74;
        C_3(scene_mesh==a)=0;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if (piContains(s{ii}{2},'city_cross_4lanes_1')...
            ||piContains(s{ii}{2},'city_cross_4lanes_001')...
            ||piContains(s{ii}{2},'city_cross_4lanes_001_construct')...
            ||piContains(s{ii}{2},'city_cross_4lanes_002')...
            ||piContains(s{ii}{2},'city_cross_4lanes_002_construct')...
            ||piContains(s{ii}{2},'city_cross_6lanes_1')...
            ||piContains(s{ii}{2},'city_cross_6lanes_001_construct')...
            ||piContains(s{ii}{2},'straight_2lanes_parking')...
            ||piContains(s{ii}{2},'highway_straight_4lanes')...
            ||piContains(s{ii}{2},'road'))
        ClassMap(scene_mesh==a)=15;
        C_1(scene_mesh==a)=128;
        C_2(scene_mesh==a)=64;
        C_3(scene_mesh==a)=128;
        I_1=C_1;I_2=C_2;I_3=C_3;        
    end
    if piContains(lower(s{ii}{2}),'plane')||piContains(lower(s{ii}{2}),'sidewalk')
        ClassMap(scene_mesh==a)=16;
        C_1(scene_mesh==a)=244;
        C_2(scene_mesh==a)=35;
        C_3(scene_mesh==a)=232;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end    
end
ClassColorMap(:,:,1)=C_1;
ClassColorMap(:,:,2)=C_2;
ClassColorMap(:,:,3)=C_3;
InstanceColorMap(:,:,1)=I_1;
InstanceColorMap(:,:,2)=I_2;
InstanceColorMap(:,:,3)=I_3;
% [destDir,sceneName]=fileparts(label);
% sceneName = strrep(sceneName,'_mesh','');
% sceneFigureDir = fullfile(destDir,sceneName);
% classlabel = fullfile(sceneFigureDir,[sceneName,'_class_label.png']);
% imwrite(uint8(ClassMap),classlabel);
% classVisulization = fullfile(sceneFigureDir,[sceneName,'_class_color.png']);
% imwrite(uint8(ClassColorMap),classVisulization);
% instancelabel = fullfile(sceneFigureDir,[sceneName,'_instance_label.png']);
% imwrite(uint16(InstanceMap),instancelabel);
% instanceColor = fullfile(sceneFigureDir,[sceneName,'_instance_color.png']);
% imwrite(uint8(InstanceColorMap),instanceColor);
scenelabel.class      = ClassMap;
scenelabel.classVis   = ClassColorMap;
scenelabel.Instance   = InstanceMap;
scenelabel.InstanceVis= InstanceColorMap;
end





