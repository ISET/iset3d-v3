%% Assemble a scene and render it. 




%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Assetc generated directly from C4D with nice naming conventions
AssetsPath = '/Users/zhenyiliu/Desktop/Assets';

%% load assets.
% This is just for test.
% In the future, the assets will have a name with class_index.pbrt, so we
% will only need to give a number of objects for the class and read them at
% back end.
%% obj 1
fname = fullfile(AssetsPath,'floor','floor.pbrt');
if ~exist(fname,'file'), error('File not found'); end
floorR = piRead(fname,'version',3);
piMaterialList(floorR); % We use default material for this obj. 
% Read a geometry file exported by C4d and convert it to be able to
% generate pixel labels
floor = piGeometryRead(floorR);
% Write out the geometry file.
piGeometryWrite(floorR, floor);

%% obj 2
fname = fullfile(AssetsPath,'cube','cube.pbrt');
if ~exist(fname,'file'), error('File not found'); end
cubeR = piRead(fname,'version',3);
% Assign Materials and Color
piMaterialList(cubeR);
material = cubeR.materials.list.cube;   % A type of material.
target = cubeR.materials.lib.plastic;      % Give it a chrome spd
rgbkd  = [1 0 0];                        % Make it red diffuse reflection
rgbkr  = [0.7 0.7 0.7];            % Specularish in the different channels
piMaterialAssign(cubeR,material.name,target,'rgbkd',rgbkd,'rgbkr',rgbkr);
cube  = piGeometryRead(cubeR); 
piGeometryWrite(cubeR, floor);

%% obj 3
fname = fullfile(AssetsPath,'pyramid','pyramid.pbrt');
if ~exist(fname,'file'), error('File not found'); end
pyramidR = piRead(fname,'version',3);

% Assign Materials and Color
piMaterialList(pyramidR);
material = pyramidR.materials.list.pyramid;   % A type of material.
target = pyramidR.materials.lib.glass;      % Give it a chrome spd
rgbkr  = [1 0 0];            % Specularish in the different channels
piMaterialAssign(pyramidR,material.name,target,'rgbkr',rgbkr);
pyramid  = piGeometryRead(pyramidR); 
piGeometryWrite(pyramidR, floor);

%% Assemble a scene
cube = piObjTranslate(cube,[10,0,0]);
glass= piObjTraslate(glass,[0 0 20]);
glass = piObjRotate(galss,[45 0 1 0]);




%% Render


%% Mesh Image with labels