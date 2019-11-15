%% Automatically generate an automotive scene
%
%    t_piRenderFW_cloud
%
% Description:
%   Illustrates (a) the use of ISETCloud, ISET3d, ISETCam and Flywheel to
%   generate driving scenes and ?b) generate stereo camera images by moving
%   camera positions.
%
% Author: Zhenyi, Zheng and Brian Wandell, 2019
%
% See also
%   piSceneAuto, piSkymapAdd, gCloud, SUMO

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if ~mcGcloudExists, mcGcloudConfig; end

%% Open the Flywheel site
st = scitran('stanfordlabs');

%% Initialize your GCP cluster

tic
gcp = gCloud('configuration','cloudRendering-pbrtv3-west1-custom-50-56320-flywheel');

toc
gcp.renderDepth = 1;  % Create the depth map
gcp.renderMesh  = 1;  % Create the object mesh for subsequent use
gcp.targets     =[];  % clear job list

% Print out the gcp parameters for the user
str = gcp.configList;

%% Helpful for debugging
% clearvars -except gcp st thisR_scene
%% Read a scene saved at Flywheel

sceneName = 'city2_14:58_v12.6_f209.08right_o270.00_201962792132';
sessionName = strsplit(sceneName,'_');
sessionName = sessionName{1};
destDir = fullfile(piRootPath,'local',[sessionName,'_',date]);
if ~exist(destDir, 'dir'), mkdir(destDir);end
RecipeName = [sceneName,'.json'];
TargetName = [sceneName,'_target.json'];


thisAcqName =sprintf('wandell/CameraEval20190626/scenes/%s/%s',sessionName,sceneName);
thisAcq = st.fw.lookup(thisAcqName);

thisRecipe = stFileSelect(thisAcq.files,'name',RecipeName);
thisTarget = stFileSelect(thisAcq.files,'name',TargetName);

thisRecipe{1}.download(fullfile(destDir,RecipeName));
thisTarget{1}.download(fullfile(destDir,TargetName));

%% convert downloaded recipe.json to a recipe
thisR_tmp = jsonread(fullfile(destDir,RecipeName));
fds = fieldnames(thisR_tmp);
thisR = recipe;
% assign the struct to a recipe class
for ii = 1:length(fds)
    thisR.(fds{ii})= thisR_tmp.(fds{ii});
end
thisR.materials.lib = piMateriallib;
scene_target = jsonread(fullfile(destDir,TargetName));
fwList = scene_target.fwAPI.InfoList;
road.fwList = fwList;
%% Write out the scene into a PBRT file
thisR.outputFile = fullfile(destDir,[sceneName,'_stereo.pbrt']);

% Do the writing
% Note: piWrite normally needs to copy resources files (textures, geometry files)
% from input folder to output folder, however, we have all the related
% rendering resources saved on flywheel, we do not need to copy anything
% actually, however, in order to be compatible with other version of
% rendering, we provide a fake input file here to avoid errors.
thisR.inputFile = '/tmp/tmp.pbrt';
[~, name, ext] =fileparts(thisR.camera.lensfile.value);
thisR.camera.lensfile.value = fullfile(piRootPath, 'data/lens',[name,ext]);

% CHANGE THE POSITION OF CAMERA HERE:
lookAt = thisR.get('lookAt');
thisR.set('from', lookAt.from + [1;0;0]);

piWrite(thisR,'creatematerials',true,...
    'overwriteresources',false,'lightsFlag',false);
%%
% Upload the information to Flywheel.
gcp.fwUploadPBRT(thisR,'scitran',st,'road',road);

gcp.addPBRTTarget(thisR);
fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));

% Describe the target to the user

gcp.targetsList;
%% This invokes the PBRT-V3 docker image
gcp.render(); 
%% Monitor the processes on GCP

[podnames,result] = gcp.podsList('print',false);
nPODS = length(result.items);
cnt  = 0;
time = 0;
while cnt < length(nPODS)
    % cnt = podSucceeded(gcp);
    cnt = gcp.jobsList;
    pause(60);
    time = time+1;
    fprintf('******Elapsed Time: %d mins****** \n',time)
