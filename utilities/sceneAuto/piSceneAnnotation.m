function scene_label = piSceneAnnotation(meshImage, label, st)
% Read primitive ID from the mesh file and add class information
%
% Syntax:
%   scene_label = piSceneAnnotation(meshImage, label, st)
%
% Description:
%    Read primitive ID from _mesh.txt
%    Add class information here:
%           convert meshImage(instanceSeg) to A classSeg.
%
% Inputs:
%    meshImage   - Matrix. A scene mesh image, in matrix form.
%    label       - String. The full filepath for the scene.
%    st          - (Optional) Object. A scitran object. Will instantiate an
%                  instance of 'stanfordlabs' if none provided.
%
% Outputs:
%    scene_label - Struct. A scene structure containing all of the provided
%                  information above.
%
% Optional key/value pairs:
%    None.
%

% History:
%    XX/XX/18  ZL/ST  Vistasoft Team, 2018
%    04/12/19  JNM    Documentation pass
%    04/18/19  JNM    Merge with Master (resolve conflicts)

%% Check if a scitran object has been supplied
if isempty(st), st = scitran('stanfordlabs'); end

%% maybe we should get recipe first
% So we will be able to assign size and pose info to detected object;
[sceneFolder, sceneName] = fileparts(label);
sceneName = strrep(sceneName, '_mesh', '');
destName_recipe = fullfile(sceneFolder, [sceneName, '.json']);

% find acquisition
if ~exist(sceneFolder, 'dir'), mkdir(sceneFolder); end
acquisition = st.lookup(sprintf(...
    'wandell/Graphics assets/scenes_pbrt/scenes_pbrt/%s', sceneName));
dataId = acquisition.id;
% download the file
piFwFileDownload(destName_recipe, [sceneName, '.json'], dataId);
fprintf('%s downloaded \n', [sceneName, '.json']);

thisR_tmp = jsonread(destName_recipe);
scene_label.daytime = thisR_tmp.metadata.daytime;
scene_label.camera = thisR_tmp.camera;
scene_label.film = thisR_tmp.film;
objects = thisR_tmp.assets;

%% Generate class map and instance map
[scenelabel, objectList] = instanceSeg(meshImage, label, objects);

fds = fieldnames(objectList);
for hh = 1: length(fds)
    nameList = {};
    for ll = 1:length(objectList.(fds{hh}))
        nameList{ll} = objectList.(fds{hh}){ll}.name;
    end
    uniqueList = unique(nameList);
    for kk = 1:length(uniqueList)
        tmp_index = find(count(nameList, uniqueList{kk}));
        for ll = 1:length(tmp_index)
            objectList.(fds{hh}){tmp_index(ll)}.position = ...
                objectList.(fds{hh}){tmp_index(ll)}.position(:, ll);
            objectList.(fds{hh}){tmp_index(ll)}.rotate = ...
                objectList.(fds{hh}){tmp_index(ll)}.rotate(:, ...
                (3 * ll - 2):(3 * ll));
        end
    end
end
scene_label.bbox2d = objectList;
scene_label.seg = scenelabel;

end

function [occluded, truncated, bbox2d] = getBBox(scene_mesh, index, offset)
% Retrieve a 2D bbox
%
% Syntax:
%   [occluded, truncated, bbox2d] = getBBox(scene_mesh, index, offset)
%
% Description:
%    Retrieve a 2D representation of the BBOX as well as whether or not
%    there are occlusions or truncations.
%
% Inputs:
%    scene_mesh - Matrix. A representation of the scene mesh image.
%    index      - Numeric. The index to begin at.
%    offset     - Numeric. The numeric offset.
%
% Outputs:
%    occluded   - Boolean. A boolean indicating the presence of occlusion.
%    truncated  - Boolean. A boolean indication the presence of truncation.
%    bbox2d     - Struct. A structure containing the 2D BBox.
%
% Optional key/value pairs:
%    None.
%
if offset == 0
    indicator = (scene_mesh == index);
else
    indicator = ((scene_mesh <= (index + offset)) & ...
        (scene_mesh >= (index - offset)));
end
xSpread = sum(indicator);
xIndices = find(xSpread > 0);
ySpread = sum(indicator, 2);
yIndices = find(ySpread > 0);
bbox2d.xmin = min(xIndices);
bbox2d.xmax = max(xIndices);
bbox2d.ymin = min(yIndices);
bbox2d.ymax = max(yIndices);
w = size(scene_mesh, 2);
h = size(scene_mesh, 1);
% Occlusions
ccomp = bwconncomp(indicator);
if ccomp.NumObjects  > 1, occluded = 1; else, occluded = 0; end

