%% A tutorial to illustrate setting special scene materials
%
% Description:
%    This example scene includes glass and other materials. The script
%    sets up the glass material and number of bounces to make the glass
%    appear reasonable.
%
%    It also uses piMaterialsGroupAssign() to set a list of materials (in
%    this case a mirror) that are part of the scene.
%
% Dependencies:
%    ISET3d, (ISETCam or ISETBio), JSONio
%
% Notes:
%    * Check that you have the updated docker image by running
%       docker pull vistalab/pbrt-v3-spectral
%       docker pull vistalab/pbrt-v3-spectral:test
%
% See Also:
%   t_piIntro_*

% History:
%    XX/XX/18  ZL, BW  SCIEN 2018
%    04/23/19  JNM     Documentation pass

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt files
sceneName = 'SimpleScene';
FilePath = fullfile(piRootPath, 'data', 'V3', sceneName);
fname = fullfile(FilePath, [sceneName, '.pbrt']);
if ~exist(fname, 'file'), error('File not found'); end

% This scene contains some glass and a mirror
thisR = piRead(fname);

%% Set render quality
% This is a low resolution for speed.
thisR.set('film resolution', [400 300]);
thisR.set('pixel samples', 64);

%% List material library
% These all the possible materials. 
mType = piMateriallib;
disp(mType);

% In fact, this whole library is always stored as part of any recipe
%    thisR.materials.lib

% These are the materials in this particular scene.
piMaterialList(thisR);

%% Write out the pbrt scene file, based on thisR.
thisR.set('fov', 45);
thisR.film.diagonal.value = 10;
thisR.film.diagonal.type  = 'float';
thisR.integrator.subtype = 'bdpt';  
thisR.sampler.subtype = 'sobol';

%% Changing the name!!!! Important to comment and explain!!! ZL, BW
outFile = fullfile(piRootPath, 'local', sceneName, ...
    sprintf('%s.pbrt', sceneName));
thisR.set('outputFile', outFile);

piWrite(thisR, 'creatematerials', true);

%% Render
scene = piRender(thisR);  %, 'reuse', true);
scene = sceneSet(scene, 'name', sprintf('Uber %s', sceneName));
sceneWindow(scene);
% sceneSet(scene, 'display mode', 'hdr');

%% Adjust the scene material from uber to mirror
% The SimpleScene has a part named 'mirror' (slot 5), but the
% material type is set to uber.  We want to change that.
partName = 'mirror';

% Get the mirror material from the library.  The library is always
% part of any recipe.
target = thisR.materials.lib.mirror; 
piMaterialAssign(thisR, partName, target);

%% Set render to account for glass and mirror requiring multiple bounces
% This value determines the number of ray bounces.  If a scene has
% glass we need to have at least 2 bounces.
thisR.set('nbounces', 10);

% Because we changed the material assignment, we need to set the
% 'creatematerials' argument to true.
piWrite(thisR, 'creatematerials', true);

%% Render
scene = piRender(thisR);  %, 'reuse', true);
scene = sceneSet(scene, 'name', sprintf('Mirror %s', sceneName));
sceneWindow(scene);
sceneSet(scene, 'gamma', 0.8);

%% Adjust the scene material from mirror to glass (the person, too)
% Now change the partName 'mirror' to glass material. 
target = thisR.materials.lib.glass; 
piMaterialAssign(thisR, partName, target);
piMaterialAssign(thisR, 'GLASS', target);

% Set the person to glass, too
personName = 'uber_blue';
piMaterialAssign(thisR, personName, target);

% Because we changed the material assignment, we need to set the
% 'creatematerials' argument to true.
piWrite(thisR, 'creatematerials', true);

%% Render
[scene, result] = piRender(thisR);  %, 'reuse', true);
scene = sceneSet(scene, 'name', sprintf('Glass %s', sceneName));
sceneWindow(scene);

%% END