%% Automatically generate an automotive scene
%
%    t_piSceneAutoGeneration
%
% Description:
%   Illustrates the use of ISETCloud, ISET3d, ISETCam and Flywheel to
%   generate driving scenes.  This example works with the PBRT-V3
%   docker container (not V2).
%
% Author: ZL
%
% See also
%   piSceneAuto, piSkymapAdd, gCloud, SUMO

%{
% Example - let's make a small example to run, if possible.  Say two
cars, no buildings.  If we can make it run in 10 minutes,
that would be good.
%
%}

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if ~mcGcloudExists, mcGcloudConfig; end

%% Open the Flywheel site
st = scitran('stanfordlabs');

%% Initialize your GCP cluster

tic
gcp = gCloud('configuration','cloudRendering-pbrtv3-central-standard-32cpu-120m-flywheel');

toc
gcp.renderDepth = 1;  % Create the depth map
gcp.renderMesh  = 1;  % Create the object mesh for subsequent use
gcp.targets     =[];  % clear job list

% Print out the gcp parameters for the user
gcp.configList;

%% Helpful for debugging
%  thisR_scene

%%  Example scene creation
%
% sceneType = ('city1');
% This is where we pull down the assets from Flywheel and assemble
% them into an asset list.  That is managed in piSceneAuto
tic
sceneType = {'city3','city4','suburb','city1','city2','citymix'};
% roadType = 'cross';
% sceneType = 'highway';
roadType = {'curve_6lanes_001',...
    'straight_2lanes_parking',...
    'city_cross_6lanes_001',...
    'city_cross_6lanes_001_construct',...
    'city_cross_4lanes_002'};
trafficflowDensity = {'low','medium','high'};
for ll = 5 %:length(sceneType)
    % roadType = 'curve_6lanes_001';
    %roadType = 'cross';
    for mm = 3% :length(roadType)
        gcp.targets     =[];
        
        % Choose a timestamp(1~360), which is the moment in the SUMO
        % simulation that we record the data.  This could be fixed or random,
        % and since SUMO runs
        timestamp = [25, 35, 45, 55, 65, 80, 95, 110, 180];
        timestamp = timestamp+randi(12)-randi(12);
        % Normally we want only one scene per generation.
        nScene = 1;
        % Choose whether we want to enable cloudrender
        cloudRender = 1;
        % Return an array of render recipe according to given number of scenes.
        % takes about 100 seconds
        for ii = 1:length(trafficflowDensity)
            st = scitran('stanfordlabs');
            for jj = 1:length(timestamp)
                clear thisR_scene road
                [thisR_scene,road] = piSceneAuto('sceneType',sceneType{ll},...
                    'roadType',roadType{mm},...
                    'trafficflowDensity',trafficflowDensity{ii},...
                    'timeStamp',timestamp(jj),...
                    'nScene',nScene,...
                    'cloudRender',cloudRender,...
                    'scitran',st);
                toc
                thisR_scene.metadata.sumo.trafficflowdensity = trafficflowDensity{ii};
                thisR_scene.metadata.sumo.timestamp          = timestamp(jj);

                %% Render parameters
                
                xRes = 1920;
                yRes = 900;
                pSamples = 256;
                thisR_scene.set('film resolution',[xRes yRes]);
                thisR_scene.set('pixel samples',pSamples);
                % thisR_scene.set('fov',45);
                thisR_scene.film.diagonal.value=10;
                thisR_scene.film.diagonal.type = 'float';
                thisR_scene.integrator.maxdepth.value = 5;
                thisR_scene.integrator.subtype = 'bdpt';
                thisR_scene.sampler.subtype = 'sobol';
                thisR_scene.integrator.lightsamplestrategy.type = 'string';
                thisR_scene.integrator.lightsamplestrategy.value = 'spatial';
                
                
                %% create a realistic camera
                % lensfiles = dir('*.dat');
                %%
                % for ii = 1:35
                lensname = 'wide.56deg.6.0mm.dat';
                thisR_scene.camera = piCameraCreate('realistic','lensFile',lensname,'pbrtVersion',3);
                % thisR_scene.camera = piCameraCreate('perspective','pbrtVersion',3);
                
                %% Add a camera to one of the cars
                %
                tmp=load(fullfile(piRootPath,'local','trafficflow',sprintf('%s_%s_trafficflow.mat',road.name,trafficflowDensity{ii})),'trafficflow');
                trafficflow = tmp.trafficflow;
                thisTrafficflow = trafficflow(timestamp(jj));
                nextTrafficflow = trafficflow(timestamp(jj)+1);
                %
                CamOrientation =[300,270,270,270,180,0,90,90,120];
                for kk = 1:length(CamOrientation)
                    % Add a random camera orientation offset.
                    oriOffset = (rand(1)-rand(1))*15;
                    camPos = {'left','right','front','rear'};
                    camPos = camPos{randi(4,1)};
