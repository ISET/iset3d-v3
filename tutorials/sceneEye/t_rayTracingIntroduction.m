%% t_rayTracingIntroduction.m
%
% This tutorial is an introduction to modeling the optics of the human eye
% using ray-tracing in ISETBio.
% 
% To begin, you must have the Github repo iset3d on your MATLAB path:
%
%   https://github.com/ISET/iset3d 
%
% as well as the Github repo isetbio on your path:
%
%   https://github.com/isetbio/isetbio
% 
% You must have Docker installed and running on your machine. You can find
% general instructions on docker here: 
%
%   https://www.docker.com/
%
% You can find the source code for pbrt-v3-spectral here:
% 
%   https://github.com/scienstanford/pbrt-v3-spectral
%
% Depends on: 
%    ISET3d, ISETBio, Docker
%
% See also:
%   YouTube videos:
%
  
%% The basic idea
%
% ISETBIO includes a set of tools for calculating the retinal image (also
% called the spectral irradiance at the retina). 
%
% Many of the tools were developed for relatively simple scenes, like the
% image on the central few degrees on a computer screen.  For such scenes
% the spectral point spread functions are enough for the central fovea.  
%
% If the image spans a larger field of view, then the spectral point spread
% functions across different field heights are necessary.
%
% For the much larger world of 3D natural images, we need additional tools.
% In part this is because distance from the eye's accommodative plane has
% an impact on the blur, and in part this is because 3D occlusion has an
% additional impact.
%
% To assist with calculating for 3D natural image models we use ray tracing
% methods. Specifically, we modified PBRT (Physically Based Ray Tracer) to
% enable us to calculate how a 3D scene would become a retinal image
% given that we had a model of the physiological optics.  PBRT is a widely
% used and admired ray tracer that has been validated, it is open-source,
% and it is very well-documented.
%
% PBRT is not Matlab, and thus we needed to develop a method for using it
% smoothly with ISETBio (and ISETCam).
%
% What we have done is place the PBRT code inside of a Docker container
% that can be called from within Matlab.  We have written a large number of
% Matlab tools that permit us to set up the PBRT scenes and the parameters
% of the physiological optics that transform the 3D scene into the retinal
% image.
%
% With this approach, you do not need to compile or install the source code
% in order to render images. You must only have docker installed and
% running on your computer. 
%
% The next few lines show the basic philosoph we take to running the 3D ray
% tracing code. There are many more tutorial scripts that go into detail,
% and we hope you find those useful.  This one just gets you going.
% Slightly.
%

%% Initialize ISETBIO
if piCamBio
    fprintf('%s: requires ISETBio, not ISETCam\n',mfilename); 
    return;
end
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Render a fast, low quality retinal image

% We have several scenes that have been tailored specifically for isetbio
% and iset3d. You can find a description of these scenes (and more) on the
% wiki page (https://github.com/isetbio/isetbio/wiki/3D-rendering).

% You can select a scene as follows:
theScene = sceneEye('Numbers at depth');

% ISETBIO requires a "working directory." If one is not specified when
% creating a scene, the default is in isetbioRootPath/local. All data
% needed to render a specific scene will be copied to the working folder
% upon creation of the scene. All new data generated within ISETBIO will
% also be placed in the working directory. This folder will eventually be
% mounted onto the docker container to be rendered.
%
% The rendering software 

% The sceneEye object class is quite simple, containing only a few
% parameters that are special to its function.
disp(theScene)

% Almost all of the rendering properties are specified within the 'recipe'.
% The 'recipe' class is used by ISET3d for all scenes, whether they are
% physiological optics models or not. The rendering software can handle
% many types of lenses and much more complex optical models, say with
% microlens arrays.
disp(theScene.get('recipe'))

%%
theScene.set('use pinhole',true);
scene = theScene.render;
sceneWindow(scene);

%% Rendering the PBRT scene

% Once you have loaded a scene, you render it using a method that is part
% of the sceneEye class.
theScene.set('use pinhole',false);
retinalImage = theScene.render;

% In ISETBio we represent the retinalImage 
oiWindow(retinalImage);

% Let's change the number of rays to render with. 
theScene.numRays = 256;

% And the FOV of the retinal image
theScene.fov = 30;

% Let's also change the resolution of the render. The retinal image is
% always square, so there is only one parameter for resolution.
theScene.resolution = 256;

% Now let's render. This may take a few seconds, depending on the number of
% cores on your machine. On a machine with 2 cores it takes ~15 seconds. 
oi = theScene.render;

% Now we have an optical image that we can use with the rest of ISETBIO. We
% can take a look at what it looks like right now:
oiWindow(oi);


%% Step through accommodation
% Now let's render a series of retinal images at different accommodations.

% With numRays at 128 and resolution at 128, each image takes around 30
% second to render on a local machine with 8 cores. If you'd like to
% improve the image quality slightly, you can turn the resolution up to 256
% and numRays to 256, which will bring rendering time to around 2 min per
% image.
%{
  myScene.resoltuion = 256; 
  myScene.numRays    = 256;
%}

accomm = [3 5 10]; % in diopters
opticalImages = cell(length(accomm),1);
for ii = 1:length(accomm)
    
    theScene.accommodation = accomm(ii);
    theScene.name = sprintf('accom_%0.2fdpt',theScene.accommodation);
    
    % This produces the characteristic LCA of the eye. The higher the
    % number, the longer the rendering time but the finer the sampling
    % across the visible spectrum.
    theScene.numCABands = 6; 
    
    % When we change accommodation the lens geometry and dispersion curves
    % of the eye will change. ISETBIO automatically generates these new
    % files at rendering time and will output them in your working
    % directory. In general, you may want to periodically clear your
    % working directory to avoid a build up of files.
    [oi, results] = theScene.render;
    opticalImages{ii} = oi;
    oiWindow(oi);
end

%% END