% Truncations
if (bbox2d.xmin == 1 || bbox2d.ymin == 1 || ...
        bbox2d.xmax == w || bbox2d.ymax == h)
    truncated = 1;
else
    truncated = 0;
end

end

function [sceneLabel, objectList] = instanceSeg(scene_mesh, label, objects)
% Create & colorize a class & instance label map for training.
%
% Syntax:
%   [sceneLabel, objectList] = instanceSeg(scene_mesh, label, objects)
%
% Description:
%    Create class and instance label map for training, and colorize them
%    for visulization.
%
% Inputs:
%    scene_mesh - Matrix. A matrix representation of the scene mesh.
%    label      - String. The filepath for the label. Save the path for
%                 generated labels colors for visulization uses the same
%                 color scheme with cityscape.
%    objects    - Struct. A structure containing all of the visible objects
%                 from the scene.
%
% Outputs:
%    sceneLabel - Object. An object to use for network training.
%    objectList - Struct. A structure containing all of the scene objects.
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * dataset:
%  https://github.com/ISET/iset3d/blob/zhenyi/utilities/sceneAuto/Notes.md
%
% objectList: visible objects list
data = importdata(label);
s = regexp(data, '\s + ', 'split');
offset = 0; % test offset
ClassMap = ones(size(scene_mesh));
InstanceMap = ones(size(scene_mesh));
l = size(scene_mesh, 1);
w = size(scene_mesh, 2);
ClassColorMap = zeros(l, w, 3);
InstanceColorMap = zeros(l, w, 3);
C_1 = ones(l, w) * 70;
C_2 = ones(l, w) * 130;
C_3 = ones(l, w) * 180;
I_1 = ones(l, w) * 70;
I_2 = ones(l, w) * 130;
I_3 = ones(l, w) * 180;
count_car = 0;
count_truck = 0;
count_bus = 0;
count_rider = 0;
count_bicycle = 0;
count_motor = 0;
count_pedestrian = 0;

