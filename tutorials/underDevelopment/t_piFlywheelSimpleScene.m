% t_piFlywheelSimpleScene

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

% This sets up the GCP, ISETCam and Docker for a scene
ieGCPInit

%% Read the file

% The teapot is our test file
inFile = fullfile(piRootPath,'data','V3','checkerboard','checkerboard.pbrt');
thisR = piRead(inFile);

% The output will be written here
sceneName = 'checkerboard';
outFile = fullfile(piRootPath,'local',sceneName,'checkerboard.pbrt');
thisR.set('outputFile',outFile);

%% Set up the render quality

% There are many different parameters that can be set.
thisR.set('film resolution',[192 192]);
thisR.set('pixel samples',128);
thisR.set('nbounces',2); % Number of bounces

% Add relevant information to the recipe
thisR.materials.lib = piMateriallib;

%%  This is where we define a series of camera positions

% This is the project where will store the renderints
renderProject = 'wandell/Graphics camera array';
renderSubject = 'simple test';
renderSession = 'checkerboard';

%% Write out the recipe for cgresources
piWrite(thisR,'creatematerials',true);

%% Upload the assets to FW for fwInfoList
rFolder = fullfile(piRootPath, 'local', sceneName);
folder = fullfile(piRootPath, 'local', sceneName, 'upload');
if ~exist(folder, 'dir'), mkdir(folder); end

resourceFile = fullfile(folder, sprintf('%s.cgresource.zip', sceneName));

zip(resourceFile,{fullfile(rFolder, 'textures'),fullfile(rFolder, 'scene')});
oldRecipeFile = fullfile(rFolder, sprintf('%s.json', sceneName));
recipeFile = fullfile(folder, sprintf('%s.recipe.json', sceneName));
copyfile(oldRecipeFile, recipeFile);

% Render a pngfile
[scene, ~] = piRender(thisR, 'rendertype', 'radiance');
pngFigure = sceneGet(scene,'rgb image');
pngFile = pngFigure.^(1/1.5); % for Tree, too dark.
figure;
imshow(pngFile);
pngfile = fullfile(folder, sprintf('%s.png',sceneName));
imwrite(pngFile,pngfile);

%% Upload the cgresource.zip and .json file

current_id = st.containerCreate('Wandell Lab', 'Graphics auto',...
            'session', renderSession, 'acquisition', sceneName,...
            'subject', 'assets');
st.fileUpload(recipeFile, current_id.acquisition, 'acquisition');
fprintf('%s uploaded \n',recipeFile);
st.fileUpload(resourceFile, current_id.acquisition, 'acquisition');
fprintf('%s uploaded \n',resourceFile);
st.fileUpload(pngfile,current_id.acquisition,'acquisition');
fprintf('%s uploaded \n',pngfile);

%% Upload the road.fwList
% Syntax is: Group/Project/Subject/Session/Acquisition
data_acq = st.fw.lookup(fullfile('wandell/Graphics auto/assets', sceneName, sceneName));
road.fwList = [data_acq.id,' ',[sceneName,'.cgresource.zip']];
%%
% The input file will always be downloaded by the script on the GCP
% from Flywheel.  So the string in the input file does not really
% matter.
% 
% Normally piWrite copies resource files (textures, geometry files)
% from the input to the output folder. Because the assets are on
% Flywheel, we do not need to copy the assets (input files). We 
% denote the Flywheel usage here by assigning the name Flywheel.pbrt.
% But that file does not really exist.
thisR.inputFile  = fullfile(tempdir,'Flywheel.pbrt');

% Get the original scene lookAt position
lookAt = thisR.get('lookAt');

% Specif the change in position vectors
deltaPosition = [0 0.03 0; 0 0.07 0];

%%
destDir = fullfile(piRootPath,'local',date,renderSession);
if ~exist(destDir,'dir'), mkdir(destDir); end
%% Loop and upload the data 

gcp.targets     = []; % clear job list

