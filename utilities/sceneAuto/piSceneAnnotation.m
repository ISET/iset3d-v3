function scene_label=piSceneAnnotation(meshImage, label,st)
% Read primitive ID from _mesh.txt
% Add class information here: convert meshImage(instanceSeg) to A
% classSeg.
%
% ZL/ST, Vistasoft Team, 2018
%% 
if isempty(st), st = scitran('stanfordlabs'); end
%% maybe we should get recipe first, so we will be able to assign size and pose info to detected object;
[sceneFolder,sceneName]=fileparts(label);
sceneName = strrep(sceneName,'_mesh','');
destName_recipe = fullfile(sceneFolder,[sceneName,'.json']);
% find acquisition
if ~exist(sceneFolder,'dir'),mkdir(sceneFolder);end
files = st.search('file',...
   'project label exact','Graphics assets',...
   'session label exact','scenes_pbrt',...
   'acquisition label exact',sceneName);
dataId = files{1}.parent.id;
% download the file
st.fileDownload([sceneName,'.json'],...
    'container type', 'acquisition' , ...
    'container id',  dataId ,...
    'destination',destName_recipe);
fprintf('%s downloaded \n',[sceneName,'.json']);
thisR_tmp = jsonread(destName_recipe);
objects = thisR_tmp.assets; 
%% Generate class map and instance map
[labelPath,objectList]=instanceSeg(meshImage,label,objects);
%
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
            objectList.(fds{hh}){tmp_index(ll)}.position = objectList.(fds{hh}){tmp_index(ll)}.position(:,ll);
            objectList.(fds{hh}){tmp_index(ll)}.rotate  = objectList.(fds{hh}){tmp_index(ll)}.rotate(:,(3*ll-2):(3*ll));
        end
    end
end
scene_label.bbox2d = objectList;

scene_label.seg = labelPath;

%{
% instanceIDs = unique(meshImage);% Find index of labeled object
% instanceIDs = instanceIDs(instanceIDs >= 0);
% 
% instance = instanceIDSearch(label,instanceIDs);
% % Search ID in scene_mesh.txt, assign bndbox to the object.
% dd = 1;
% for ii=1:length(instance)
%     indicator = (meshImage == instance{ii}.index);
%     if sum(indicator(:)) == 0
%         continue;
%     end
%     
%     xSpread = sum(indicator);
%     xIndices = find(xSpread >= 0);
%     
%     ySpread = sum(indicator,2);
%     yIndices = find(ySpread >= 0);
% %     for jj = 1:length(objects)
% %         if isequal(objects(jj).name, instance{ii}.name)
% %             %              [~,name] = fileparts(thisR.outputFile);
% %             %              tmp = strfind(name,'_');label = name(1:tmp-1);
% %             %              detections(dd).label = label;
% %             detections(dd).index = jj;
% %         end
% %     end
%     detections(dd).bndbox.xmin = min(xIndices);
%     detections(dd).bndbox.xmax = max(xIndices);
%     detections(dd).bndbox.ymin = min(yIndices);
%     detections(dd).bndbox.ymax = max(yIndices);
%     objects(detections(dd).index).bndbox.xmin = detections(dd).bndbox.xmin;
%     objects(detections(dd).index).bndbox.xmax = detections(dd).bndbox.xmax;
%     objects(detections(dd).index).bndbox.ymin = detections(dd).bndbox.ymin;
%     objects(detections(dd).index).bndbox.ymax = detections(dd).bndbox.ymax;
%     %objects(detections(dd).index).label      = detections(dd).label;
%     dd = dd+1;
% end
%}

end
function [occluded, truncated,bbox2d] = getBBox(scene_mesh,index,offset)
if offset==0
    indicator = (scene_mesh==index);
else
    indicator = ((scene_mesh<=(index+offset))&(scene_mesh>=(index-offset)));
end
figure;imagesc(indicator);
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
% Occlusions
ccomp = bwconncomp(indicator);
if ccomp.NumObjects > 1
    occluded = 1;
else
    occluded = 0;
end

% Truncations
if (bbox2d.xmin == 1 || bbox2d.ymin == 1 || ...
        bbox2d.xmax == w || bbox2d.ymax == h)
    truncated = 1;
else
    truncated = 0;
