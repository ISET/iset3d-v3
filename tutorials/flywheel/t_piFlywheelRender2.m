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
inGroup   = 'wandell';
inProject = 'Graphics test';
inSubject = 'scenes';

% The PBRT outputs will be stored here.  We match the project and
% session and (ultimately) the acquisition labels. We know these are
% the renderings because we change the subject field, calling it
% 'render' where as above the subject field is 'scenes'.
renderGroup   = inGroup;
renderProject = inProject;
renderSubject = 'renderings'; 

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
luString = sprintf('%s/%s/%s',inGroup,inProject,inSubject);

% 'subject' is an object that lets us address the various sessions and
% other properties of the subject.
subject = st.lookup(luString);

% For example, these are the sessions in Zhenyi's data
sessions = subject.sessions();
fprintf('Input has %d sessions\n',numel(sessions))

% In Zhenyi's project sessions are collections of scenes read to
% render.  We will pick the first one.  'thisSession' is another
% scitran object that we can use to find out the information about
% the session.
whichSession = 1;
thisSession = sessions{whichSession};

% Here is the label of the session.
inSession = thisSession.label;
fprintf('Working on scenes in this session: %s\n',inSession);
renderSession = inSession;

%%  Within the session, we have many acquisitions. 

% The acquisitions each represent a single scene that we might render.
% There are a lot of possible scenes, so the read here takes a few
% seconds.
acquisitions = thisSession.acquisitions();
fprintf('Choosing from %d potential scenes\n',numel(acquisitions));

% We pick one acquisition (scene).  'thisAcquisition' is another
% scitran object that can be used to find the files and other
% properties of the scene.
thisAcquisition = 1;
acquisition = acquisitions{thisAcquisition};
fprintf('\n**** Processing the scene: %s **********\n',acquisition.label);
renderAcquisition = acquisition.label;

%% Now we find the files we need to render the scene

% We can find all the files in the acquisition this way
files = acquisition.files;
stPrint(files,'name');

% There are two files we will need that defines the scene properties.
% This one contains information about the assets in the scene.  It has
% the string 'target' in it.
targetFile = stSelect(files,'name','target.json');

% This is the recipe file that instructs PBRT how to render the data.
% We might modify the recipe, say by changing the camera or light or
% other scene properties.
recipeFile = stSelect(files,'name',[renderAcquisition,'.json']);

% Create a folder for this scene with the proper name.  This directory
% is local.
destDir = fullfile(piRootPath,'local',date,inSession);
if ~exist(destDir,'dir'), mkdir(destDir); end

% Download the two json files from Zhenyi's data into our scene folder
recipeName = fullfile(destDir,recipeFile{1}.name);
recipeFile{1}.download(fullfile(destDir,recipeFile{1}.name));
targetFile{1}.download(fullfile(destDir,targetFile{1}.name));

%% Read and modify the JSON files

% The scene recipe with all the graphics information is stored here
% as a recipe
thisR = piJson2Recipe(recipeName);

% The output file for this position
thisR.outputFile = fullfile(destDir,'testRender.pbrt');

% Next TODO:  If you ahve the target then all you should have to do is
% download the target.json file and copy the slots from that JSON file
% into the gcp.fwAPI slots.
%
% Then run gcp.addPBRTTarget with the recipe (thisR)
%
% So this should become a function like this
%
%    gcp.readTarget(targetName);
%
% That loads the JSON target file and sets the gcp parameters.

targetName = fullfile(destDir,targetFile{1}.name);
gcp.readTarget(targetName);

%% Now get ready to process

% Set up the rendering target for the kubernetes process.  The subject
% label changes from 'camera array' to 'renderings'.  But the session,
% acquisition and project remain the same.
gcp.addPBRTTarget(thisR,'subject label',renderSubject);

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