end

%{
%  You can get a lot of information about the job this way
podname = gcp.podsList
gcp.PodDescribe(podname{1})
 gcp.Podlog(podnames{1});
%}

% Keep checking for the data, every 15 sec, and download it is there
%% Add the original recipe and prepared to download the scene/oi
% This part is ugly written... Better to check with Zhenyi for a more
% elegent way.
thisROrg = thisR.copy;
thisROrg.outputFile = fullfile(destDir, [sceneName, '.pbrt']);
gcpOrg = gcp; % Copy the gcp instance, only for changing the targets
gcpOrg.targets = [];
gcpOrg.addPBRTTarget(thisROrg);

gcpOrg.targetsList;

%% Download files from Flywheel
outputDir = fullfile(destDir, 'renderings');

disp('*** Data downloading...');
% [oi]   = gcp.fwDownloadPBRT('scitran',st);
oi = gcp.fwBatchProcessPBRT('scitran',st,'destination dir',outputDir);
oiOrg = gcpOrg.fwBatchProcessPBRT('scitran',st_tmp,'renderprojectlookup', 'wandell/CameraEval20190626/','destination dir',outputDir);
disp('*** Data downloaded');

%% Show the rendered image using ISETCam
oi = piFireFliesRemove(oi);
oiOrg = piFireFilesRemove(oiOrg);
ieAddObject(oi);
ieAddObject(oiOrg);
oiWindow(oiOrg);

%% Show the rendered image using ISETCam (Not working yet)

% Some of the images have rendering artifiacts.  These are partially
% removed using piFireFliesRemove
%

for ii =1:length(oi)
    oi_corrected{ii} = piFireFliesRemove(oi{ii});
    ieAddObject(oi_corrected{ii}); 
    oiWindow;
    %{
    oiSet(oi_corrected{ii},'gamma',0.75);
%     oiSet(scene_corrected{ii},'gamma',0.85);
    pngFigure = oiGet(oi_corrected{ii},'rgb image');
    figure;
    imshow(pngFigure);
    % Get the class labels, depth map, bounding boxes for ground
    % truth. This usually takes about 15 secs
    tic
    scene_label{ii} = piSceneAnnotation(scene_mesh{ii},label{ii},st);toc
    [sceneFolder,sceneName]=fileparts(label{ii});
    sceneName = strrep(sceneName,'_mesh','');
    irradiancefile = fullfile(sceneFolder,[sceneName,'_ir.png']);
    imwrite(pngFigure,irradiancefile); % Save this scene file

    %% Visualization of the ground truth bounding boxes
    vcNewGraphWin;
    imshow(pngFigure);
    fds = fieldnames(scene_label{ii}.bbox2d);
    for kk = 4
    detections = scene_label{ii}.bbox2d.(fds{kk});
    r = rand; g = rand; b = rand;
    if r< 0.2 && g < 0.2 && b< 0.2
        r = 0.5; g = rand; b = rand;
    end
    for jj=1:length(detections)
        pos = [detections{jj}.bbox2d.xmin detections{jj}.bbox2d.ymin ...
            detections{jj}.bbox2d.xmax-detections{jj}.bbox2d.xmin ...
            detections{jj}.bbox2d.ymax-detections{jj}.bbox2d.ymin];

        rectangle('Position',pos,'EdgeColor',[r g b],'LineWidth',2);
        t=text(detections{jj}.bbox2d.xmin+2.5,detections{jj}.bbox2d.ymin-8,num2str(jj));
       %t=text(detections{jj}.bbox2d.xmin+2.5,detections{jj}.bbox2d.ymin-8,fds{kk});
        t.Color = [0 0 0];
        t.BackgroundColor = [r g b];
        t.FontSize = 15;
    end
    end
    drawnow;
%}
end
sceneWindow;
truesize;

%% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.

% gcp.jobsDelete();

%% END

