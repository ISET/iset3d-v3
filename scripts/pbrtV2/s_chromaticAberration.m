%% s_chromaticAberration.m
%
% Demonstrate the chromatic aberration present in lens rendering. Adapted
% from s_texturedPlane.m
%
% TL SCIEN Team, 2018

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the pbrt scene
fname = fullfile(piRootPath,'data','texturedPlane','texturedPlane.pbrt');

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

% Setup working folder
workingDir = fullfile(piRootPath,'local','texturedPlane');
if(~isdir(workingDir))
    mkdir(workingDir);
end

%% Scale and translate the plane

scale = 0.5; % 1000*0.5 = 500 mm
translate = 1000; % mm

% The textured plane has specifically been named "Plane" in this scene. We
% also know that our camera is located at the origin and looking down the
% positive y-axis. 
% Note: The order of scaling and translating matters!
piObjectTransform(thisR,'Plane','Scale',[scale scale scale]); % The plane is oriented in the x-z plane
piObjectTransform(thisR,'Plane','Translate',[0 translate 0]); 

%% Attach a desired texture
imageName = 'squareResolutionChart.exr';
imageFile = fullfile(piRootPath,'data','imageTextures',imageName);

copyfile(imageFile,workingDir);
thisR = piWorldFindAndReplace(thisR,'dummyTexture.exr',imageName);

%% Attach a lens

thisR.set('camera','omni');
thisR.set('aperture',2);  % The number of rays should go up with the aperture 
thisR.set('film resolution',128);
thisR.set('rays per pixel',128);
thisR.set('diagonal', 5);
thisR.set('filmdistance',9.2)

%% Render once without chromatic aberration

[p,n,e] = fileparts(fname); 
thisR.outputFile = fullfile(workingDir,[n,e]);

piWrite(thisR);

oi = piRender(thisR);
oi = oiSet(oi,'name','noCA');

% Show it in ISET
oiWindow(oi);  

%% Turn on chromatic aberration and render

thisR.set('chromatic aberration','true');

piWrite(thisR);

oiCA = piRender(thisR);
oiCA = oiSet(oiCA,'name','CA');

% Show it in ISET
oiWindow(oiCA);  