renderAcqList = {};
outputFileList = {};

for pp = 1:size(deltaPosition,1)
    
    % Store the position shift in millimeters
    d = deltaPosition(pp,:)*1000;

    % The output file for this position
    str = sprintf('%s_%d_%d_%d.pbrt',sceneName, d(1),d(2),d(3));
    thisR.outputFile = fullfile(destDir,str);
    [~,acqLabel] = fileparts(thisR.outputFile);
    outputFileList{pp} = acqLabel;
    % CHANGE THE POSITION OF CAMERA HERE:
    % We will write more routines that generate a sequence of positions
    % for stereo and for camera moving and so forth in this section.
    thisR.set('from', lookAt.from + deltaPosition(pp,:));
    
    % There is a new camera position that is stored in the
    % <sceneName_position>.pbrt file.
    piWrite(thisR,'creatematerials',true,...
        'overwriteresources',false,'lightsFlag',false);
    
    % Upload the information to Flywheel
    renderAcquisition = sprintf('pos_%d_%d_%d',d(1),d(2),d(3));
    renderAcqList{pp} = renderAcquisition;
    
    % This uploads the modified recipe (thisR), the scitran object, and
    % information about where the road data are stored on Flywheel.
    % The render session and subject and acquisition labels are stored
    % on the gCloud object.  
    gcp.fwUploadPBRT(thisR,'scitran',st,...
        'road', road,...
        'render project lookup', renderProject, ...
        'session label',renderSession, ...
        'subject label',renderSubject, ...
        'acquisition label',renderAcquisition);
    
    % Set up the rendering target.  The subject label changes from
    % 'camera array' to 'renderings'.  But the session, acquisition
    % and project remain the same.
    gcp.addPBRTTarget(thisR,'subject label','renderings test');
    
    fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));
    
end

%% Set the session time stamp
sessionLabel = sprintf('wandell/Graphics camera array/%s/%s',renderSubject,renderSession);
session = st.lookup(sessionLabel);

% Set and update the info from here


%% What are we planning?

% Describe the target to the user
gcp.targetsList;

% You can get a lot of information about the job this way.  Examining this
% is useful when there is an error.  It is not needed, but watching it
% scroll lets you see what is happening moment to moment.
%{   
   podname = gcp.podsList
   gcp.PodDescribe(podname{end})    % Prints out what has happened
   cmd = gcp.Podlog(podname{end});  % Creates a command to show the running log
%}

%% This invokes the PBRT-V3 docker image

% These fwRender.sh script places the outputs into the
% subject/session/acquisition specified on the gCloud object (see
% above).
gcp.render(); 

%% Are the render time stamps set?

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

% Keep checking for the data, every 15 sec, and download it is there
%% Add the original recipe and prepared to download the scene/oi

% What we want to do is download the radiance output from PBRT that is
% stored on Flywheel as a dat file.  Then we will read it in as an OI
% using this code.

renderAcq = st.search('acquisition',...
    'project label exact','Graphics camera array',...
    'subject code','renderings test',...
    'session label','checkerboard',...
    'acquisition label contains',renderAcqList{1},...
    'fw',true);
rAcq = renderAcq{1};
savePathTar = fullfile(destDir,'renderings',[sceneName,'.tar']);
rAcq.downloadTar(fullfile(destDir,'renderings',[sceneName,'.tar']));

% Unzip the tar file and display it
untar(savePathTar,'left');

ieRootPath = fullfile(destDir,'renderings','left','scitran',renderProject,...
    'renderings test', sceneName, renderAcqList{1});

iePath = fullfile(ieRootPath, [outputFileList{1},'.dat']);


% Read radiance type
ieObject = piDat2ISET(iePath,...
    'label','radiance',...
    'recipe',thisR,...
    'scaleIlluminance',false);

switch ieObject.type
    case 'scene'
        sceneWindow(ieObject);
        img = sceneGet(ieObject, 'rgb image');
    case 'optical image'
        oiWindow(ieObject);
        img = oiGet(ieObject, 'rgb image');
