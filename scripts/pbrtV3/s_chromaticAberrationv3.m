%% s_chromaticAberrationv3.m
% Show chromatic aberration in lens rendering.
%
% Description:
%    Demonstrate the chromatic aberration present in lens rendering.
%    Adapted from s_texturedPlane.m
%
% History:
%    XX/XX/18  TL   SCIEN Team, 2018
%    03/22/19  JNM  Documentation pass

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

% Determine whether you are working in ISETBio or ISETCam
fprintf('Attempting to execute using %s.\n', piCamBio);

%% Read the pbrt scene
fname = fullfile(piRootPath, 'data', 'V3', 'texturedPlane', ...
    'texturedPlane.pbrt');

% Read the main scene pbrt file. Return it as a recipe
thisR = piRead(fname, 'version', 3);

% Setup working folder
workingDir = fullfile(piRootPath, 'local', 'texturedPlane');
if ~isfolder(workingDir), mkdir(workingDir); end
% if ~(isdir(workingDir)), mkdir(workingDir); end

%% Scale and translate the plane
scale = 0.5; % 1*0.5 = 0.5 m
translate = 1; % m

% The textured plane has specifically been named "Plane" in this scene. We
% also know that our camera is located at the origin and looking down the
% positive y-axis.
%    [Note: XXX - The order of scaling and translating matters!]
% The plane is oriented in the x-z plane
piObjectTransform(thisR, 'Plane', 'Scale', [scale scale scale]);
piObjectTransform(thisR, 'Plane', 'Translate', [0 0 translate]);

%% Attach a desired texture
imageName = 'squareResolutionChart.exr';
imageFile = fullfile(piRootPath, 'data', 'imageTextures', imageName);

copyfile(imageFile, workingDir);
thisR = piWorldFindAndReplace(thisR, 'dummyTexture.exr', imageName);

%% Attach a lens
% The number of rays should go up with the aperture
thisR.set('camera', 'realistic');
thisR.set('aperture', 2);
thisR.set('film resolution', 128);
thisR.set('rays per pixel', 128);
thisR.set('diagonal', 5);
thisR.set('focusdistance', 1)

%% Render once without chromatic aberration
[p, n, e] = fileparts(fname);
thisR.outputFile = fullfile(workingDir, [n, e]);
piWrite(thisR);

% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
[oi, results] = piRender(thisR); %, 'reuse', true);
oi = oiSet(oi, 'name', 'noCA');

% Show it in ISET
ieAddObject(oi);
oiWindow;

%% Turn on chromatic aberration and render
thisR.set('chromaticaberration', 'true');
piWrite(thisR);

% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
[oiCA, results] = piRender(thisR); %, 'reuse', true);
oiCA = oiSet(oiCA, 'name', 'CA');

% Show it in ISET
ieAddObject(oiCA);
oiWindow;
