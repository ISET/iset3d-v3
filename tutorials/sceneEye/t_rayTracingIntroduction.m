%% t_rayTracingIntroduction.m
%
% This tutorial is a brief, mainly textual, introduction to modeling the
% optics of the human eye using ray-tracing in ISETBio.  Read the words
% here to get some ideas.  Then try the other tutorials (t_eye*) for more
% examples of parameters (with fewer words).
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
% What we have done is place the PBRT code inside of a Docker
% container that can be called from within Matlab.  We have written a
% large number of Matlab tools in this toolbox, ISET3d, that permit us
% to set up the PBRT scenes and the parameters of the physiological
% optics that transform the 3D scene into the retinal image.
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

% Some scenes, but not most, use mm as spatial units.  This scene does.
% This parameter is part of the camera definition.
theScene.set('mm units',true);

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

%%  Show the scene.

% Setting the pinhole to true means we have no optics.  The result is a
% scene, rather than a spectral irradiance at the retina.
theScene.set('use pinhole',true);
theScene.set('fov',45);

[scene,renderInfo] = theScene.render;
sceneWindow(scene);

%% Rendering the PBRT scene

% Now tell PBRT to use the lens
theScene.set('use optics',true);

% Focus on the numbers at 300 mm
theScene.set('accommodation',1/.3);   % Diopters

% The lens rendering benefits from adding a few more rays per pixel
theScene.set('rays per pixel',192);

% Summarizing is always nice
theScene.summary;

% Render and show.  We use 'oi' to refer to optical image, the spectral
% irradiance at the retina (also retinal irradiance).
oi = theScene.render('render type','radiance');
oiWindow(oi);

%% Set the accomodation to the 100 mm target

% Change the focal distance.  You can set this in diopters or 'focal
% distance'.  Your choice.
theScene.set('accommodation',1/0.1);   % Diopters
% theScene.summary;

oi = theScene.render('render type','radiance');
oiWindow(oi);

%% Adjust the lens pigment density

% The lens density is managed in the sceneEye.setOI method after the PBRT
% rendering.
theScene.set('lens density',0);
theScene.summary;

oi = theScene.render;
oiWindow(oi);

%% END