%                     camPos = camPos{4};
                    [thisCar,from,to,ori] = piCamPlace('thistrafficflow',thisTrafficflow,...
                                                     'CamOrientation',CamOrientation(kk),...
                                                     'thisR',thisR_scene,'camPos',camPos,...
                                                     'oriOffset',oriOffset);
                    if ~isempty(thisCar)
                        thisR_scene.lookAt.from = from;
                        thisR_scene.lookAt.to   = to;
                        thisR_scene.lookAt.up = [0;1;0];
                        % Will write a function to select a certain speed, now just manually check
                        % give me z axis smaller than 110;
                        %%
                        thisR_scene = piMotionBlurEgo(thisR_scene,'nextTrafficflow',nextTrafficflow,...
                            'thisCar',thisCar,...
                            'fps',60);
                        %% Add a skymap and add SkymapFwInfor to fwList
                        if randi(30,1)==1
                            index = randi(4,1);
                            skynamelist = {'morning','noon','sunset','cloudy'};
                            dayTime = skynamelist{index};
                        else
                            dayTime = sprintf('%02d:%02d',randi(11,1)+6,randi(60,1)-1);
                        end
                        [thisR_scene,skymapfwInfo] = piSkymapAdd(thisR_scene,dayTime);
                        road.fwList = [road.fwList,' ',skymapfwInfo];
                        %% Write out the file
                        if contains(sceneType{ll},'city')
                            outputDir = fullfile(piRootPath,'local',strrep(road.roadinfo.name,'city',sceneType{ll}));
                            thisR_scene.inputFile = fullfile(outputDir,[strrep(road.roadinfo.name,'city',sceneType{ll}),'.pbrt']);
                        else
                            outputDir = fullfile(piRootPath,'local',strcat(sceneType{ll},'_',road.name));
                            thisR_scene.inputFile = fullfile(outputDir,[strcat(sceneType{ll},'_',road.name),'.pbrt']);
                        end
                        
                        if ~exist(outputDir,'dir'), mkdir(outputDir); end
                        filename = sprintf('%s_%s_v%0.1f_f%0.2f%s_o%0.2f_%i%i%i%i%i%0.0f.pbrt',...
                            sceneType{ll},dayTime,thisCar.speed,thisR_scene.lookAt.from(3),camPos,ori,clock);
                        thisR_scene.outputFile = fullfile(outputDir,filename);
                        
                        
                        piWrite(thisR_scene,'creatematerials',true,...
                            'overwriteresources',false,'lightsFlag',false,...
                            'thistrafficflow',thisTrafficflow);
                        
                        gcp.fwUploadPBRT_local(thisR_scene,'scitran',st,'road',road);
                        
                        addPBRTTarget(gcp,thisR_scene);
                        fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));
                        
                        gcp.targetsList;
                    end
                end
            end
        end
        disp('******All scenes are generated*****');
        %% save gcp.targets as a txt file so that I can read from gcp
        filePath_record = '/Users/zhenyiliu/Google Drive (zhenyi27@stanford.edu)/rendering_record/';
        DateString=strrep(strrep(strrep(datestr(datetime('now')),' ','_'),':','_'),'-','_');
        save([filePath_record,sceneType{ll},'_',roadType{mm},'_',DateString,'.mat'],'gcp');
        disp('************gcp targets saved***********')
    end
end
toc
%% This invokes the PBRT-V3 docker image
% gcp.render();
%% Monitor the processes on GCP
%{
[podnames,result] = gcp.Podslist('print',false);
nPODS = length(result.items);
cnt  = 0;
time = 0;
[jobnames,result] = gcp.Jobslist('print',false);
nJobs = length(result.items);
while cnt < length(nPODS)
    cnt = podSucceeded(gcp);
    pause(60);
    time = time+1;
    fprintf('******Elapsed Time: %d mins****** \n',time);
end

%{
%  You can get a lot of information about the job this way
podname = gcp.Podslist
gcp.PodDescribe(podname{1})
 gcp.Podlog(podname{1});
%}


%% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.

% gcp.JobsRmAll();
%}
%% END

