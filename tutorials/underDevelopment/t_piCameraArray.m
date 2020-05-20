%% Replicate a single scene that is stored in Flywheel using GCP
%
%    t_piCameraArray 
%
% Description:
%   This script illustrates how to modify a recipe from an existing
%   PBRT scene and then render the modified scene/recipe.
%
%   We created many automotive optical images and stored them in
%   Flywheel, particularly in the project CameraEval2019.  This script
%   shows how to recalculate one of these scenes using the google
%   cloud platform (GCP).
%
%   We used this approach to create slight variants of the existing
%   OIs, say be adjusting the camera position a few times.  See the
%   imageAlignment, imageStereo, and imageResolution folders.
%
%   This script illustrates (a) the use of ISETCloud, ISET3d, ISETCam
%   and Flywheel to generate driving scenes, and (b) generate stereo
%   camera images by moving camera positions.
%
%   Probably needs some more documentation here.
%
% Author: Zhenyi, Zheng and Brian Wandell, 2019
%
% See also
%   piSceneAuto, piSkymapAdd, gCloud

%% Initialize ISET and Docker and GCP

% This sets up the GCP, ISETCam and Docker for a scene
ieGCPInit

%% Download the two recipes needed to create the scene

% This can become a function to just get the two JSON recipes

% Here is an example acquisition that contains a scene on Flywheel
sceneGroup   = 'wandell';
sceneProject = 'Graphics auto renderings';
sceneSubject = 'scenes';
sceneSession = 'city4';
sceneAcquisition = 'city4_9:30_v0.0_f40.00front_o270.00_201952151746';

% This is the project where will store the renderings
renderProject = 'wandell/Graphics camera array';
renderSubject = 'camera array test';
renderSession = sceneAcquisition;

%% Now look up the information on Flywheel

luString = sprintf('%s/%s/%s/%s/%s',sceneGroup,sceneProject,sceneSubject,sceneSession,sceneAcquisition);
acquisition = st.lookup(luString);
files = acquisition.files;
targetFile = stSelect(files,'name','target.json');
recipeFile = stSelect(files,'name',[sceneAcquisition,'.json']);

% Download the JSON files
destDir = fullfile(piRootPath,'local',date,sceneSession);
if ~exist(destDir,'dir'), mkdir(destDir); end
recipeName = fullfile(destDir,recipeFile{1}.name);
recipeFile{1}.download(fullfile(destDir,recipeFile{1}.name));
targetFile{1}.download(fullfile(destDir,targetFile{1}.name));

%% Read the JSON files 

% The scene recipe with all the graphics information is stored here as
% a recipe
thisR = piJson2Recipe(recipeName);

% Set some defaults (low res for now)
thisR.set('film resolution',[640 360]);
thisR.set('pixel samples',256);
thisR.set('n bounces',2);

% Add relevant information to the recipe
thisR.materials.lib = piMateriallib;

% This is information on how to address Flywheel when running on the
% GCP.  The fwAPI has critical information.  That is the only part of
% the target.json file that we use.
targetName = fullfile(destDir,targetFile{1}.name);
scene_target = jsonread(targetName);

% Here is where the target information is stored.
% The fwAPI is special for when we run using Flywheel on the GCP.
% More explanation needed.
fwList = scene_target.fwAPI.InfoList;
road.fwList = fwList;

%%  This is where we define a series of camera positions

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

% Set the lens
[~, name, ext] =fileparts(thisR.camera.lensfile.value);
thisR.camera.lensfile.value = fullfile(piRootPath, 'data/lens',[name,ext]);

% Get the original scene lookAt position
lookAt = thisR.get('lookAt');

% Specify the change in position vectors
deltaPosition = [0 0.03 0; 0 0.07 0]';

%% Loop and upload the data 

gcp.targets     = []; % clear job list

for pp = 1:size(deltaPosition,2)
    
    % Store the position shift in millimeters
    d = deltaPosition(:,pp)*1000;

    % The output file for this position
    str = sprintf('%s_%d_%d_%d.pbrt',sceneAcquisition, d(1),d(2),d(3));
    thisR.outputFile = fullfile(destDir,str);
    
    % CHANGE THE POSITION OF CAMERA HERE:
    % We will write more routines that generate a sequence of positions
    % for stereo and for camera moving and so forth in this section.
    thisR.set('from', lookAt.from + deltaPosition(:,pp));
    thisR.set('to', lookAt.to + deltaPosition(:,pp));
    
    % There is a new camera position that is stored in the
    % <sceneName_position>.pbrt file.
    piWrite(thisR,'creatematerials',true,...
        'overwriteresources',false,'lightsFlag',false);
    
    % Upload the information to Flywheel
    renderAcquisition = sprintf('pos (%d,%d,%d)',d(1),d(2),d(3));
    
    % This uploads the modified recipe (thisR), the scitran object, and
    % information about where the road data are stored on Flywheel.
    % The render session and subject and acquisition labels are stored
    % on the gCloud object.  
    gcp.fwUploadPBRT(thisR,'scitran',st,...
        'road',road, ...
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
sessionLabel = sprintf('wandell/Graphics camera array/camera array/%s',renderSession);
session = st.lookup(sessionLabel);

% Set and update the info from here

%% What are we planning?

% Describe the target to the user
gcp.targetsList;

%% This invokes the PBRT-V3 docker image

% These fwRender.sh script places the outputs into the
% subject/session/acquisition specified on the gCloud object (see
% above).
gcp.render(); 

%% Are the render time stamps set?

%% Monitor the processes on GCP, waiting for them to all succeed

%{
% How many processes-on-demand have been started?  Each is a scene
[podnames,result] = gcp.podsList('print',false);
nPODS = length(result.items);

% Loop waiting for all the PODS to report success.
cnt  = 0;
time = 0;
while cnt < length(nPODS)
    % cnt = podSucceeded(gcp);
    cnt = gcp.jobsList;
    pause(60);
    time = time+1;
    fprintf('******Elapsed Time: %d mins****** \n',time)
end

%}

%% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.

% gcp.jobsDelete();

%% END