end
end
%{
% function instance = instanceIDSearch(label, instanceIDs)
% fid_tmp = fopen(label);
% instanceIDlist = textscan(fid_tmp,'%s','Delimiter','\n');
% instanceIDlist = instanceIDlist{1};
% fclose(fid_tmp);dd = 1;
% for ii = 1:length(instanceIDlist)
%     tmp = strfind(instanceIDlist{ii},' ');
%     id{ii}.index = str2double(instanceIDlist{ii}(1:tmp-1));
%     id{ii}.name = instanceIDlist{ii}(tmp+1:end);
%     % Search the corresponding name with the id found in meshImage
%     
%     for jj = 1:length(instanceIDs)
%         if instanceIDs(jj) == id{ii}.index
%             instance{dd} = id{ii};
%             dd = dd+1;
%         end
%     end
%     fprintf('%d object instances found \n',dd-1);
% end
% end
%}

function [labelPath,objectList] = instanceSeg(scene_mesh,label,objects)
%% Create class and instacne label map for training, and colorize them for visulization
% labelPath: save the path for generated labels
% colors for visulization uses the same color scheme with cityscape
% dataset:
%        
%       https://github.com/ISET/iset3d/blob/zhenyi/utilities/sceneAuto/Notes.md
%
% objectList: visible objects list
data=importdata(label);
s = regexp(data, '\s+', 'split');
offset=0;% test offset
SegmentationMap= ones(size(scene_mesh));
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
    if contains(s{ii}{2},'sky')
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=1;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=70;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=130;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=180;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if contains(lower(s{ii}{2}),'car')
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=2;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=0;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=0;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=142;
        if ~isempty(C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset))))
            count_car=count_car+1;
            objectList.car{count_car}.name = s{ii}{2};
            [objectList.car{count_car}.occluded,...
                objectList.car{count_car}.truncated,...
                objectList.car{count_car}.bbox2d] = getBBox(scene_mesh,a,offset);
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
        InstanceMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=2000+count_car;

        I_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=randi(255);
        I_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=randi(255);
        I_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=randi(255);

    end
    
    if contains(lower(s{ii}{2}),'truck')
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=3;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=0;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=0;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=70;
        if ~isempty(C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset))))
            count_truck=count_truck+1;
            objectList.truck{count_truck}.name = s{ii}{2};
            [objectList.truck{count_truck}.occluded,...
                objectList.truck{count_truck}.truncated,...
                objectList.truck{count_truck}.bbox2d] = getBBox(scene_mesh,a,offset);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name,s{ii}{2})
                    break;
                end
            end
            objectList.truck{count_truck}.size     = objects(jj).size;
            objectList.truck{count_truck}.position = objects(jj).position;
            objectList.truck{count_truck}.rotate   = objects(jj).rotate;
        end
        InstanceMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=3000+count_truck;

        I_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=randi(255);
        I_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=randi(255);
        I_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=randi(255);
    end
    
    if contains(lower(s{ii}{2}),'bus')
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=4;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=0;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=60;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=100;
        if ~isempty(C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset))))
            count_bus=count_bus+1;
            objectList.bus{count_bus}.name= s{ii}{2};
            [objectList.bus{count_bus}.occluded,...
                objectList.bus{count_bus}.truncated,...
                objectList.bus{count_bus}.bbox2d] = getBBox(scene_mesh,a,offset);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name,s{ii}{2})
                    break;
                end
            end
            objectList.bus{count_bus}.size     = objects(jj).size;
            objectList.bus{count_bus}.position = objects(jj).position;
            objectList.bus{count_bus}.rotate   = objects(jj).rotate;           
        end
        InstanceMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=4000+count_bus;

        I_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=randi(255);
        I_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=randi(255);
        I_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=randi(255);
    end
    if contains(lower(s{ii}{2}),'rider')&&contains(lower(s{ii}{2}),'people')
        SegmentationMap(scene_mesh==a)=5;
        C_1(scene_mesh==a)=255;
        C_2(scene_mesh==a)=0;
        C_3(scene_mesh==a)=0;
        
        InstanceMap(scene_mesh==a)=5000+count_rider;
        if ~isempty(C_1(scene_mesh==a))
            count_rider=count_rider+1;
            objectList.rider{count_rider}.name= s{ii}{2};
            [objectList.rider{count_rider}.occluded,...
                objectList.rider{count_rider}.truncated,...
            objectList.rider{count_rider}.bbox2d] = getBBox(scene_mesh,a,0);
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
    if contains(lower(s{ii}{2}),'bicycle')||(contains(lower(s{ii}{2}),'bike_')&&~contains(lower(s{ii}{2}),'people'))
        SegmentationMap((scene_mesh==a))=6;
        C_1(scene_mesh==a)=119;
        C_2(scene_mesh==a)=11;
        C_3(scene_mesh==a)=32;
        if ~isempty(C_1(scene_mesh==a))
            count_bicycle=count_bicycle+1;
            objectList.bicycle{count_bicycle}.name= s{ii}{2};
            [objectList.bicycle{count_bicycle}.occluded,...
                objectList.bicycle{count_bicycle}.truncated,...
                objectList.bicycle{count_bicycle}.bbox2d] = getBBox(scene_mesh,a,0);
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
    if contains(lower(s{ii}{2}),'motor')
        SegmentationMap(scene_mesh==a)=7;
        C_1(scene_mesh==a)=0;
        C_2(scene_mesh==a)=0;
        C_3(scene_mesh==a)=230;
        if ~isempty(C_1(scene_mesh==a))
            count_motor=count_motor+1;
            objectList.motor{count_motor}.name= s{ii}{2};
            [objectList.motor{count_motor}.occluded,...
                objectList.motor{count_motor}.truncated,...
                objectList.motor{count_motor}.bbox2d] = getBBox(scene_mesh,a,0);
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
    if contains(lower(s{ii}{2}),'pedestrian')
        SegmentationMap(scene_mesh==a)=8;
        C_1(scene_mesh==a)=220;
        C_2(scene_mesh==a)=20;
        C_3(scene_mesh==a)=60;
        if ~isempty(C_1(scene_mesh==a))
            count_pedestrian=count_pedestrian+1;
            objectList.pedestrian{count_pedestrian}.name= s{ii}{2};