%% generate label image and instance image
for ii = 1:size(s, 1)
    a = str2double(s{ii}{1});% change from str2num to str2double
    if piContains(s{ii}{2}, 'sky')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 1;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 70;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 130;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 180;
        I_1 = C_1;
        I_2 = C_2;
        I_3 = C_3;
    end
    if piContains(lower(s{ii}{2}), 'car')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 2;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 0;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 0;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 142;
        if ~isempty(C_1((scene_mesh <= (a + offset)) & ...
                (scene_mesh >= (a - offset))))
            count_car = count_car + 1;
            objectList.car{count_car}.name = s{ii}{2};
            [objectList.car{count_car}.occluded, ...
                objectList.car{count_car}.truncated, ...
                objectList.car{count_car}.bbox2d] = ...
                getBBox(scene_mesh, a, offset);
            % get size and orientation infomation
            for jj = 1: length(objects)
                if strcmp(objects(jj).name, s{ii}{2}), break; end
            end
            objectList.car{count_car}.size = objects(jj).size;
            objectList.car{count_car}.position = objects(jj).position;
            objectList.car{count_car}.rotate = objects(jj).rotate;
        end
        InstanceMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 2000 + count_car;

        I_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = randi(255);
        I_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = randi(255);
        I_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = randi(255);
    end

    if piContains(lower(s{ii}{2}), 'truck')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 3;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 0;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 0;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 70;
        if ~isempty(C_1((scene_mesh <= (a + offset)) & ...
                (scene_mesh >= (a - offset))))
            count_truck = count_truck + 1;
            objectList.truck{count_truck}.name = s{ii}{2};
            [objectList.truck{count_truck}.occluded, ...
                objectList.truck{count_truck}.truncated, ...
                objectList.truck{count_truck}.bbox2d] = ...
                getBBox(scene_mesh, a, offset);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name, s{ii}{2}), break; end
            end
            objectList.truck{count_truck}.size = objects(jj).size;
            objectList.truck{count_truck}.position = objects(jj).position;
            objectList.truck{count_truck}.rotate = objects(jj).rotate;
        end
        InstanceMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 3000 + count_truck;

        I_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = randi(255);
        I_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = randi(255);
        I_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = randi(255);
    end

    if piContains(lower(s{ii}{2}), 'bus')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 4;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 0;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 60;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 100;
        if ~isempty(C_1((scene_mesh <= (a + offset)) & ...
                (scene_mesh >= (a - offset))))
            count_bus = count_bus + 1;
            objectList.bus{count_bus}.name = s{ii}{2};
            [objectList.bus{count_bus}.occluded, ...
                objectList.bus{count_bus}.truncated, ...
                objectList.bus{count_bus}.bbox2d] = ...
                getBBox(scene_mesh, a, offset);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name, s{ii}{2}), break; end
            end
            objectList.bus{count_bus}.size = objects(jj).size;
            objectList.bus{count_bus}.position = objects(jj).position;
            objectList.bus{count_bus}.rotate = objects(jj).rotate;
        end
        InstanceMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 4000 + count_bus;

        I_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = randi(255);
        I_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = randi(255);
        I_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = randi(255);
    end
    if piContains(lower(s{ii}{2}), 'rider') && ...
            piContains(lower(s{ii}{2}), 'people')
        ClassMap(scene_mesh == a) = 5;
        C_1(scene_mesh == a) = 255;
        C_2(scene_mesh == a) = 0;
        C_3(scene_mesh == a) = 0;

        InstanceMap(scene_mesh == a) = 5000 + count_rider;
        if ~isempty(C_1(scene_mesh == a))
            count_rider = count_rider + 1;
            objectList.rider{count_rider}.name = s{ii}{2};
            [objectList.rider{count_rider}.occluded, ...
                objectList.rider{count_rider}.truncated, ...
                objectList.rider{count_rider}.bbox2d] = ...
                getBBox(scene_mesh, a, 0);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name, s{ii}{2}), break; end
            end
            objectList.rider{count_rider}.size = objects(jj).size;
            objectList.rider{count_rider}.position = objects(jj).position;
            objectList.rider{count_rider}.rotate = objects(jj).rotate;
        end
        I_1(scene_mesh == a) = randi(255);
        I_2(scene_mesh == a) = randi(255);
        I_3(scene_mesh == a) = randi(255);
    end
    if piContains(lower(s{ii}{2}), 'bicycle') || ...
            (piContains(lower(s{ii}{2}), 'bike_') && ...
            ~piContains(lower(s{ii}{2}), 'people'))
        ClassMap((scene_mesh == a)) = 6;
        C_1(scene_mesh == a) = 119;
        C_2(scene_mesh == a) = 11;
        C_3(scene_mesh == a) = 32;
        if ~isempty(C_1(scene_mesh == a))
            count_bicycle = count_bicycle + 1;
            objectList.bicycle{count_bicycle}.name = s{ii}{2};
            [objectList.bicycle{count_bicycle}.occluded, ...
                objectList.bicycle{count_bicycle}.truncated, ...
                objectList.bicycle{count_bicycle}.bbox2d] = ...
                getBBox(scene_mesh, a, 0);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name, s{ii}{2}), break; end
            end
            objectList.bicycle{count_bicycle}.size = objects(jj).size;
            objectList.bicycle{count_bicycle}.position = ...
                objects(jj).position;
            objectList.bicycle{count_bicycle}.rotate = objects(jj).rotate;
        end
        InstanceMap(scene_mesh == a) = 6000 + count_bicycle;

        I_1(scene_mesh == a) = randi(255);
        I_2(scene_mesh == a) = randi(255);
        I_3(scene_mesh == a) = randi(255);
    end
    if piContains(lower(s{ii}{2}), 'motor')
        ClassMap(scene_mesh == a) = 7;
        C_1(scene_mesh == a) = 0;
        C_2(scene_mesh == a) = 0;
        C_3(scene_mesh == a) = 230;
        if ~isempty(C_1(scene_mesh == a))
            count_motor = count_motor + 1;
            objectList.motor{count_motor}.name = s{ii}{2};
            [objectList.motor{count_motor}.occluded, ...
                objectList.motor{count_motor}.truncated, ...
                objectList.motor{count_motor}.bbox2d] = ...
                getBBox(scene_mesh, a, 0);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name, s{ii}{2}), break; end
            end
            objectList.motor{count_motor}.size = objects(jj).size;
            objectList.motor{count_motor}.position = objects(jj).position;
            objectList.motor{count_motor}.rotate = objects(jj).rotate;
        end
        InstanceMap(scene_mesh == a) = 7000 + count_motor;

        I_1(scene_mesh == a) = randi(255);
        I_2(scene_mesh == a) = randi(255);
        I_3(scene_mesh == a) = randi(255);
    end
    if piContains(lower(s{ii}{2}), 'pedestrian')
        ClassMap(scene_mesh == a) = 8;
        C_1(scene_mesh == a) = 220;
        C_2(scene_mesh == a) = 20;
        C_3(scene_mesh == a) = 60;
        if ~isempty(C_1(scene_mesh == a))
            count_pedestrian = count_pedestrian + 1;
            objectList.pedestrian{count_pedestrian}.name = s{ii}{2};
