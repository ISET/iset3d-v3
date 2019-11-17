%% Replicate a scene that is stored in Flywheel using GCP
%
%    t_piRenderFW_cloud (might rename t_piRender_FW_GCP)
%
% Description:
%   We created many automotive optical images and stored them in
%   Flywheel, particularly in the project CameraEval2019.  This script
%   shows how to recalculate one of these scenes using the google
%   cloud platform (GCP).
%
%   We will use this approach to create slight variants of the
%   existing OIs, say be adjusting the camera position a few times.
%
%   This script illustrates (a) the use of ISETCloud, ISET3d, ISETCam
%   and Flywheel to generate driving scenes, and (b) generate stereo
%   camera images by moving camera positions.
%
% Author: Zhenyi, Zheng and Brian Wandell, 2019
%
% See also
%   piSceneAuto, piSkymapAdd, gCloud

%% Initialize ISET and Docker and GCP

ieInit;
if ~piDockerExists, piDockerConfig; end

% The isetcloud toolbox must be on your path
if ~mcGcloudExists, mcGcloudConfig; end

%% Open a connection to the Flywheel scitran site

% The scitran toolbox must be on your path
st = scitran('stanfordlabs');

%% Initialize the GCP cluster

tic
gcp = gCloud('configuration','cloudRendering-pbrtv3-west1-custom-50-56320-flywheel');

toc
gcp.renderDepth = 1;  % Create the depth map
gcp.renderMesh  = 1;  % Create the object mesh for subsequent use
gcp.targets     = []; % clear job list

%{
 %Print out the gcp parameters for the user if they want it.
 str = gcp.configList;
%}

%% Helpful for debugging
% clearvars -except gcp st thisR_scene

%% Download the two recipes needed to create the scene

% Here is the name of the scene
sceneName = 'city2_14:58_v12.6_f209.08right_o270.00_201962792132';
sessionName = strsplit(sceneName,'_');
sessionName = sessionName{1};

% Here is where we will download it
destDir = fullfile(piRootPath,'local',[sessionName,'_',date]);
if ~exist(destDir, 'dir'), mkdir(destDir);end

% The scene will have a JSON file that describes all of the assets and
% general parameters
RecipeName = [sceneName,'.json'];

% It will have a 2nd JSON file that defines the Flywheel ID values for
% the different assets in the RecipeName
TargetName = [sceneName,'_target.json'];

% The acquisition information is found using the Flywheel
%   group/project/subject/session/acquisition format
thisAcqName =sprintf('wandell/CameraEval20190626/scenes/%s/%s',sessionName,sceneName);
thisAcq = st.fw.lookup(thisAcqName);

% Get the particular files from the acquisition
thisRecipe = stFileSelect(thisAcq.files,'name',RecipeName);
thisTarget = stFileSelect(thisAcq.files,'name',TargetName);

% Download them
thisRecipe{1}.download(fullfile(destDir,RecipeName));
thisTarget{1}.download(fullfile(destDir,TargetName));

%% Convert downloaded recipe.json to a recipe

% Read the recipe containing the assets

%{
 % jsonread returns a struct.  We copy it into a recipe class.  This
 % could be new function.  This could be replaced by the
 % thisR_tmp = jsonread(fullfile(destDir,RecipeName));
fds = fieldnames(thisR_tmp);
thisR = recipe;
for ii = 1:length(fds)
    thisR.(fds{ii})= thisR_tmp.(fds{ii});
end
%}

%  Read the JSON file into the recipe
thisR = piJson2Recipe(fullfile(destDir,RecipeName));

%% We add relevant information to the recipe

% Not sure why the materials library is needed.
thisR.materials.lib = piMateriallib;

% This is information on how to address Flywheel when running on the
% GCP.  The fwAPI has critical information.  That is the only part of
% the target.json file that we use.
scene_target = jsonread(fullfile(destDir,TargetName));

% Here is where the target information is stored.
% The fwAPI is special for when we run using Flywheel on the GCP.
% More explanation needed.
fwList = scene_target.fwAPI.InfoList;
road.fwList = fwList;

%% Adjust the input and output files to match this calculation

% The input file will always be downloaded by the script on the GCP
% from Flywheel.  So the string in the input file does not really
% matter.
% 
% Normally piWrite copies resource files (textures, geometry files)
% from the input to the output folder. But we have the rendering
% resources saved on flywheel, we do not need to copy anything.  We
% denote the Flywheel usage here in the inputFile and we do not call
% piWrite, below.
thisR.inputFile  = fullfile(tempdir,'Flywheel.pbrt');
thisR.outputFile = fullfile(destDir,[sceneName,'_stereo.pbrt']);

%%  This is important and where we will put in a series of positions

[~, name, ext] =fileparts(thisR.camera.lensfile.value);
thisR.camera.lensfile.value = fullfile(piRootPath, 'data/lens',[name,ext]);

% CHANGE THE POSITION OF CAMERA HERE:
% We will write more routines that generate a sequence of positions
% for stereo and for camera moving and so forth in this section.
lookAt = thisR.get('lookAt');
thisR.set('from', lookAt.from + [1;0;0]);

% There is a new camera position that is stored in the <name>_geometry.pbrt
% file.  We write out that geometry file locally, calling it
% <name>_stereo_geometry.pbrt.  This will be part of the new
% information we upload along with the new recipe file.
%
piWrite(thisR,'creatematerials',true,...
   'overwriteresources',false,'lightsFlag',false);

%% Upload the information to Flywheel

% This uploads the modified recipe (thisR), the scitran object, and
% information about where the road data are stored on Flywheel.
gcp.fwUploadPBRT(thisR,'scitran',st,'road',road, ...
    'session name','stereo');

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

% What we want to do is download the radiance output from PBRT that is
% stored on Flywheel as a dat file.  Then we will read it in as an OI
% using this code.
%{
st.fileDownload(filename, ... where to go (outfile));

ieObject = piDat2ISET(outFile,...
                'label','radiance',...
                'recipe',thisR,...
                'scaleIlluminance',scaleIlluminance);
%}

% This part is ugly written... Better to check with Zhenyi for a more
% elegent way.
thisROrg = thisR.copy;
thisROrg.outputFile = fullfile(destDir, [sceneName, '.pbrt']);
gcpOrg = gcp; % Copy the gcp instance, only for changing the targets
gcpOrg.targets = [];
gcpOrg.addPBRTTarget(thisROrg);

gcpOrg.targetsList;

%% Download files from Flywheel

% We will download the relevant .dat file from the PBRT run using
% scitran and then use 
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