end

img = img.^(1/1.5);
pngFile = fullfile(ieRootPath, [outputFileList{1},'.png']);
imwrite(img,pngfile);

st.fileUpload(pngfile,rAcq.id,'acquisition');
fprintf('%s uploaded \n',pngfile);

% Read depth radiance image
iePath = fullfile(ieRootPath, [outputFileList{1},'_depth.dat']);
depth = piDat2ISET(iePath,...
    'label','depth',...
    'recipe',thisR,...
    'scaleIlluminance',false);
imagesc(depth);
depthFile = fullfile(ieRootPath, [outputFileList{1},'_depth.mat']);
save(depthFile, 'depth');

st.fileUpload(depthFile, rAcq.id,'acquisition');
fprintf('%s uploaded \n',depthFile);

% Read mesh type
iePath = fullfile(ieRootPath, [outputFileList{1},'_mesh.dat']);
mesh = piDat2ISET(iePath,...
    'label','mesh',...
    'recipe',thisR,...
    'scaleIlluminance',false);
imagesc(mesh);
meshFile = fullfile(ieRootPath, [outputFileList{1},'_mesh.mat']);
save(meshFile, 'mesh');

st.fileUpload(meshFile, rAcq.id,'acquisition');
fprintf('%s uploaded \n',meshFile);

%% Add the corresponding scene

renderAcq = st.search('acquisition',...
    'project label exact','Graphics camera array',...
    'subject code','renderings test',...
    'session label','checkerboard',...
    'acquisition label contains',renderAcqList{2},...
    'fw',true);
rAcq = renderAcq{1};
savePathTar = fullfile(destDir,'renderings',[sceneName,'_2.tar']);
rAcq.downloadTar(fullfile(destDir,'renderings',[sceneName,'_2.tar']));

% Unzip the tar file and display it
untar(savePathTar,'right');

ieRootPath = fullfile(destDir,'renderings','right','scitran',renderProject,...
    'renderings test', sceneName, renderAcqList{2});

iePath = fullfile(ieRootPath, [outputFileList{2},'.dat']);


% Read radiance type
ieObject = piDat2ISET(iePath,...
    'label','radiance',...
    'recipe',thisR,...
    'scaleIlluminance',false);

switch ieObject.type
    case 'scene'
        sceneWindow(ieObject);
        img = sceneGet(ieObject, 'rgb image');
    case 'optical image'
        oiWindow(ieObject);
        img = oiGet(ieObject, 'rgb image');
end

img = img.^(1/1.5);
pngFile = fullfile(ieRootPath, [outputFileList{2},'.png']);
imwrite(img,pngfile);

st.fileUpload(pngfile,rAcq.id,'acquisition');
fprintf('%s uploaded \n',pngfile);

% Read depth radiance image
iePath = fullfile(ieRootPath, [outputFileList{2},'_depth.dat']);
depth = piDat2ISET(iePath,...
    'label','depth',...
    'recipe',thisR,...
    'scaleIlluminance',false);
imagesc(depth);
depthFile = fullfile(ieRootPath, [outputFileList{2},'_depth.mat']);
save(depthFile, 'depth');

st.fileUpload(depthFile, rAcq.id,'acquisition');
fprintf('%s uploaded \n',depthFile);

% Read mesh type
iePath = fullfile(ieRootPath, [outputFileList{2},'_mesh.dat']);
mesh = piDat2ISET(iePath,...
    'label','mesh',...
    'recipe',thisR,...
    'scaleIlluminance',false);
imagesc(mesh);
meshFile = fullfile(ieRootPath, [outputFileList{2},'_mesh.mat']);
save(meshFile, 'mesh');

st.fileUpload(meshFile, rAcq.id,'acquisition');
fprintf('%s uploaded \n',meshFile);

%% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.

% gcp.jobsDelete();

%% END