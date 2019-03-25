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

%%
tic
ieInit;
%% Download files from Flywheel, convert .dat into optical image
%{
targetsDir = '/home/zhenyi27/git_repo/iset3d/local/rendering_record/2019';
cd(targetsDir)
targets_list = dir();
targets_list(1:2)=[];
for ii = 1:length(targets_list)
load(targets_list(ii).name);
thisName = strsplit(targets_list(ii).name,'.');


% Open the Flywheel site982abcdhinrsvw
st = scitran('stanfordlabs');
destDir=sprintf('/media/zhenyi27/8474e4a5-2b1b-444a-a496-2b8aee99a4f6/downloads/%s',thisName{1});
if ~exist(destDir,'dir')
    desContents =dir(destDir);
    if ~(length(desContents)>2)
        tic;
        disp('*** Data processing...');
        gcp.fwBatchProcessPBRT('scitran',st,'destination dir',destDir);
        disp('*** Processing finished ***');
        toc;
        % remove *.dat *.json *.txt
        cd(destDir)
        [status, result]=system('rm -r  *.dat *.json *.txt');
        cd(targetsDir)
    end
else
    cd(destDir)
    [status, result]=system('rm -r  *.dat *.json *.txt');
    disp('******Directory exist*******')
    cd(targetsDir)
end
end
%}
%% Process them
rootPath = '/media/zhenyi27/8474e4a5-2b1b-444a-a496-2b8aee99a4f6/downloads';
cd(rootPath)
sceneList = dir();
sceneList(1:2)=[];
% NumImgs = 0;
% check number of idle cores every 5 mins
parfor ii= 1:length(sceneList)
% for ii=1
    fprintf('***********Processing %d********** \n',ii);
    cd(sceneList(ii).name)
    cd 'opticalImages'
    imgList = dir();
    imgList(1:2)=[];
    %     NumImgs = NumImgs+length(imgList);
    numImg = length(imgList);
    sensorImagesDir = fullfile(rootPath,sceneList(ii).name,'sensorImages');
    if ~exist(sensorImagesDir,'dir'),mkdir(sensorImagesDir);end
    for jj = 1:numImg
        oiName = imgList(jj).name;
        oi = load(oiName);
        oi = oi.ieObject;
        % correct for the scene illuminance
        meanIlluminance = 1;
        aperture = oi.optics.focalLength*1e3/oi.optics.fNumber;
        lensArea = pi*(aperture/2)^2;
        meanIlluminance = meanIlluminance*lensArea; 
        oi        = oiAdjustIlluminance(oi,meanIlluminance);
        oi.data.illuminance = oiCalculateIlluminance(oi); 
        
        
        sceneName = strsplit(oi.name,'-');
        sceneName = sceneName{1};
        %% OI to sensor to ip
        % rgb
        rggbDir = fullfile(sensorImagesDir,'rggb');
        oiFilepath = fullfile(rggbDir,[sceneName,'_rggb.mat']);
        if ~exist(rggbDir,'dir'),mkdir(rggbDir);end
        vcimg = piOI2IP(oi,'sensor','MT9V024SensorRGB');
        parsave(oiFilepath,vcimg); 
    end
    %{
    % rccc
    rcccDir = fullfile(sensorImagesDir,'rccc');
    if ~exist(rcccDir,'dir'),mkdir(rcccDir);end
    vcimg = piOI2IP(oi,'sensor','MT9V024SensorRCCC');
    oiFilepath = fullfile(rcccDir,[sceneName,'_rccc.mat']);
    save(oiFilepath,'vcimg');
    % rgbw
    rgbwDir = fullfile(sensorImagesDir,'rgbw');
    if ~exist(rgbwDir,'dir'),mkdir(rgbwDir);end
    vcimg = piOI2IP(oi,'sensor','MT9V024SensorRGBW');
    oiFilepath = fullfile(rgbwDir,[sceneName,'_rgbw.mat']);
    save(oiFilepath,'vcimg');
    % monochrome
    monoDir = fullfile(sensorImagesDir,'mono');
    if ~exist(monoDir,'dir'),mkdir(monoDir);end
    vcimg = piOI2IP(oi,'sensor','MT9V024SensorMono');
    oiFilepath = fullfile(monoDir,[sceneName,'_mono.mat']);
    save(oiFilepath,'vcimg');
    %}
    cd(sceneList(ii).folder)
    close all
end
toc
disp('*********SENSOR CREATION DONE!**********')

%% Visulization
% annotationFig=piBBox2dDraw(rggb);
% saveas(annotationFig,'2dbox.png','png');
% save annotation
% [destDir,sceneName]=fileparts(label);
% sceneName = strrep(sceneName,'_mesh','');
% sceneFigureDir = fullfile(destDir,sceneName);
% classlabel = fullfile(sceneFigureDir,[sceneName,'_class_label.png']);
% imwrite(uint8(ClassMap),classlabel);
% classVisulization = fullfile(sceneFigureDir,[sceneName,'_class_color.png']);
% imwrite(uint8(ClassColorMap),classVisulization);
% instancelabel = fullfile(sceneFigureDir,[sceneName,'_instance_label.png']);
% imwrite(uint16(InstanceMap),instancelabel);
% instanceColor = fullfile(sceneFigureDir,[sceneName,'_instance_color.png']);
% imwrite(uint8(InstanceColorMap),instanceColor);
%% END

