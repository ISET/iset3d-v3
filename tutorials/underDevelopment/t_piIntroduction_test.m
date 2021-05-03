%% Uses Flywheel to get a skymap; also uses special scene materials
%
% We store many graphics assets in the Flywheel database.  This script
% shows how to download a file from Flywheel.  This technique is used
% much more extensively in creating complex driving scenes.
%
% This example scene also includes glass and other materials that
% were created for driving scenes.  The script sets up the glass
% material and number of bounces to make the glass appear reasonable.
%
% It also uses piMaterialsGroupAssign() to set a list of materials (in
% this case a mirror) that are part of the scene.
%
% Dependencies:
%
%    ISET3d, ISETCam or ISETBio, JSONio, SCITRAN, Flywheel Add-On (at
%    least version 4.3.2) 
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntroduction01, t_piIntroduction02


%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
% if ~piScitranExists, error('scitran installation required'); end

%% Read pbrt files

FilePath = fullfile(piRootPath,'data','V3','SimpleScene');
fname = fullfile(FilePath,'SimpleScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end

thisR = piRead(fname);

%% Set render quality

% This is a low resolution for speed.
thisR.set('film resolution',[400 300]);
thisR.set('pixel samples',8);

%% Get a sky map from Flywheel, and use it in the scene

% We will put a skymap in the local directory so people without
% Flywheel can see the output
if piScitranExists
    % Use a small skymap.  We should make all the skymaps small, but
    % 'noon' is not small!
    [~, skymapInfo] = piSkymapAdd(thisR,'cloudy');
    
    % The skymapInfo is structured according to python rules.  We convert
    % to Matlab format here.
    s = split(skymapInfo,' ');
    
    % If the skymap is there already, move on.
    skyMapFile = fullfile(fileparts(thisR.outputFile),s{2});
    
    % Otherwise open up Flywheel and download it.
    if ~exist(skyMapFile,'file')
        fprintf('Downloading Skymap from Flywheel ... ');
        st = scitran('stanfordlabs');
        
        fName = st.fileDownload(s{2},...
            'containerType','acquisition',...
            'containerID',s{1}, ...
            'destination',skyMapFile);
        
        assert(isequal(fName,skyMapFile));
        fprintf('complete\n');
    end
end
%% List material library

% This value determines the number of ray bounces.  The scene has
% glass we need to have at least 2 or more.  We start with only 1
% bounce, so it will not appear like glass or mirror.
thisR.integrator.maxdepth.value = 4;

% This adds a mirror and other materials that are used in driving.s
piMaterialGroupAssign(thisR);

%% Write out the pbrt scene file, based on thisR.

thisR.set('fov',45);
thisR.film.diagonal.value = 10;
thisR.film.diagonal.type  = 'float';

sceneName = 'simpleTest';
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s_scene.pbrt',thisR.integrator.subtype));
thisR.set('outputFile',outFile);

piWrite(thisR);

%% Render.  

% Maybe we should speed this up by only returning radiance.
[scene, result] = piRender(thisR,'render type','radiance');

scene = sceneSet(scene,'name','original');
ieAddObject(scene); sceneWindow;
%% Now remove a person
fprintf('****remove %s****\n',thisR.assets(3).name);
thisR.assets(3) = [];
piWrite(thisR);
%% Render again.  

[scene, result] = piRender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','objRemoved');
ieAddObject(scene); sceneWindow;
%% move a obj
fprintf('****move %s to the right side****\n',thisR.assets(3).name);
% horizontally 
% position is saved as x,y,z; z represents depth. x represents
% horizontal position.
thisR.assets(3).position(1) = 2;
piWrite(thisR);
%% Render again.  

[scene, result] = piRender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','objmoved to the right');
ieAddObject(scene); sceneWindow;
%% END







