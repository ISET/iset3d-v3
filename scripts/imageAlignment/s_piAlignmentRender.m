%% Replicate a scene that is stored in Flywheel using GCP, moving the camera
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

%% Set up where we get and put the PBRT files from

% Zhenyi created a large number of recipes and scene resources in this
% project.  We start with those data as inputs and modify them.
zhenyiGroup   = 'wandell';
zhenyiProject = 'CameraEval20190626';
zhenyiSubject = 'scenes';

% This is where we put the recipes and scene data that we modify from the
% original Zhenyi data
sceneGroup   = 'wandell';
sceneProject = 'Graphics camera array';
sceneSubject = 'image alignment';
sceneProjectLU = sprintf('%s/%s',sceneGroup,sceneProject);

% This is  where we store the renderings.  We match the project and session
% and (ultimately) the acquisition.  We change the subject by adding
% 'render'.
renderGroup   = sceneGroup;
renderProject = sceneProject;
renderSubject = 'image alignment render';  % Stereo
renderSession = sceneSession;

%% Main routine

% clear job list
gcp.targets = [];

% The scenes are stored in Zhenyi's project as the subject 'scenes', and
% the rendered outputs as the subject of 'render'.
%
% st.lookup for all the sessions with label 'scenes' is this:
% groupID/projectLabel/subjectLabel
luString = sprintf('%s/%s/%s',zhenyiGroup,zhenyiProject,zhenyiSubject);
subject = st.lookup(luString);

% These are the sessions in Zhenyi's data
sessions = subject.sessions();
fprintf('Zhenyi has %d sessions\n',numel(sessions))

%%  Define a series of camera positions and then process

% {
 % Displace the camera by this many meters
 % We want up to 500 millimeters
 x = randi(500,[1,6]);
 y = randi(500,[1,6]);
 z = zeros(size(x));
 deltaPosition = [x;y;z]*1e-3;
%}
%{
 % Displace the camera by this many meters
 % Used for stereo (75 millimeters)
 deltaPosition = [75 0 0]'* 1e-3;  % Puts this in meters
%}
%{
% Render the original with no camera shift
deltaPosition = [0 0 0]';
%}

fprintf('Moving camera to %d positions\n',size(deltaPosition,2));

%% In Zhenyi's data, the acquisitions are the individual scenes.

% The inputs are labeled as 'subject' 'scenes'.  In Zhenyi's project
% sessions are collections of scenes read to render
whichSession = 1;
thisSession = sessions{whichSession};
sceneSession = thisSession.label;
fprintf('Working on scenes in %s\n',sceneSession);

%%
% These are all the scenes for that session
acquisitions = thisSession.acquisitions();

fprintf('Choosing from %d potential scenes\n',numel(acquisitions));
whichAcquisitions = [40 50 60]; % 1:numel(acquisitions)
for jj = whichAcquisitions 
    % jj = whichAcquisitions(1);  % For debugging
    
    acquisition = acquisitions{jj};
    zhenyiAcquisition = acquisition.label;
    fprintf('\n**** Processing %s **********\n',zhenyiAcquisition);
    
    % In our case, the scene name is Zhenyi's acquisition name
    sceneSession = zhenyiAcquisition;
    
    files = acquisition.files;
    targetFile = stSelect(files,'name','target.json');
    recipeFile = stSelect(files,'name',[sceneSession,'.json']);
    
    % Create a folder for this scene
    destDir = fullfile(piRootPath,'local',date,sceneSession);
    if ~exist(destDir,'dir'), mkdir(destDir); end
    
    % Download the two recipe files from Zhenyi's data into our scene
    % folder
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
    
    % This recipe has information on how to address Flywheel when
    % running on the GCP.  The fwAPI has that critical information.
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
    % Normally piWrite copies resource files (textures, geometry files)
    % from the input to the output folder. Because the assets are on
    % Flywheel, we do not need to copy the assets (input files). We
    % denote the Flywheel usage here by assigning the name Flywheel.pbrt.
    % But that file does not really exist.
    thisR.inputFile  = fullfile(tempdir,'Flywheel.pbrt');
    
    % Set the lens - Sometimes it failed to find a lens file.
    if isfield(thisR.camera, 'lensfile')
        [~, name, ext] =fileparts(thisR.camera.lensfile.value);
        thisR.camera.lensfile.value = fullfile(piRootPath, 'data/lens',[name,ext]);
    end
    
    %% Loop on the change in camera positions, uploading the modified recipes
    for pp = 1:size(deltaPosition,2)
        tmpRecipe = thisR.copy;

        % Store the position shift in millimeters
        dLabel = deltaPosition(:,pp)*1e3; % So the label is in millimeters
        
        % The output file for this position
        str = sprintf('%s_pos_%03d_%03d_%03d.pbrt',...
            sceneSession,dLabel(1),dLabel(2),dLabel(3));
        thisR.outputFile = fullfile(destDir,str);
        
        % CHANGE THE POSITION OF CAMERA HERE:
        % We will write more routines that generate a sequence of positions
        % for stereo and for camera moving and so forth in this section.
        tmpRecipe = piCameraTranslate(tmpRecipe, 'xAmount', deltaPosition(1,pp),...
                                             'yAmount', deltaPosition(2,pp),...
                                             'zAmount', deltaPosition(3,pp));

        % There is a new camera position that is stored in the
        % <sceneName_position>.pbrt file.  Everything including
        % the lens file should get stored with this piWrite.
        piWrite(tmpRecipe,...
            'overwriteresources',false,'lightsFlag',false);
        
        % Name the acquisition based on the camera position change
        sceneAcquisition = sprintf('pos_%03d_%03d_%03d',dLabel(1),dLabel(2),dLabel(3));
        
        % This uploads the modified recipe (thisR), the scitran object, and
        % information about where the road data are stored on Flywheel.
        % The render session and subject and acquisition labels are stored
        % on the gCloud object.
        %
        % We put the scenes that will be rendered into the 'image
        % alignment' subject section.  We render the scenes into the
        % 'image alignment render' subject section.  But other than the
        % name of the subject, they should match.
        fprintf('Uploading\n');
        gcp.fwUploadPBRT(tmpRecipe,'scitran',st,...
            'road',road, ...
            'render project lookup', sceneProjectLU, ...
            'session label',sceneSession, ...
            'subject label',sceneSubject, ...
            'acquisition label',sceneAcquisition);
        
        % Set up the rendering target.  The subject label changes from
        % 'camera array' to 'renderings'.  But the session, acquisition
        % and project remain the same.
        gcp.addPBRTTarget(tmpRecipe,'subject label',renderSubject);
        
        fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));
        
    end
    fprintf('\n**** Done with %s **********\n\n',zhenyiAcquisition);

end


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

% gcp.render('renderList', 1:10, 'replaceJob', 1);
gcp.render();

%{
%% Monitor the processes on GCP

[podnames,result] = gcp.podsList('print',true);
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

% Keep checking for the data, every 15 sec, and download if it is there

%% Generate and upload the preview image, depth and mesh label images

% Search all the session (scenes)
luString = sprintf('%s/%s/%s',sceneGroup,renderProject,'renderings');

sessions = st.search('session',...
    'project label exact','Graphics camera array',...
    'subject code','renderings',...
    'fw',true);

fwDownloadPath = fullfile(piRootPath, 'local', date,'fwDownload');
if ~exist(fwDownloadPath,'dir'), mkdir(fwDownloadPath); end

%% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.

% gcp.jobsDelete();

%% END
%}