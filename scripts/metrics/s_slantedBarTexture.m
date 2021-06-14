%% Create a slanted bar target using the flatSurface with a texture
%
% This scene only has one object, a uniform surface, and a camera.  We
% point the camera towards the surface, and we paint a texture on the
% surface.  The texture is checks that we can use for calculating the
% slanted bar MTF.
%
% See also
%

%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%%  Read the scene and add a light

% thisR = piRecipeDefault('scene name','flatSurfaceRandomTexture');
thisR = piRecipeDefault('scene name','flatsurface');

% Add a light
distantLight = piLightCreate('distant','type','distant',...
    'spd', [9000 0.001], ...
    'cameracoordinate', true);
thisR.set('light','add',distantLight);

%% Point the camera

% Find the position of the surface
surfaceName = '001_Cube_O';
xyz = thisR.get('asset',surfaceName,'world position');

% Aim the camera at the object and bring it closer.
thisR.set('to',  xyz -   [0,5,0]);
% thisR.set('from',xyz - [0, 10, 0]);

% Have a look at the camera, its direction, and object
% piAssetGeometry(thisR);

%{
% Try it before the lens.  It is just a uniform, bluish surface.
 piWrite(thisR);
 scene = piRender(thisR,'render type','radiance');
 sceneWindow(scene);
%}

%% Add a lens

% We can render at a couple of different distances (camera positions).
lensname = 'dgauss.22deg.6.0mm.json';
c = piCameraCreate('omni','lens file',lensname);
thisR.set('camera',c); 

%% Set the field of view by choosing the film size

% The FOV is OK, about 49 deg.  If you want to make it bigger or smaller
% change the size of the film
% thisR.set('film diagonal',0.8);

fov      = thisR.get('fov');
filmsize = thisR.get('film diagonal');
thisR.set('film diagonal',filmsize*(45/fov));

%% Add the checks

checksName = 'checks';
checksTexture = piTextureCreate(checksName,...
    'type', 'checkerboard',...
    'format', 'spectrum',...
    'uscale', 10,...
    'vscale', 10, ...
    'spectrum tex1', [.05 .05 .05],...
    'spectrum tex2', [.95 .95 .95]);

thisR.set('texture', 'add', checksTexture);
thisR.get('texture print');

thisR.set('material', 'Mat', 'kd val', checksName);

% The material has been modified so that its 'val' is now the texture name.
% PBRT figures out what to do.
% thisR.get('material', 'Mat', 'kd val')

% Let's rotate the uniform surface
thisR.set('assets',surfaceName,'rotate',[30 20 0]);

%% Set the spatial resolution

% When you are close to done, we will want a lot of spatial samples so the
% image is not the rate limiting step in the MTF
thisR.set('spatial samples',[320,320]);
thisR.get('spatial samples')/fov

% The geometry looks wrong
% piAssetGeometry(thisR)

piWrite(thisR);
oi = piRender(thisR,'render type','radiance');
oiWindow(oi);

%% Optical image to sensor

sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',45);

% Set the sensor parameters here
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%% END