%             disp(s{ii}{2});
%             disp(a);
            [objectList.pedestrian{count_pedestrian}.occluded, ...
                objectList.pedestrian{count_pedestrian}.truncated, ...
                objectList.pedestrian{count_pedestrian}.bbox2d] = ...
                getBBox(scene_mesh, a, 0);
            for jj = 1: length(objects)
                if strcmp(objects(jj).name, s{ii}{2}), break; end
            end
            objectList.pedestrian{count_pedestrian}.size = ...
                objects(jj).size;
            objectList.pedestrian{count_pedestrian}.position = ...
                objects(jj).position;
            objectList.pedestrian{count_pedestrian}.rotate = ...
                objects(jj).rotate;
        end
        InstanceMap(scene_mesh == a) = 8000 + count_pedestrian;

        I_1(scene_mesh == a) = randi(255);
        I_2(scene_mesh == a) = randi(255);
        I_3(scene_mesh == a) = randi(255);
    end
    if piContains(s{ii}{2}, 'tree_')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 9;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 107;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 142;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 35;
        I_1 = C_1;
        I_2 = C_2;
        I_3 = C_3;
    end
    if piContains(s{ii}{2}, 'building')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 10;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 70;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 70;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 70;
        I_1 = C_1;
        I_2 = C_2;
        I_3 = C_3;
    end
    if piContains(s{ii}{2}, 'streetlight')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 11;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 153;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 153;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 153;
        I_1 = C_1;
        I_2 = C_2;
        I_3 = C_3;
    end
    if piContains(s{ii}{2}, 'trafficlight')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 12;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 250;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 170;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 30;
        I_1 = C_1;
        I_2 = C_2;
        I_3 = C_3;
    end
    if piContains(s{ii}{2}, 'trafficsign')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 13;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 220;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 220;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 0;
        I_1 = C_1;
        I_2 = C_2;
        I_3 = C_3;
    end
    if (piContains(s{ii}{2}, 'bikerack') && ...
            ~piContains(s{ii}{2}, '_bike')) || ...
            piContains(s{ii}{2}, 'trashcan') || ...
            piContains(s{ii}{2}, 'callbox') || ...
            piContains(s{ii}{2}, 'bench') || ...
            piContains(s{ii}{2}, 'billboard') || ...
            piContains(s{ii}{2}, 'station')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 14;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 111;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 74;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 0;
        I_1 = C_1;
        I_2 = C_2;
        I_3 = C_3;
    end
    if piContains(s{ii}{2}, 'city_cross_4lanes_1')...
            || piContains(s{ii}{2}, 'city_cross_4lanes_001')...
            || piContains(s{ii}{2}, 'city_cross_4lanes_001_construct')...
            || piContains(s{ii}{2}, 'city_cross_4lanes_002')...
            || piContains(s{ii}{2}, 'city_cross_4lanes_002_construct')...
            || piContains(s{ii}{2}, 'city_cross_6lanes_1')...
            || piContains(s{ii}{2}, 'city_cross_6lanes_001_construct')...
            || piContains(s{ii}{2}, 'straight_2lanes_parking')...
            || piContains(s{ii}{2}, 'highway_straight_4lanes')...
            || piContains(s{ii}{2}, 'road')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 15;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 128;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 64;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 128;
        I_1 = C_1;I_2 = C_2;I_3 = C_3;
    end
    if piContains(lower(s{ii}{2}), 'plane') || ...
            piContains(lower(s{ii}{2}), 'sidewalk')
        ClassMap((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 16;
        C_1((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 244;
        C_2((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 35;
        C_3((scene_mesh <= (a + offset)) & ...
            (scene_mesh >= (a - offset))) = 232;
        I_1 = C_1;
        I_2 = C_2;
        I_3 = C_3;
    end
end
ClassColorMap(:, :, 1) = C_1;
ClassColorMap(:, :, 2) = C_2;
ClassColorMap(:, :, 3) = C_3;
InstanceColorMap(:, :, 1) = I_1;
InstanceColorMap(:, :, 2) = I_2;
InstanceColorMap(:, :, 3) = I_3;
[sceneFolder, sceneName] = fileparts(label);
classlabel = fullfile(sceneFolder, [sceneName, '_class_label.png']);
imwrite(uint8(ClassMap), classlabel);
classVisulization = fullfile(sceneFolder, [sceneName, '_class_color.png']);
imwrite(uint8(ClassColorMap), classVisulization);
instancelabel = fullfile(sceneFolder, [sceneName, '_instance_label.png']);
imwrite(uint16(InstanceMap), instancelabel);
instanceColor = fullfile(sceneFolder, [sceneName, '_instance_color.png']);
imwrite(uint8(InstanceColorMap), instanceColor);
sceneLabel.class = ClassMap;
sceneLabel.classVis = ClassColorMap;
sceneLabel.Instance = InstanceMap;
sceneLabel.InstanceVis = InstanceColorMap;
end
