%% t_piIntroduction03
% Uses Flywheel to get a skymap; also uses special scene materials
%
% Description:
%    We store many graphics assets in the Flywheel database.  This script
%    shows how to download a file from Flywheel.  This technique is used
%    much more extensively in creating complex driving scenes.
%
%    This example scene also includes glass and other materials that
%    were created for driving scenes.  The script sets up the glass
%    material and number of bounces to make the glass appear reasonable.
%
%    It also uses piMaterialsGroupAssign() to set a list of materials (in
%    this case a mirror) that are part of the scene.
%
% Dependencies:
%    ISET3d, ISETCam or ISETBio, JSONio, SCITRAN, Flywheel Add-On (at
%    least version 4.3.2)
%
% Notes:
%    Check that you have the updated docker image by running
%    docker pull vistalab/pbrt-v3-spectral
%
% See Also:
%   t_piIntroduction01, t_piIntroduction02, t_piIntroduction_test
%
% History:
%    XX/XX/18  ZL, BW  SCIEN 2018
%    03/12/19  JNM     Documentation pass

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
% if ~piScitranExists, error('scitran installation required'); end

% Determine whether you are working in ISETBio or ISETCam
fprintf('Attempting to execute using %s.\n', piCamBio);

%% Read pbrt files
FilePath = fullfile(piRootPath, 'data', 'V3', 'SimpleScene');
fname = fullfile(FilePath, 'SimpleScene.pbrt');
if ~exist(fname, 'file'), error('File not found'); end

thisR = piRead(fname);

%% Set render quality
% This is a low resolution for speed.
thisR.set('film resolution', [400 300]);
thisR.set('pixel samples', 64);

%% Get a sky map from Flywheel, and use it in the scene
% We will put a skymap in the local directory so people without
% Flywheel can see the output
if piScitranExists
    % Use a small skymap.  We should make all the skymaps small, but
    % 'noon' is not small!
    [~, skymapInfo] = piSkymapAdd(thisR, 'cloudy');

    % The skymapInfo is structured according to python rules.  We convert
    % to Matlab format here.
    s = split(skymapInfo, ' ');

    % If the skymap is there already, move on.
    skyMapFile = fullfile(fileparts(thisR.outputFile), s{2});

    % Otherwise open up Flywheel and download it.
    if ~exist(skyMapFile, 'file')
        fprintf('Downloading Skymap from Flywheel ... ');
        st = scitran('stanfordlabs');

        fName = st.fileDownload(s{2}, ...
            'containerType', 'acquisition', ...
            'containerID', s{1}, ...
            'destination', skyMapFile);

        assert(isequal(fName, skyMapFile));
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
thisR.set('fov', 45);
thisR.film.diagonal.value = 10;
thisR.film.diagonal.type = 'float';

sceneName = 'simpleTest';
outFile = fullfile(piRootPath, 'local', sceneName, ...
    sprintf('%s_scene.pbrt', thisR.integrator.subtype));
thisR.set('outputFile', outFile);

piWrite(thisR, 'creatematerials', true);

%% Render.
% Maybe we should speed this up by only returning radiance.
%
% To reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
[scene, result] = piRender(thisR, 'render type', 'radiance');
%, 'reuse', true);

scene = sceneSet(scene, 'name', sprintf('%s', thisR.integrator.subtype));
ieAddObject(scene);
sceneWindow;

%% END