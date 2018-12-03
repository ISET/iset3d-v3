%% Get SkyMap from Flywheel - and use glass in the scene
%
% Shows how to download a file from Flywheel.  This technique is used
% much more extensively (and hidden from the user) in creating the
% complex driving scenes.
%
% This scene has glass and also materials that were created for
% driving scenes.  The script sets up the glass material and number of
% bounces to make the glass appear reasonable.
%
% It also uses piMaterialsGroupAssign() to set a list of materials (in
% this case a mirror) that are part of the scene.
%
% Dependencies:
%
%    ISET3d, ISETCam, JSONio, SCITRAN, Flywheel Add-On (at least version 4.1.0)
%
%  Check that you have the updated docker image by running
%
%   docker pull vistalab/pbrt-v3-spectral
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntroduction01, t_piIntroduction02


%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
if isempty(which('scitran'))
    error('You must have scitran with a stanfordlabs Flywheel account');
end

%% Read pbrt files

FilePath = fullfile(piRootPath,'data','V3','SimpleScene');
fname = fullfile(FilePath,'SimpleScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end

thisR = piRead(fname);

%% Set render quality

% This is a relatively low resolution for speed.
thisR.set('film resolution',round(1.5*[300 200]));
thisR.set('pixel samples',16);

%% Get the skymap from Flywheel

% Use a small skymap.  We should make all the skymaps small, but
% 'noon' is not small!
[~, skymapInfo] = piSkymapAdd(thisR,'cloudy');

% The skymapInfo is structured according to python rules.  We convert
% to Matlab format here.
s = split(skymapInfo,' ');

% If the skymap is there already, move on.  Otherwise open up Flywheel
% and download it.
skyMapFile = fullfile(fileparts(thisR.outputFile),s{2});
if ~exist(skyMapFile,'file')
    fprintf('Downloading Skymap ... ');
    st = scitran('stanfordlabs');
    fName = st.fileDownload(s{2},...
        'containerType','acquisition',...
        'containerID',s{1}, ...
        'destination',skyMapFile);
    assert(isequal(fName,skyMapFile));
    fprintf('complete\n');
end

%% List material library

% This value determines the number of ray bounces.  The scene has
% glass we need to have at least 2 or more.  We start with only 1
% bounce, so it will not appear like glass or mirror.
thisR.integrator.maxdepth.value = 4;

% This adds a mirror and other materials that are used in driving.s
piMaterialGroupAssign(thisR);

%% Write out the pbrt scene file, based on thisR.

piWrite(thisR);

%% Render.  

% Maybe we should speed this up by only returning radiance.
[scene, result] = piRender(thisR);

scene = sceneSet(scene,'name',sprintf('Glass (%d)',thisR.integrator.maxdepth.value));
ieAddObject(scene); sceneWindow;

%% END