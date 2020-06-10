%% t_piIntro_meshLabel
%
% Under development
%
% Some scenes can be labeled by mesh identity, but not others.  The
% Chess Set does not get the labels.
%
% Let's ask Zhenyi which scenes and why.  Probably related to cinema4D
% issues.
%
% Zheng, Brian, 2019
%

%%
ieInit;
if ~piDockerExists, piDockerConfig; end
if isempty(which('RdtClient'))
    error('You must have the remote data toolbox on your path'); 
end

%% Read the pbrt files

% sceneName = 'kitchen'; sceneFileName = 'scene.pbrt';
% sceneName = 'living-room'; sceneFileName = 'scene.pbrt';
sceneName = 'ChessSet'; sceneFileName = 'ChessSet.pbrt';

inFolder = fullfile(piRootPath,'local','scenes');
inFile = fullfile(inFolder,sceneName,sceneFileName);
if ~exist(inFile,'file')
    % Sometimes the user runs this many times and so they already have
    % the file.  We only fetch the file if it does not exist.
    fprintf('Downloading %s from RDT',sceneName);
    dest = piPBRTFetch(sceneName,'pbrtversion',3,...
        'destinationFolder',inFolder,...
        'delete zip',true);
end

% This is the PBRT scene file inside the output directory
thisR  = piRead(inFile);

%% Set render quality

% Set resolution for speed or quality.
thisR.set('film resolution',round([600 600]*0.25));  % 2 is high res. 0.25 for speed
thisR.set('rays per pixel',16);                      % 128 for high quality

%% Maybe we should speed this up by only returning radiance.
piWrite(thisR,'creatematerials',true);

scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);

%% Get the object ?? or material?? label

meshMap = piRender(thisR, 'render type', 'mesh');
ieNewGraphWin; 
imagesc(meshMap)

%% END