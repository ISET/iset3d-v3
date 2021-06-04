%% Gets a skymap from Flywheel; also uses special scene materials
%
% This script shows how to create a simple scene using assets that are
% stored in the Flywheel stanfordlabs site.  To run this script you must
% have permission (a key) to login and download assets from Flywheel.
%
% This technique is used at a much larger scale in creating complex driving
% scenes.
%
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), ISETAuto(zhenyi branch), JSONio, SCITRAN
%
% Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntro_simpleCar

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
if ~piScitranExists, error('scitran installation required'); end

%% We are going place some cars on a plane
% Initialize a planar surface with a checkerboard texture pattern
sceneName = 'simpleCarScene';
sceneR = piRecipeDefault('scene name','checkerboard');
sceneR.set('outputFile',fullfile(piRootPath, 'local', sceneName,[sceneName,'.pbrt']));
% render quality
sceneR.set('film resolution',[1280 600]/2);
sceneR.set('pixel samples',16);
sceneR.set('max depth',10);

% camera properties
sceneR.set('fov',45);
sceneR.set('from', [0 1.5 7]);   % from was 5
sceneR.set('to',[0 0.5 0]);
sceneR.set('up',[0 1 0]);

% scale and rotate checkerboard
sceneR.set('assets','0002ID_Checkerboard_B','scale',[10 10 1]);
sceneR.set('asset','Checkerboard_B','world rotation',[90 30 0]);

%% Get a car from Flywheel

% Open the connection
st = scitran('stanfordlabs');
% The lookup reads from group/project/subject/session/acquisition
object_acq = st.lookup('wandell/Graphics auto/assets/car/Car_085',true);% 

% We are going to put the object here
dstDir = fullfile(piRootPath, 'local','Car_085');

% There are cg resources and we have selected a destination directory
% This is the recipe to render the car object by itself.
objectR = piFWAssetCreate(object_acq, 'resources', true, 'dstDir', dstDir);

% This tells the iaRecipeMerge where to look for the resources
objectR.inputFile =  fullfile(dstDir,'Car_085.pbrt');

%% add downloaded asset information to Render recipe.
sceneR = piRecipeMerge(sceneR, objectR);

%% Get a sky map from Flywheel, and use it in the scene

thisTime = '16:30';  % The time of day of the sky

% We will put a skymap in the local directory so people without
% Flywheel can see the output
[acqID, skyname] = piFWSkymapAdd(thisTime,st);

%% Add a light to the merged scene

% Delete any lights that happened to be there
sceneR = piLightDelete(sceneR, 'all');

rotation(:,1) = [0 0 0 1]';
rotation(:,2) = [45 0 1 0]';
rotation(:,3) = [-90 1 0 0]';

skymap = piLightCreate('new skymap', ...
    'type', 'infinite',...
    'string mapname', skyname,...
    'rotation',rotation);

sceneR.set('light', 'add', skymap);


% The skymapInfo is structured according to python rules, which we use for
% the cloud calculations
skymapInfo = [acqID,' ',skyname];

% We convert to Matlab format here. The first cell is the acquisition ID
% and the second cell is the file name of the skymap
s = split(skymapInfo,' ');

% The destination of the skymap file
skyMapFile = fullfile(fileparts(sceneR.outputFile),s{2});

% If it exists, move on. Otherwise open up Flywheel and
% download the skypmap file.
if ~exist(skyMapFile,'file')
    fprintf('Downloading Skymap from Flywheel ... ');
    % Download the file from acq using fileName and Id, same approach
    % is used for rendering jobs on google cloud
    piFwFileDownload(skyMapFile, s{2}, s{1})% (dest, FileName, AcqID)
    fprintf('complete\n');
end

%% This adds predefined sceneauto materials to the assets in this scene

iaAutoMaterialGroupAssign(sceneR);  

%% Set the car body to a new color.

colorkd = piColorPick('blue');

MaterialName = 'HDM_06_002_carbody_black'; 
sceneR.set('material',MaterialName,'kd value',colorkd);

% Assign a nice position.
sceneR.set('asset','HDM_06_002_B','world translation',[0.5 0 0]);
sceneR.set('asset','HDM_06_002_B','world rotation',[0 -15 0]);
sceneR.set('asset','HDM_06_002_B','world rotation',[0 -30 0]);

%% Write out the pbrt scene file, based on scene.
piWrite(sceneR);   % We get a warning.  Ignore

%% Render.

% Maybe we should speed this up by only returning radiance.
[scene, result] = piRender(sceneR,'render type','radiance');

%%  Show the scene in a window

% scene = sceneSet(scene,'name',sprintf('Time: %s',thisTime));
% denoise scene
% scene = sceneSet(scene,'gamma', 0.75);
scene = sceneSet(scene,'name', 'normal');
sceneWindow(scene);
sceneSet(scene,'display mode','hdr'); 
% denoise
%{
sceneDenoise = piAIdenoise(scene);
scene = sceneSet(scene,'name', 'denoised');
sceneWindow(sceneDenoise);
% sceneSet(scene,'display mode','hdr');   
%}






