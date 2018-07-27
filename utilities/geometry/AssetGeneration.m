%% Initialize ISET and Docker
ieInit;
%if ~piDockerExists, piDockerConfig; end

%%
assetname = 'Car_8';

%% Read pbrt_material files
FilePath = fullfile('/Volumes/group/data/NN_Camera_Generalization/Pbrt_Assets_Generation/pbrt_assets/car',assetname);
% FilePath = pwd;
% FilePath = fullfile('/Volumes/group/data/NN_Camera_Generalization/pbrt_assets/people',lower(assetname));
% fname = '/Volumes/group/data/NN_Camera_Generalization/Pbrt_Assets_Generation/pbrt_assets/car/Car_5/Car_5.pbrt';
fname = fullfile(FilePath,sprintf('%s.pbrt',assetname));
if ~exist(fname,'file'), error('File not found'); end
thisR = piRead(fname,'version',3);

%% Change render quality
thisR.set('filmresolution',[1080 720]);
thisR.set('pixelsamples',8);
thisR.integrator.maxdepth.value = 5;
thisR.integrator.subtype = 'bdpt';
thisR.sampler.subtype = 'sobol';
%% Add skymap
 piSkymapAdd(thisR,'day')
%% Assign Materials and Color
piMaterialGroupAssign(thisR);
piMaterialList(thisR);
% use piColorPick to wisely choose a black color.
% thisR.materials.list.NissanTitan_carbody_black_paint_base.colorkd = piColorPick('black');

%% Write out
[~,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local',assetname,[n,e]));
piWrite(thisR);
%% Upload to Car acquisition on Flywheel
st = scitran('stanfordlabs');
%% zip the folder
folder = fullfile(piRootPath,'local',assetname);
cd(folder);
zip('RenderResource.zip',{'texture','spds','skymaps','scene','brdfs'});

% upload Car_7.json
 
% upload render resources (spds,skymaps,scene, brdfs) as a zip.

%% Render irradiance
% tic, scene = piRender(thisR); toc
% ieAddObject(scene); sceneWindow;
