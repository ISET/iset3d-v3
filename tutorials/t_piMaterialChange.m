%% Change the material properties in a V3 PBRT scene
%
% ZL SCIEN Team, 2018

%% Initialize ISET and Docker

% Check: Does the pbrt-v3-spectral docker container pull automatically?
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt_material files
FilePath = fullfile(piRootPath,'data','V3','SimpleScene');
fname = fullfile(FilePath,'SimpleScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Warnings may appear about filter and Renderer
thisR = piRead(fname);

%% Change render quality

%{
% Higher quality
thisR.set('film resolution',[800 600]);
thisR.set('pixel samples',32);
%}
%{
% Lowest quality
thisR.set('film resolution',[300 150]);
thisR.set('pixel samples',16);
%}

% Intermediate quality
thisR.set('film resolution',[300 150]);
thisR.set('pixel samples',16);

%% Get the skymap

% This is the location of the 
[~, skymapInfo] = piSkymapAdd(thisR,'noon');
s = split(skymapInfo,' ');

% If it is there already, move on.  Otherwise open up Flywheel and go
% download it.
skyMapFile = fullfile(fileparts(thisR.outputFile),s{2});
if ~exist(skyMapFile,'file')
    st = scitran('stanfordlabs');
    fName = st.fileDownload(s{2},...
        'containerType','acquisition',...
        'containerID',s{1}, ...
        'destination',skyMapFile);
    assert(isequal(fName,skyMapFile));
end

%% List material library

% It's helpful to check what current material properties are.
piMaterialList(thisR);
piMaterialGroupAssign(thisR);
fprintf('A library of materials\n\n');  % Needs a nicer print method
disp(thisR.materials.lib)

% This value determines the number of bounces.  To have glass we need
% to have at least 2 or more.  We start with only 1 bounce, so it will
% not appear like glass or mirror.
thisR.integrator.maxdepth.value = 4;

%% Write out the pbrt scene file, based on thisR.

% You could adjust the output directory at this point. The default is
% OK and puts in the 'local' part of the iset3d repository. But if you
% want to use a different directory you can 
%
%    * move the files that were written out in thisR.outputFile's
%      directory to your new directory, and 
%    * then set thisR.outputFile to a name in that new directory.
%

% material.pbrt is supposed to overwrite itself.
piWrite(thisR);

%% Render

[scene, result] = piRender(thisR);

scene = sceneSet(scene,'name',sprintf('Glass on (%d)',thisR.integrator.maxdepth.value));

ieAddObject(scene); sceneWindow;

%% Change the sphere to glass

% For this scene, the BODY material is attached to ???? object.  We
% need to parse the geometry file to make sure.  This will happen, but
% has not yet.
target = thisR.materials.lib.plastic;    % Give it a chrome spd
rgbkr  = [0.5 0.5 0.5];              % Reflection
rgbkd  = [0.5 0.5 0.5];              % Scatter

piMaterialAssign(thisR, 'GLASS', target,'rgbkd',rgbkd,'rgbkr',rgbkr);
[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','SimpleScene',[n,'1',e]));
piWrite(thisR,'creatematerials',true);

%% Render again

tic, scene = piRender(thisR,'render type','radiance'); toc
scene = sceneSet(scene,'name','Glass off');
ieAddObject(scene); sceneWindow;

%%