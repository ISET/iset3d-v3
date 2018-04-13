%% Test a simple pbrtv3 scene (teapot).
% 
% TL SCIEN 2017

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file

% Good options are
% kitchen, bathroom, bathroom2, living-room, SimpleScene
destinationFolder = fullfile(piRootPath,'data','V3');
if ~exist(fullfile(destinationFolder,'white-room'),'dir')
    piPBRTFetch('white-room','pbrtversion',3,'destinationFolder',destinationFolder);
end

% For all the scenes except SimpleScene
fname = fullfile(sceneDir,'scene.pbrt');

recipe = piRead(fname,'version',3);

%% Add a realistic camera
%{
recipe.set('camera','realistic');
recipe.set('lensfile',fullfile(piRootPath,'data','lens','dgauss.22deg.50.0mm.dat'));
recipe.set('filmdiagonal',35); 
%}

%% Change render quality
recipe.set('filmresolution',[128 128]);
recipe.set('pixelsamples',128);
recipe.set('maxdepth',1); % Number of bounces

%% Render
% ~ 20 seconds on an 8 core machine
oiName = 'white-room';
recipe.set('outputFile',fullfile(piRootPath,'local',strcat(oiName,'.pbrt')));

piWrite(recipe);

%%
switch recipe.get('optics type')
    case 'lens'
        [oi, result] = piRender(recipe);
        ieAddObject(oi);
        oiWindow;
        oi = oiSet(oi,'gamma',0.5);

    case {'pinhole','perspective'}
        [scene, result] = piRender(recipe);
        ieAddObject(scene);
        sceneWindow;
        scene = sceneSet(scene,'gamma',0.5);

    otherwise
        error('Unknown optics type %s\n',recipe.get('optics type'));
end

%%

%%