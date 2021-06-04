%% Change the material properties in a V3 PBRT scene
%
% Deprecated for t_piIntro_material.m
%
% We create two scenes.  In one the material of certain objects is
% plastic, and in the other the objects are turned to glass.
%
% Notes:
%   We increased the amount of docker memory and swap to 12G and 2G.
%   Not sure this was necessary.
%
%   We switched the skypmap from noon, which ius 98M, to cloudy, which
%   is 7M.  That should speed up something, and maybe cause fewer
%   crashes.
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
% Intermediate quality
thisR.set('film resolution',[800 600]);
thisR.set('pixel samples',16);
%{
% Lowest quality
thisR.set('film resolution',[300 150]);
thisR.set('pixel samples',16);
%}


%% Get the skymap

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

% It's helpful to check what current material properties are.
piMaterialPrint(thisR);
piMaterialGroupAssign(thisR);
fprintf('A library of materials\n\n');  % Needs a nicer print method
disp(thisR.materials.lib)

% This value determines the number of bounces.  To have glass we need
% to have at least 2 or more.  We start with only 1 bounce, so it will
% not appear like glass or mirror.
thisR.integrator.maxdepth.value = 4;

%% Write out the pbrt scene file, based on thisR.

piWrite(thisR);

%% Render.  

% Maybe we should speed this up by only returning radiance.
[scene, result] = piRender(thisR);

scene = sceneSet(scene,'name',sprintf('Glass (%d)',thisR.integrator.maxdepth.value));
ieAddObject(scene); sceneWindow;

%% Change materials to glass

% For this scene, the BODY material is attached to ???? object.  We
% need to parse the geometry file to make sure.  This will happen, but
% has not yet.
target = thisR.materials.lib.plastic; % Give it a chrome spd
rgbkr  = [0.5 0.5 0.5];               % Reflection
rgbkd  = [0.5 0.5 0.5];               % Scatter

piMaterialAssign(thisR, 'GLASS', target,'rgbkd',rgbkd,'rgbkr',rgbkr);


% Write out the modified scene in the same folder but put a '1' into
% the output name.
[~,sceneName,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local',sceneName,[sceneName,'1',e]));
piWrite(thisR);

%% Render again

tic, scene = piRender(thisR,'render type','radiance'); toc
scene = sceneSet(scene,'name','Plastic');
ieAddObject(scene); sceneWindow;

%%