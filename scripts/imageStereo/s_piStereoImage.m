%% Replicate a scene that is stored in Flywheel using GCP
%
%    s_piStereoImage
%
% Description:
%   We created many automotive optical images and stored them in
%   Flywheel, particularly in the project CameraEval2019.  This script
%   shows how to calculate a stereo pair from those PBRT scenes.  We
%   use the google cloud platform (GCP).
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
%   s_piAlignmentRender, piSceneAuto, piSkymapAdd, gCloud

%% Initialize ISET and Docker and GCP

% This sets up the GCP, ISETCam and Docker for a scene
ieGCPInit

%% Download the two recipes needed to create the scene

% This can become a function to just get the two JSON recipes

% Here an acquisition that contains a scene on Flywheel
sceneGroup   = 'wandell';
sceneProject = 'CameraEval20190626';
sceneSubject = 'scenes';

% st.lookup follows the syntax of:
% groupID/projectLabel/subjectLabel/sessionLabel/acquisitionLabel
luString = sprintf('%s/%s/%s',sceneGroup,sceneProject,sceneSubject);
subject = st.lookup(luString);
sessions = subject.sessions();

gcp.targets     = []; % clear job list

for ii = 1:length(subject.sessions())
    % The inputs are labeled as 'subject' 'scenes'.  In this Project
    % sessions are collections of scenes read to render
    thisSession = sessions{ii};
    acquisitions = thisSession.acquisitions();
    sceneSession = thisSession.label;
    
    % Only use acquisitions in city 3
    if ~strcmp(sceneSession, 'city3')
        continue;
    end
    for jj = 1:length(acquisitions)
        % Each session has a large number of acquisitions that are the
        % scenes.
        acquisition = acquisitions{jj};
        sceneAcquisition = acquisition.label;
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
        % thisR.set('film resolution',[640 360]);
        % thisR.set('pixel samples',1024);
        % thisR.set('n bounces',5);

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

        % This is the project where will store the renderints
        renderProject = 'wandell/Graphics camera array';
        renderSubject = 'camera array';
        renderSession = sceneAcquisition;

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

        % Set the lens - Sometimes it failed to find a lens file.
        if isfield(thisR.camera, 'lensfile')
            [~, name, ext] =fileparts(thisR.camera.lensfile.value);
            thisR.camera.lensfile.value = fullfile(piRootPath, 'data/lens',[name,ext]);
        end
        
        % Specif the change in position vectors
        deltaPosition = [0 0 0; 0.75 0 0]';

        %% Loop and upload the data 
        for pp = 1:size(deltaPosition,2)
            
            tmpRecipe = thisR.copy;
            % Store the position shift in millimeters
            d = deltaPosition(:,pp)*1000;

            % The output file for this position
            str = sprintf('%s_pos_%d_%d_%d.pbrt',sceneAcquisition, d(1),d(2),d(3));
            thisR.outputFile = fullfile(destDir,str);

            tmpRecipe = piCameraTranslate(tmpRecipe,'xAmount', deltaPosition(1,pp),...
                                             'yAmount', deltaPosition(2,pp),...
                                             'zAmount', deltaPosition(3,pp));
            % There is a new camera position that is stored in the
            % <sceneName_position>.pbrt file.  Everything including
            % the lens file should get stored with this piWrite.
            piWrite(tmpRecipe,...
                'overwriteresources',false,'lightsFlag',false);

            % Upload the information to Flywheel
            renderAcquisition = sprintf('pos_%d_%d_%d',d(1),d(2),d(3));

            % This uploads the modified recipe (thisR), the scitran object, and
            % information about where the road data are stored on Flywheel.
            % The render session and subject and acquisition labels are stored
            % on the gCloud object.  
