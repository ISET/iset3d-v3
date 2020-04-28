%% Read and render a scene that is stored in Flywheel using GCP
%
%   This script illustrates the use of ISETCloud, ISET3d, ISETCam and
%   Flywheel to render driving scenes that were previously generated.
%
% Description:
%   Zhenyi created many automotive optical images and stored them in
%   Flywheel in the project CameraEval2019.  This script shows how to
%   recalculate one of these scenes using the google cloud platform
%   (GCP).
%
%   We used this approach to create slight variants of the existing
%   OIs, say be adjusting the camera position a few times for burst
%   photography simulation and for stereo camera simulation.
%
% Dependencies
%  ISETCAM, ISET3D, ISETCLOUD, SCITRAN
% 
% Author: Zhenyi, Zheng and Brian Wandell, 2019
%
% See also
%   s_piAlignmentRender, s_piStereoImage, piSceneAuto, piSkymapAdd, gCloud

%% Initialize ISET and Docker and GCP

% This sets up the GCP, ISETCam and Docker environments from your
% local computer.  For this to run properly, you must have downloaded
% gcloud and kubectl onto your system.
ieGCPInit

%% Set up where we get and put the PBRT files from

% Zhenyi created a large number of scene recipes and scene resources
% in this project.  We start with those as inputs.
zhenyiGroup   = 'wandell';
zhenyiProject = 'CameraEval20190626';
zhenyiSubject = 'scenes';

% When we modify them, we put the recipes and scene data here.  These
% modified files will be the new inputs to the PBRT rendering.
sceneGroup   = 'wandell';
sceneProject = 'Graphics camera array';
sceneSubject = 'image alignment';
sceneProjectLU = sprintf('%s/%s',sceneGroup,sceneProject);

% The PBRT outputs will be stored here.  We match the project and
% session and (ultimately) the acquisition labels. We know these are
% the renderings because we change the subject field, calling it
% 'render' where as above the subject field is 'scenes'.
renderGroup   = sceneGroup;
renderProject = sceneProject;
renderSubject = 'render';  % Stereo
% renderSession = sceneSession;

%% Main routine

% The gcp object is part of ISETCloud.  It implements the calls to
% gcloud that manage the Kubernetes jobs and cluster.

% First we clear job list
gcp.targets = [];

% The st object interfaces with the Flywheel database.  It has various
% functions (in the scitran repository) that call the Flywheel SDK.

% st.lookup is a method that lets you find a particular Flywheel
% object. We form a string, which is like the path to the object, in
% luString. In this case we find the 'scenes' in zhenyi's project.

% groupID/projectLabel/subjectLabel
luString = sprintf('%s/%s/%s',zhenyiGroup,zhenyiProject,zhenyiSubject);

% 'subject' is an object that lets us address the various sessions and
% other properties of the subject.
subject = st.lookup(luString);

% For example, these are the sessions in Zhenyi's data
sessions = subject.sessions();
fprintf('Zhenyi has %d sessions\n',numel(sessions))

% In Zhenyi's project sessions are collections of scenes read to
% render.  We will pick the first one.  'thisSession' is another
% scitran object that we can use to find out the information about
% the session.
whichSession = 1;
thisSession = sessions{whichSession};

% Here is the label of the session.
sceneSession = thisSession.label;
fprintf('Working on scenes in this session: %s\n',sceneSession);

%%  Within the session, we have many acquisitions. 

% The acquisitions each represent a single scene that we might render.
% There are a lot of possible scenes, so the read here takes a few
% seconds.
acquisitions = thisSession.acquisitions();
fprintf('Choosing from %d potential scenes\n',numel(acquisitions));

% We pick one acquisition (scene).  'thisAcquisition' is another
% scitran object that can be used to find the files and other
% properties of the scene.
thisAcquisition = 50;
acquisition = acquisitions{thisAcquisition};
zhenyiAcquisition = acquisition.label;
fprintf('\n**** Processing the scene: %s **********\n',zhenyiAcquisition);

% We will set the scene we render by Zhenyi's acquisition name, which
% is the name of his scene.
sceneSession = zhenyiAcquisition;

%% Now we find the files we need to render the scene

% We can find all the files in the acquisition this way
files = acquisition.files;

% There are two files we will need that defines the scene properties.
% This one contains information about the assets in the scene.  It has
% the string 'target' in it.
targetFile = stSelect(files,'name','target.json');

% This is the recipe file that instructs PBRT how to render the data.
% We might modify the recipe, say by changing the camera or light or
% other scene properties.
recipeFile = stSelect(files,'name',[sceneSession,'.json']);

% Create a folder for this scene with the proper name.  This directory
% is local.
destDir = fullfile(piRootPath,'local',date,sceneSession);
if ~exist(destDir,'dir'), mkdir(destDir); end

