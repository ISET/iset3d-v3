%% Initialize ISET and Docker
ieInit;
%if ~piDockerExists, piDockerConfig; end

%%
assetname = 'Bus_1';

%% Read pbrt_material files
FilePath = fullfile('/Volumes/wandell/data/NN_Camera_Generalization/pbrt_assets/bus',assetname);
fname = fullfile(FilePath,sprintf('%s.pbrt',assetname));
if ~exist(fname,'file'), error('File not found'); end
thisR = piRead(fname,'version',3);

%% Change render quality
% thisR.set('filmresolution',[1080 720]);
% thisR.set('pixelsamples',8);
% thisR.integrator.maxdepth.value = 5;
% thisR.integrator.subtype = 'bdpt';
% thisR.sampler.subtype = 'sobol';
%% Add skymap
% piSkymapAdd(thisR,'day')
%% Assign Materials and Color
piMaterialGroupAssign(thisR);
piMaterialList(thisR);
% use piColorPick to wisely choose a black color.
% thisR.materials.list.NissanTitan_carbody_black_paint_base.colorkd = piColorPick('black');

%% Read a geometry file exported by C4d and extract objects information
car = piGeometryRead(thisR);

%% Write out

[~,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local',assetname,[n,e]));
piWrite(thisR);
%%
piGeometryWrite(thisR, car);

%% zip the folder
folder = fullfile(piRootPath,'local',assetname);
cd(fullfile(piRootPath,'local'));
zip(sprintf('%s.zip',n),folder);

%% Upload to Car acquisition on Flywheel


%% Render irradiance
% tic, scene = piRender(thisR); toc
% ieAddObject(scene); sceneWindow;
