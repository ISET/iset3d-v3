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
% Choose whether we want to enable cloudrender
cloudRender = 1;
% Print out the gcp parameters for the user
gcp.configList;

%%  Example scene creation
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
%%
gcp.targets = [];
for ll = 1:length(sceneType)
    for mm = 1 :length(roadType)
        % Choose a timestamp(1~360), which is the moment in the SUMO
        % simulation that we record the data. 
        timestamp = randi([10,350],[1,6]);% total number of images: 6x5x3x9 = 3600
        % Return an array of render recipe according to given number of scenes.
        % takes about 100 seconds
        for ii = 1:length(trafficflowDensity)
            
            for jj = 1:length(timestamp)
                clear thisR_scene road
                
                [thisR,road] = piSceneAuto('sceneType',sceneType{ll},...
                    'roadType',roadType{mm},...
                    'trafficflowDensity',trafficflowDensity{ii},...
                    'timeStamp',timestamp(jj),...
                    'cloudRender',cloudRender,...
                    'scitran',st);
                
                thisR.metadata.sumo.trafficflowdensity = trafficflowDensity{ii};
                thisR.metadata.sumo.timestamp          = timestamp(jj);

                %% Render parameters
                
                xRes = 1280;
                yRes = 720;
                pSamples = 64;
                
                thisR.set('film resolution',[xRes yRes]);
                thisR.set('pixel samples',pSamples);
                thisR.film.diagonal.value = 10;
                thisR.film.diagonal.type = 'float';
                thisR.integrator.maxdepth.value = 10;
                thisR.integrator.maxdepth.type = 'integer';
                thisR.sampler.subtype = 'sobol';
                                
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
                    camPos = {'right','front','rear','front','front','front','rear'};
                    camPos = camPos{randi(7,1)};
                    [thisCar, thisR] = piCamPlace('thistrafficflow',thisTrafficflow,...
                                                     'CamOrientation',CamOrientation(kk),...
                                                     'thisR',thisR,'camPos',camPos,...
                                                     'oriOffset',oriOffset);
                    if ~isempty(thisCar)
                        % Will write a function to select a certain speed, now just manually check
                        % give me z axis smaller than 110;
                        %%
                        thisR = piMotionBlurEgo(thisR,'nextTrafficflow',nextTrafficflow,...
                            'thisCar',thisCar,...
                            'fps',60);
                        %% Add a skymap and add SkymapFwInfor to fwList
                        
                        dayTime = sprintf('%02d:%02d',randi(11,1)+6,randi(60,1)-1);
                        [thisR, skymapfwInfo] = piSkymapAdd(thisR,dayTime);
                        
                        road.fwList = [road.fwList,' ',skymapfwInfo];
                        % set inputFile
                        if contains(sceneType{ll},'city')
                            outputDir = fullfile(piRootPath,'local',strrep(road.roadinfo.name,'city',sceneType{ll}));
                            thisR.inputFile = fullfile(outputDir,[strrep(road.roadinfo.name,'city',sceneType{ll}),'.pbrt']);
                        else
                            outputDir = fullfile(piRootPath,'local',strcat(sceneType{ll},'_',road.name));
                            thisR.inputFile = fullfile(outputDir,[strcat(sceneType{ll},'_',road.name),'.pbrt']);
                        end
                        
                        if ~exist(outputDir,'dir'), mkdir(outputDir); end
                        
                        % Makes the materials, particularly glass, look right.
                        piMaterialGroupAssign(thisR);
                        %% Experiemnt setting
                        % set default paramters
                        expSet.daytime = dayTime;
                        expSet.sceneType = sceneType{ll};
                        expSet.materialType = 'realisticMat';
                        expSet.skyType = 'hdr';
                        expSet.motion = 'motion'; 
                        lensType = {'pinhole','thinlens','realistic'};
                        expSet.clock = clock;
                        for gg = 1:length(lensType)
                            lens = lensType{gg};
                            switch lens
                                case 'pinhole'
                                     % lens setting
                                    thisR.camera.subtype = 'perspective';
                                    thisR.set('fov', 45);
                                    expSet.lens = 'pinhole';
                                    % First File (realiscMat+motion+hdr)
                                    [thisR, gcp] = saveFile(thisR, expSet, gcp, thisTrafficflow, road, st);
                                    % Second File (HDR lighting replaced with simple lighting)
                                    expSet.skyType = 'simple';
                                    lightR = piRecipeCopy(thisR);
                                    lightR = simpleLighting(lightR);
                                    % write out
                                    [lightR, gcp] = saveFile(lightR, expSet, gcp, thisTrafficflow, road, st);
                                    
                                    % Third File (HDR lighting and motion removed)
                                    expSet.motion = 'static';
                                    motionR = motionRemove(lightR);
                                    % write out
                                    [motionR, gcp] = saveFile(motionR, expSet, gcp, thisTrafficflow, road, st);
                                    
                                    % Fourth File (HDR lighting, motion and realisticMat removed)
                                    expSet.materialType = 'simpleMat';
                                    matteR = simpleMat(motionR);
                                    % write out
                                    [matteR, gcp] = saveFile(matteR, expSet, gcp, thisTrafficflow, road, st);
                                    
                                    % Fifth File (HDR lighting, motion and nocolor material removed)
                                    expSet.materialType = 'nocolorMat';
                                    colorR = colorRemove(matteR);
                                    % write out
                                    [colorR, gcp] = saveFile(colorR, expSet, gcp, thisTrafficflow, road, st);
                                    
                                    
                                case 'thinlens'
                                    % lens setting
                                    expSet.materialType = 'realisticMat';
                                    expSet.skyType = 'hdr';
                                    expSet.motion = 'motion';
                                    thisR.camera.subtype = 'perspective';
                                    thisR.set('fov', 45);
                                    expSet.lens = 'thinlens';
                                    thisR.camera.focaldistance.value = 10; % take meters
                                    % focal length=6mm; fnumber=2.5
                                    thisR.camera.lensradius.value = 1.2*1e-3; % meters 
                                    thisR.camera.focaldistance.type = 'float';
                                    thisR.camera.lensradius.type = 'float';
                                    
                                    [thisR, gcp] = saveFile(thisR, expSet, gcp, thisTrafficflow, road, st);
                                case 'realistic'
                                     % lens setting
                                    expSet.materialType = 'realisticMat';
                                    expSet.skyType = 'hdr';
                                    expSet.motion = 'motion';
                                    expSet.lens = 'realistic';
                                    lensname = 'wide.56deg.6.0mm.dat';
                                    RealCam = piCameraCreate('realistic','lensFile',lensname);
                                    thisR.camera.subtype = RealCam.subtype;
                                    thisR.camera.lensfile = RealCam.lensfile;
                                    thisR.camera.aperturediameter = RealCam.aperturediameter;
                                    thisR.camera.focusdistance = RealCam.focusdistance;
                                    % write out
                                    [thisR, gcp] = saveFile(thisR, expSet, gcp, thisTrafficflow, road, st);
                            end
                        end
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
[podnames,result] = gcppodslist('print',false);
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
podname = gcp.podsList
gcp.PodDescribe(podname{1})
 gcp.Podlog(podname{1});