%             gcp.fwUploadPBRT(thisR,'scitran',st,...
%                 'road',road, ...
%                 'render project lookup', renderProject, ...
%                 'session label',renderSession, ...
%                 'subject label',renderSubject, ...
%                 'acquisition label',renderAcquisition);

            % Set up the rendering target.  The subject label changes from
            % 'camera array' to 'renderings'.  But the session, acquisition
            % and project remain the same.
            gcp.addPBRTTarget(tmpRecipe,'subject label','renderings');

            fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));

        end
    end
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
gcp.render('renderList', [401:504], 'replaceJob', 1); 

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

%% Generate and upload the preview image, depth and mesh label images

% Search all the session (scenes)
renderProject = 'Graphics camera array';
luString = sprintf('%s/%s/%s',sceneGroup,renderProject,'renderings');

sessions = st.search('session',...
    'project label exact','Graphics camera array',...
    'subject code','renderings',...
    'fw',true);

fwDownloadPath = fullfile(piRootPath, 'local', date,'fwDownload');
if ~exist(fwDownloadPath,'dir'), mkdir(fwDownloadPath); end

%%
for ii = 1:length(sessions)
    thisSession = sessions{ii};
    acquisitions = thisSession.acquisitions();
    for jj = 1:length(acquisitions)
        thisAcq = acquisitions{jj};
        dlDir = fullfile(fwDownloadPath,...
                [thisSession.label,'_',thisAcq.label]);
        if ~exist(dlDir,'dir'), mkdir(dlDir); end
        for kk = 1:length(thisAcq.files)
            thisFile = thisAcq.files{kk}.name;
            thisAcq.downloadFile(thisFile, fullfile(dlDir, thisFile));
        end
        
        fileRootPath = fullfile(dlDir,...
                        [thisSession.label,'_',thisAcq.label]);
        % Read the radiance file
        iePath = [fileRootPath, '.dat'];
        ieObject = piDat2ISET(iePath,...
                    'label','radiance',...
                    'recipe',thisR,...
                    'scaleIlluminance',false);
        switch ieObject.type
            case 'scene'
                ieObject = sceneSet(ieObject, 'name', [thisSession.label,'_',thisAcq.label]);
                % sceneWindow(ieObject);
%                 ieObject = sceneSet(ieObject,'gamma',0.67);
                ieAddObject(ieObject);
                img = sceneGet(ieObject, 'rgb image');
            case 'opticalimage'
                ieObject = oiSet(ieObject, 'name', [thisSession.label,'_',thisAcq.label]);
                ieObject = piFireFliesRemove(ieObject);
                % oiWindow(ieObject);
%                 ieObject = oiSet(ieObject,'gamma',0.6);
                ieAddObject(ieObject);
                img = oiGet(ieObject, 'rgb image');
        end
        
        img = img.^(1/1.5);
        pngFile = [fileRootPath,'.png'];
        imwrite(img,pngFile);
        
        st.fileUpload(pngFile,thisAcq.id,'acquisition');
        fprintf('%s uploaded \n',pngFile);
        
        % Read the depth file
        iePath = [fileRootPath, '_depth.dat'];
        depth = piDat2ISET(iePath,...
            'label','depth',...
            'recipe',thisR,...
            'scaleIlluminance',false);
        % imagesc(depth);
        depthFile = [fileRootPath,'_depth.mat'];
        save(depthFile, 'depth');

        st.fileUpload(depthFile, thisAcq.id,'acquisition');
        fprintf('%s uploaded \n',depthFile);
        
        % Read the mesh file
        iePath = [fileRootPath, '_mesh.dat'];
        mesh = piDat2ISET(iePath,...
            'label','mesh',...
            'recipe',thisR,...
            'scaleIlluminance',false);
        % imagesc(mesh);
        meshFile = [fileRootPath,'_mesh.mat'];
        save(meshFile, 'mesh');

        st.fileUpload(meshFile, thisAcq.id,'acquisition');
        fprintf('%s uploaded \n',meshFile);
    end
end

close all;
fprintf('Done!');

%% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.

% gcp.jobsDelete();

%% END