%             disp(s{ii}{2});
%             disp(a);
            [objectList.pedestrian{count_pedestrian}.occluded,...
                objectList.pedestrian{count_pedestrian}.truncated,...
                objectList.pedestrian{count_pedestrian}.bbox2d] = getBBox(scene_mesh,a,0);
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
    if contains(s{ii}{2},'tree_')
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=9;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=107;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=142;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=35;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if contains(s{ii}{2},'building')
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=10;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=70;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=70;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=70;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if contains(s{ii}{2},'streetlight')
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=11;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=153;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=153;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=153;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if contains(s{ii}{2},'trafficlight')
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=12;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=250;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=170;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=30;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if contains(s{ii}{2},'trafficsign')
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=13;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=220;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=220;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=0;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if (contains(s{ii}{2},'bikerack')&&~contains(s{ii}{2},'bike'))...
            ||contains(s{ii}{2},'trashcan')||contains(s{ii}{2},'callbox')...
            ||contains(s{ii}{2},'bench')||contains(s{ii}{2},'billboard')...
            ||contains(s{ii}{2},'station')
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=14;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=111;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=74;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=0;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end
    if (contains(s{ii}{2},'city_cross_4lanes_1')...
            ||contains(s{ii}{2},'city_cross_4lanes_001')...
            ||contains(s{ii}{2},'city_cross_4lanes_001_construct')...
            ||contains(s{ii}{2},'city_cross_4lanes_002')...
            ||contains(s{ii}{2},'city_cross_4lanes_002_construct')...
            ||contains(s{ii}{2},'city_cross_6lanes_1')...
            ||contains(s{ii}{2},'city_cross_6lanes_001_construct')...
            ||contains(s{ii}{2},'straight_2lanes_parking')...
            ||contains(s{ii}{2},'highway_straight_4lanes')...
            ||contains(s{ii}{2},'road'))
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=15;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=128;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=64;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=128;
        I_1=C_1;I_2=C_2;I_3=C_3;        
    end
    if contains(lower(s{ii}{2}),'plane')||contains(lower(s{ii}{2}),'sidewalk')
        SegmentationMap((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=16;
        C_1((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=244;
        C_2((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=35;
        C_3((scene_mesh<=(a+offset))&(scene_mesh>=(a-offset)))=232;
        I_1=C_1;I_2=C_2;I_3=C_3;
    end    
end
ClassColorMap(:,:,1)=C_1;
ClassColorMap(:,:,2)=C_2;
ClassColorMap(:,:,3)=C_3;
InstanceColorMap(:,:,1)=I_1;
InstanceColorMap(:,:,2)=I_2;
InstanceColorMap(:,:,3)=I_3;
[sceneFolder,sceneName]=fileparts(label);
classlabel = fullfile(sceneFolder,[sceneName,'_class_label.png']);
imwrite(uint8(SegmentationMap),classlabel);
classVisulization = fullfile(sceneFolder,[sceneName,'_class_color.png']);
imwrite(uint8(ClassColorMap),classVisulization);
instancelabel = fullfile(sceneFolder,[sceneName,'_instance_label.png']);
imwrite(uint16(InstanceMap),instancelabel);
instanceColor = fullfile(sceneFolder,[sceneName,'_instance_color.png']);
imwrite(uint8(InstanceColorMap),instanceColor);
labelPath{1}=classlabel;
labelPath{2}=classVisulization;
labelPath{3}=instancelabel;
labelPath{4}=instanceColor;
end