%}


%% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.

% gcp.jobsDelete()
%}
%% upload local folder to flywheel project
cd('/Users/zhenyi/git_repo/iset3d/local');
cmd = '/Users/zhenyi/Downloads/darwin_amd64/fw import folder FORUPLOAD -j 16';
system(cmd);
%% 
destDir = fullfile(outputDir,'renderings');

disp('Downloading PBRT dat and converting to ISET...');
% This function creates two subfolder in the output folder renderings: 
% OIpngPreviews contains a png file directly from Optical Image.
% opticalImages contains Optical Image object in .mat format.
ieObject = gcp.fwBatchProcessPBRT('scitran',st,'destination dir',destDir);
disp('*** Downloaded ieObject')
%% END
%% create children function
function [thisR, gcp] = saveFile(thisR, expSet, gcp, thisTrafficflow, road, st)
expSet.daytime = strrep(expSet.daytime, ':','_');
filename = sprintf('%s_%s_%s_%s_%s_%s_%i%i%i%i%i%0.0f.pbrt',...
    expSet.sceneType,...
    expSet.daytime,...
    expSet.skyType,...
    expSet.lens,...
    expSet.materialType,...
    expSet.motion,...
    expSet.clock);

outputDir = fileparts(thisR.inputFile);
thisR.outputFile = fullfile(outputDir,filename);

piWrite(thisR,'creatematerials',true,...
    'overwriteresources',false,'lightsFlag',false,...
    'thistrafficflow',thisTrafficflow);

gcp.fwUploadPBRT_local(thisR,'scitran',st,'road',road);

addPBRTTarget(gcp,thisR);
fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));

gcp.targetsList;

end

function colorR = colorRemove(thisR)
% convert all material surfaces to be gray
colorR = piRecipeCopy(thisR);
materialNameList = fieldnames(thisR.materials.list);
for ii = 1:length(materialNameList)
    target = colorR.materials.lib.matte;
    piMaterialAssign(colorR, ...
        materialNameList{ii}, target,...
        'rgbkd',[0.5 0.5 0.5],...
        'colorkd',[0.5 0.5 0.5]);
end

end

function matteR = simpleMat(thisR)
% convert all material to be matte material
matteR = piRecipeCopy(thisR);
materialNameList = fieldnames(thisR.materials.list);
for ii = 1:length(materialNameList)
    target = matteR.materials.lib.matte;
    piMaterialAssign(matteR, ...
        materialNameList{ii}, target);
end

end

function motionR = motionRemove(thisR)
% remove all motion effect
motionR = piRecipeCopy(thisR);
for ii = 1:length(thisR.assets)
    thisR.assets(ii).motion = [];
end

if isfield(thisR.camera, 'motion')
    thisR.camera.motion.activeTransformEnd.pos = thisR.camera.motion.activeTransformStart.pos;
    thisR.camera.motion.activeTransformEnd.rotate = thisR.camera.motion.activeTransformStart.rotate;
end

end

function lightR = simpleLighting(thisR)
% replace hdr skymap with color skymap
lightR = piRecipeCopy(thisR);
lightR = piLightDelete(lightR, 'all');
blackbody = randi([4500,6500],1);
position = [-30 40 100];
position(1) = position(1)+randi([-40,40],1);
position(3) = position(3)+randi([-40,40],1);
lightR = piLightAdd(lightR, 'type','infinite',...
    'rgbSpectrum',[0.6 0.7 0.8]);
lightR = piLightAdd(lightR, 'type','distant',...
    'blackbody',[blackbody, 1.5],...
    'from', position);
end



