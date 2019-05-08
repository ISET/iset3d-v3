%% An introduction to eye optics modeling using ray tracing and ISETBio
%
% Description:
%    This tutorial is an introduction to modeling the optics of the eye
%    using ray-tracing in ISETBIO.
%
%    To begin, you must have the Github repo iset3d on your MATLAB path:
%    https://github.com/ISET/iset3d as well as the Github repo isetbio on
%    your path: https://github.com/isetbio/isetbio
%
%    You must also have docker installed and running on your machine. You
%    can find general instructions on docker here: https://www.docker.com/
%
%    In ISETBIO we can load up a virtual, 3D scene and render a retinal
%    image by tracing the light passing from the scene through the optics
%    of the human eye onto the retina. We use a modified version of PBRT
%    (Physically Based Ray Tracer) to do this calculation. Our version of
%    PBRT, which we call pbrt-v3-spectral, has the ability to render
%    through the optics of the human eye and to trace rays spectrally.
%    Pbrt-v3-spectral has also been dockerized so you do not need to
%    compile or install the source code in order to render images. Instead,
%    you must have docker installed and running on your computer and the
%    scenes should automatically render through the docker container.
%
%    You can find the source code for pbrt-v3-spectral here:
%    https://github.com/scienstanford/pbrt-v3-spectral
%
% Dependencies:
%   iset3d, isetbio, Docker
%
% History:
%    XX/XX/17  TL   ISETBIO Team, 2017
%    03/16/19  JNM  Documentation pass


%% Initialize ISETBIO
if isequal(piCamBio, 'isetcam')
    error('%s: requires ISETBio, not ISETCam\n', mfilename);
end
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Render a fast, low quality retinal image
% We have several scenes that have been tailored specifically for isetbio
% and iset3d. You can find a description of these scenes (and more) on the
% wiki page (https://github.com/isetbio/isetbio/wiki/3D-rendering).

% You can select a scene as follows:
myScene = sceneEye('numbersAtDepth');

% ISETBIO requires a "working directory." If one is not specified when
% creating a scene, the default is in isetbioRootPath/local. All data
% needed to render a specific scene will be copied to the working folder
% upon creation of the scene. All new data generated within ISETBIO will
% also be placed in the working directory. This folder will eventually be
% mounted onto the docker container to be rendered. You can specify a
% specific working folder as follows:
% myScene = sceneEye('scene', 'numbersAtDepth', 'workingDirectory', [path to
% desired directory]);

% The sceneEye object contains information of the 3D scene as well as the
% parameters of the eye optics included in the raytracing. You can see a
% list of the parameters available in the object structure:
myScene

% Let's render a quick, low quality retinal image first. Let's name this
% render fastExample.
myScene.name = 'fastExample';

% Let's change the number of rays to render with.
myScene.numRays = 128;

% And the FOV of the retinal image
myScene.fov = 30;

% Let's also change the resolution of the render. The retinal image is
% always square, so there is only one parameter for resolution.
myScene.resolution = 128;

% Now let's render. This may take a few seconds, depending on the number of
% cores on your machine. On a machine with 2 cores it takes ~15 seconds.
%
% to reuse an existing rendered file of the correct size, uncomment the
% parameter provided below.
oi = myScene.render; %('reuse');

% Now we have an optical image that we can use with the rest of ISETBIO. We
% can take a look at what it looks like right now:
ieAddObject(oi);
oiWindow;

%% Step through accommodation
% Now let's render a series of retinal images at different accommodations.

% With numRays at 128 and resolution at 128, each image takes around 30 sec
% to render on a local machine with 8 cores. If you'd like to bump up the
% image quality slightly, you can turn the resolution up to 256 and numRays
% to 256, which will bring rendering time to around 2 min per image.
% myScene.resoltuion = 256;
% myScene.numRays = 256;

accomm = [3 5 10]; % in diopters
opticalImages = cell(length(accomm), 1);
for ii = 1:length(accomm)
    myScene.accommodation = accomm(ii);
    myScene.name = sprintf('accom_%0.2fdpt', myScene.accommodation);

    % This produces the characteristic LCA of the eye. The higher the
    % number, the longer the rendering time but the finer the sampling
    % across the visible spectrum.
    myScene.numCABands = 6;

    % When we change accommodation the lens geometry and dispersion curves
    % of the eye will change. ISETBIO automatically generates these new
    % files at rendering time and will output them in your working
    % directory. In general, you may want to periodically clear your
    % working directory to avoid a build up of files.
    %
    % to reuse an existing rendered file of the correct size, uncomment the
    % parameter provided below.
    [oi, results] = myScene.render; %('reuse');
    ieAddObject(oi);
    opticalImages{ii} = oi;
end

oiWindow;
