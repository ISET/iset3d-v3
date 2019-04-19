%% v_piRDTScenes
% This is the second in a series of scripts introducing iset3d calulcations
%
% Description:
%    This introduction works with a file that is stored in the Remote Data
%    Toolbox site where we keep various larger PBRT files.  This function
%    shows how to download one of the files and render it.
%
%    You must have the Remote Data Toolbox on your path to run this.
%
%    Download and print out simple properties of the RDT scenes
%
%    We also set up a few more variables than we used in the first
%    introduction, t_Introduction01.
%
% Dependencies:
%
%    ISET3d, ISETCam or ISETBio, JSONio, RemoteDataToolbox
%
% Notes:
%    * Check that you have the updated docker image by running
%     docker pull vistalab/pbrt-v3-spectral
%    * List by directory and scene filename
%         Directory, sceneFileName
%         ------------------------
%         ChessSet, ChessSet
%         kitchen, scene
%         white-room, scene
%         ColorfulScene, ColorfulScene
%         living-room, scene
%         bathroom, scene
%         bathroom2, scene
%         bedroom, scene

% History:
%    XX/XX/17  TL, ZL, BW  SCIEN 2017
%    03/12/19  JNM        Documentation pass
%    04/19/19  JNM        Merge with master (resolve conflicts)

%% Initialize ISET and Docker
% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if isempty(which('RdtClient'))
    error('You must have the remote data toolbox on your path');
end

% Determine whether you are working in ISETBio or ISETCam
fprintf('Attempting to execute using %s.\n', piCamBio);

% This is the INPUT file name
sceneName = 'living-room';
sceneFileName = 'scene.pbrt';

% The output will be written here
inFolder = fullfile(piRootPath, 'local', 'scenes');
piPBRTFetch(sceneName, 'pbrtversion', 3, 'destinationFolder', inFolder);

%%
inFile = fullfile(inFolder, sceneName, sceneFileName);
recipe = piRead(inFile);

% This is out the putput scene name
outFolder = fullfile(tempdir, sceneName);
outFile = fullfile(outFolder, [sceneName, '.pbrt']);
recipe.set('outputFile', outFile);

%% Change render quality
recipe.set('film resolution', [192 192]);
recipe.set('pixel samples', 96);

% For some scenes, the mirror and glass don't show unless you set the
% number of bounces to 3 or higher.
recipe.set('max depth', 1); % Number of bounces

%% Write the changes
piWrite(recipe);

%%  Render the scene
% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
[scene, result] = piRender(recipe); %, 'reuse', true);

%%  Show it and the depth map
ieAddObject(scene);
sceneWindow;
% scene = sceneSet(scene, 'gamma', 0.5);
scenePlot(scene, 'depth map');

sceneWindow(scene);
% sceneSet(scene, 'gamma', 0.5);

%%
scenePlot(scene, 'depth map');

%% Add a realistic camera
% Another time another script.  Show rendering with a lens.
recipe.set('camera', 'realistic');
recipe.set('lensfile', fullfile(piRootPath, 'data', 'lens', ...
    'dgauss.22deg.50.0mm.dat'));
recipe.set('filmdiagonal', 35);
%}

%% End