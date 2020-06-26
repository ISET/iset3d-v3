%% Render a Cornell box
%
% Status:   Error on line 37.  Adding the light has a problem with the
% translate parameter.  Error at the end with the iLightDelete().
%
% piLightDelete is a problem on line 53.
%
% Zhenyi, SCIEN

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read a Cornell box pbrt file

sceneName = 'cornell_box';
thisR = piRecipeDefault('scene name',sceneName);

%%
piWrite(thisR); scene = piRender(thisR,'render type','radiance');
sceneWindow(scene);

%% Summarize the recipe

thisR.summarize;

%% Add an area light at predefined region

% Should we delete all the lights and start clean?

piLightDelete(thisR,'all');
thisR = piLightAdd(thisR, 'type', 'spot', ...
    'cameracoordinate', true, ...
    'cone angle',18);

% Default light spectrum is D65
% Not sure this light shows up at all!
%{
thisR = piLightAdd(thisR, 'type', 'area', ...
    'name','Area light 1',...
    'lightspectrum', 'Tungsten');
%}
%{
 thisR = piLightDelete(thisR,1);
%}
%%  Rendering parameters


% By default, the fov is setted as horizontal and vertical
% fov = [10 10]; 
fov = [25 25]; 
% fov = [30 30];  % Default
% fov = [40 40];
% fov = [50 50];
thisR.set('fov',fov); 

% Increase the spatial resolution a bit
filmRes = [384 256];
thisR.set('film resolution',filmRes);

thisR.set('rays per pixel',64);
thisR.set('nbounces',5);

thisR.integrator.subtype ='directlighting'; 

%% Write and render

piWrite(thisR);
% piWrite(thisR, 'creatematerials', true);

scene = piRender(thisR, 'rendertype', 'radiance');

scene = sceneSet(scene,'mean luminance',100);
sceneWindow(scene);

%% Add another point light

% The relative intensity is a problem.  Hence the gamma below.  FIgure out
% how to deal with this.
thisR = piLightAdd(thisR, 'type', 'point', 'from',[-0.25,-0.25,1.68]);
piWrite(thisR, 'creatematerials', true);
[scene, result] = piRender(thisR, 'rendertype', 'radiance');

sceneWindow(scene);
scene = sceneSet(scene,'mean luminance',100);
sceneSet(scene,'gamma',0.3);

%% Change light to D65

%{
lightsource = piLightGet(thisR);
piLightDelete(thisR, 'all');   % This fails!!! Fix it.

% When the light sources were all removed, this throws an error.
thisR = piLightAdd(thisR, 'type', 'area', 'lightspectrum', 'D65');
%}
%% END