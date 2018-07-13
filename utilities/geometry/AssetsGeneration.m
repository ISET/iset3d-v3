%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
%% Read pbrt_material files
FilePath = '/Volumes/group/wandell/data/NN_Camera_Generalization/pbrt_assets/car/Car_2';
fname = fullfile(FilePath,'Car_2.pbrt');
if ~exist(fname,'file'), error('File not found'); end
thisR = piRead(fname,'version',3);

%% Change render quality
thisR.set('filmresolution',[640 480]);
thisR.set('pixelsamples',8);
thisR.integrator.maxdepth.value = 5;

%% Add skymap
piAddSkymap(thisR,'day')

%% Assign Materials and Color
% Check materials read from the file
piMaterialList(thisR);
% assign all the materials according to its name
piMaterialGroupAssign(thisR);
piMaterialList(thisR);

%% Read a geometry file exported by C4d and extract objects information
car_1 = piGeometryRead(thisR);

%% Write out

[~,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','Car_2',[n,e]));
piWrite(thisR);
%%
piGeometryWrite(thisR, car_1);
%% Render irradiance
% tic, scene = piRender(thisR); toc
% ieAddObject(scene); sceneWindow;
