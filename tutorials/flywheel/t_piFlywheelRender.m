%% Read and render a scene that is stored in Flywheel using GCP
%
% Description:
%   This script illustrates the use of ISETCloud, ISET3d, ISETCam and
%   Flywheel to render driving scenes that were assembled and stored
%   in a Flywheel acquisition container. Zhenyi created many such
%   scenes and stored them in the Flywheel in the project
%   CameraEval2019.
%
%   This script shows how to recalculate the rendered scene starting
%   with one such acquisition and using the google cloud platform (GCP).
%
%   We used a variant of this approach to create slight variants of
%   the existing OIs, say by adjusting the camera position a few times
%   for burst photography simulation and for stereo camera simulation.
%
% Dependencies
%  ISETCAM, ISET3D, ISETCLOUD, SCITRAN
% 
% Author: Zhenyi, Zheng and Brian Wandell, 2019
%
% See also
%   t_piAcq2IP, s_piAlignmentRender, s_piStereoImage

%% Initialize ISET and Docker and GCP

% This sets up the GCP, ISETCam and Docker environments from your
% local computer.  For this to run properly, you must have downloaded
% gcloud and kubectl onto your system.
ieGCPInit

%% Set up where we get and put the PBRT files from

% Zhenyi created a large number of scene recipes and scene resources
% in this project.  We start with those as inputs.
inGroup   = 'wandell';
inProject = st.lookup('wandell/Graphics test');
inSubject = 'scenes';
inSession = 'suburb';
inAcquisition = 'city3_11:16_v12.0_f47.50front_o270.00_2019626181423_pos_163_000_000';

% The PBRT outputs will be stored in this acquisition.  We match the
% project and session and (ultimately) the acquisition labels. We mark
% these as renderings by the subject field,
renderProjectID   = inProject.id;
renderSession     = inSession;
renderAcquisition = strcat(date, '-', inAcquisition);
renderSubject     = 'renderings';

%% Main routine - Flywheel files

% The st object interfaces with the Flywheel database.  It has various
% functions (in the scitran repository) that call the Flywheel SDK.

% We need to download the target.json and recipe.json files for the
% scene.  These are in the input acquisition container.  Here we form
% a string, which is like the path to the object.  The function
% fwSceneGet will download the two JSON files.

% This is the string from Zhenyi's project.  The format is
% groupID/projectLabel/subjectLabel
luString = sprintf('%s/%s/%s/%s/%s',...
    inGroup,inProject.label,inSubject,inSession,inAcquisition);

[recipeFile, targetFile, acq] = piFWSceneGetJSON(st,luString);

thisR = piJson2Recipe(recipeFile);

destDir = fullfile(piRootPath, 'local', date);
if ~exist(destDir, 'dir'), mkdir(destDir);
end

% The output file for this position
thisR.outputFile = fullfile(destDir,'testRender.pbrt');

%% Now get ready to process

% Set up the rendering target for the kubernetes process.  The subject
% label changes from 'camera array' to 'renderings'.  But the session,
% acquisition and project remain the same.

% First we clear job list
gcp.targets = [];

% Then we add the target information from the original calculation into the
% Google Cloud object
gcp.addPBRTTarget(targetFile,'subject label',renderSubject);

% Set the Flywheel information for the rendering into the Google Cloud
% object
gcp.fwSet('project id',renderProjectID, ...
    'subject',    renderSubject,...
    'session',    renderSession,...
    'acquisition',renderAcquisition);

project = st.fw.get(gcp.targets(1).fwAPI.projectID);
fprintf('\nData will be rendered into\n  project %s\n  subject: %s\n  session: %s\n  acquisition: %s\n', ...
     project.label, ...
     gcp.targets(1).fwAPI.subjectLabel, ...
     gcp.targets(1).fwAPI.sessionLabel,...
     gcp.targets(1).fwAPI.acquisitionLabel);

% Describe the jobs (targets) to the user
gcp.targetsList;

%% Invoke the PBRT-V3 docker image
gcp.render();

%% When done, check the render using this code
%{

% Find the rendered acquisition.  You must pass the scitran object.
thisAcq = gcp.fwGet('acquisition container','scitran',st);

% Create the OI from the rendered acquisition.  This depends on the
% recipe file having the same name as the spectral radiance file,
% except for the extension
oi = piAcquisition2ISET(thisAcq,st);

% Clean it up and show it nice
oi = piFireFliesRemove(oi);
oiWindow(oi); oiSet(oi,'gamma',0.6); truesize;

%}

%% Only more comments from here to the end

%% Find the session where the data were rendered

% You can get a lot of information about the job this way.  Examining this
% is useful when there is an error.  It is not needed, but watching it
% scroll lets you see what is happening moment to moment.
%{
   podname = gcp.podsList
   gcp.PodDescribe(podname{end})    % Prints out what has happened
   cmd = gcp.Podlog(podname{end});  % Creates a command to show the running log
%}

%{
%
% The fwRender.sh script inside the Docker container places the
% outputs into the subject/session/acquisition specified on the gCloud
% object (see above).
%
% There are also options here to render multiple jobs and to set
% flags about replacing jobs.
%
%    gcp.render('renderList', 1:10, 'replaceJob', 1);
%
% But for this purpose we are just running one 'process on demand'
% (pod).  We will be told whether it is running.

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

% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.
gcp.jobsDelete();

%}

%% END