% Download the two json files from Zhenyi's data into our scene folder
recipeName = fullfile(destDir,recipeFile{1}.name);
recipeFile{1}.download(fullfile(destDir,recipeFile{1}.name));
targetFile{1}.download(fullfile(destDir,targetFile{1}.name));

%% Read and modify the JSON files

% The scene recipe with all the graphics information is stored here
% as a recipe
thisR = piJson2Recipe(recipeName);

% Set some defaults (low res for now)
thisR.set('film resolution',2*[640 360]);
thisR.set('pixel samples',1024);
thisR.set('n bounces',3);

% Add relevant information to the recipe
thisR.materials.lib = piMateriallib;

% This JSON file has information on how to address Flywheel when
% running on the GCP.  The Flywheel API has that critical information.
% That is the only part of the target.json file we use.
targetName = fullfile(destDir,targetFile{1}.name);
scene_target = jsonread(targetName);

% We extract that Flywheel ID information from this slot.
% The fwAPI is special for when we run using Flywheel on the GCP.
fwList = scene_target.fwAPI.InfoList;
road.fwList = fwList;

% The input file will always be downloaded by the script on the GCP
% from Flywheel.  So the string in the input file does not matter
% in this case.
%
% When running locally piWrite copies resource files (textures,
% geometry files) from the input to the output folder. Because the
% assets are on Flywheel, we do not need to copy the assets (input
% files). We denote the Flywheel usage here by assigning the name
% Flywheel.pbrt. But that file does not really exist.
thisR.inputFile  = fullfile(tempdir,'Flywheel.pbrt');

% Set the lens - Sometimes it failed to find a lens file.
if isfield(thisR.camera, 'lensfile')
    [~, name, ext] =fileparts(thisR.camera.lensfile.value);
    thisR.camera.lensfile.value = fullfile(piRootPath, 'data/lens',[name,ext]);
end

%% Change the camera position, and then upload the modified recipe
deltaPosition = [5 5 5];

% You might want to loop, so let's just work with a copy of this
% recipe.
tmpRecipe = thisR.copy;
    
% Store the position shift in millimeters
dLabel = deltaPosition(:)*1e3; % So the label is in millimeters

% The output file for this position
str = sprintf('%s_pos_%03d_%03d_%03d.pbrt',...
    sceneSession,dLabel(1),dLabel(2),dLabel(3));
tmpRecipe.outputFile = fullfile(destDir,str);
    
% WE CHANGE THE POSITION OF CAMERA HERE:
tmpRecipe = piCameraTranslate(tmpRecipe, 'x shift', deltaPosition(1),...
    'y shift', deltaPosition(2),...
    'z shift', deltaPosition(3));
    
% There is a new camera position that is stored in the
% <sceneName_position>.pbrt file.  Everything including the lens file
% must be written with this piWrite.
piWrite(tmpRecipe,'creatematerials',true,...
    'overwriteresources',false,'lightsFlag',false);

% Name the acquisition based on the camera position change
sceneAcquisition = sprintf('pos_%03d_%03d_%03d',dLabel(1),dLabel(2),dLabel(3));

% This uploads the modified recipe (thisR), the scitran object, and
% information about where the road data are stored on Flywheel.
% The render session and subject and acquisition labels are stored
% on the gCloud object.
fprintf('Uploading to the Flywheel session\n');
gcp.fwUploadPBRT(tmpRecipe,'scitran',st,...
    'road',road, ...
    'render project lookup', sceneProjectLU, ...
    'session label',sceneSession, ...
    'subject label',sceneSubject, ...
    'acquisition label',sceneAcquisition);

%% Now get ready to process

% Set up the rendering target for the kubernetes process.  The subject
% label changes from 'camera array' to 'renderings'.  But the session,
% acquisition and project remain the same.
gcp.addPBRTTarget(tmpRecipe,'subject label',renderSubject);

% Describe the jobs (targets) to the user
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

% There are various options here to start up multiple jobs and to set
% flags about replacing jobs.
%
%    gcp.render('renderList', 1:10, 'replaceJob', 1);
%
% But for this purpose we are just running one 'process on demand'
% (pod).  We will be told whether it is running.
gcp.render();

%{
%% Monitor the processes this way

[podnames,result] = gcp.podsList('print',true);

% Wandell could see the process on the GCP this way:
% Under Kubernetes | Workloads
% https://console.cloud.google.com/kubernetes/workload?project=primal-surfer-140120

% This is one way to loop, but it is not very reliable and we don't do
% it all the time
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
%}
%{

%% This is the session where we uploaded the data
sessions = st.search('session',...
    'project label exact',sceneProject,...
    'subject code',renderSubject,...
    'session label',sceneSession, ...
    'fw',true);
acqs = sessions{1}.acquisitions();
stPrint(acqs,'label');
%}
%{
fwDownloadPath = fullfile(piRootPath, 'local', date,'fwDownload');
if ~exist(fwDownloadPath,'dir'), mkdir(fwDownloadPath); end

%% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.

% gcp.jobsDelete();
%}

%% END
%}