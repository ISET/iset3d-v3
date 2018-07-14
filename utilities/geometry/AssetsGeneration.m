%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
%% Read pbrt_material files
FilePath = '/Volumes/group/wandell/data/NN_Camera_Generalization/pbrt_assets/car/Car_3';
fname = fullfile(FilePath,'Car_3.pbrt');
if ~exist(fname,'file'), error('File not found'); end
thisR = piRead(fname,'version',3);

%% Change render quality
% thisR.set('filmresolution',[640 480]);
% thisR.set('pixelsamples',8);
% thisR.integrator.maxdepth.value = 5;
%% Add skymap
% piAddSkymap(thisR,'day')
%% Assign Materials and Color
piMaterialGroupAssign(thisR);
piMaterialList(thisR);

%% Read a geometry file exported by C4d and extract objects information
car = piGeometryRead(thisR);

%% Write out

[~,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','Car_3',[n,e]));
piWrite(thisR);
%%
piGeometryWrite(thisR, car);

%% zip the folder
folder = fullfile(piRootPath,'local','Car_3');
zip(sprintf('%s.zip',n),folder);

%% Upload to Car acquisition on Flywheel


%% Render irradiance
% tic, scene = piRender(thisR); toc
% ieAddObject(scene); sceneWindow;
