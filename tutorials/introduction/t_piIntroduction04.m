%% Render using a lens
%
%
% Dependencies:
%    ISET3d, ISETCam or ISETBio, JSONio, SCITRAN
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral:test
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntroduction*


%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
if ~piScitranExists, error('scitran installation required'); end

%% Read pbrt files

% This is the INPUT file name
sceneName = 'ChessSet'; sceneFileName = 'ChessSet.pbrt';

% The output will be written here
inFolder = fullfile(piRootPath,'local','scenes');
piPBRTFetch(sceneName,'pbrtversion',3,'destinationFolder',inFolder);

%%

inFile = fullfile(inFolder,sceneName,sceneFileName);
thisR = piRead(inFile);

%% Set render quality

% This is a relatively low resolution for speed.
thisR.set('film resolution',[400 300]);
thisR.set('pixel samples',64);

%% Set output file

oiName = 'ChessSet';
outFile = fullfile(piRootPath,'local',oiName,sprintf('%s.pbrt',oiName));
thisR.set('outputFile',outFile);
outputDir = fileparts(outFile);

%% Get the skymap from Flywheel

% Use a small skymap.  We should make all the skymaps small, but
% 'noon' is not small!
[~, skymapInfo] = piSkymapAdd(thisR,'12:30');

% The skymapInfo is structured according to python rules.  We convert
% to Matlab format here.
s = split(skymapInfo,' ');

% If the skymap is there already, move on.  Otherwise open up Flywheel
% and download it.
skyMapFile = fullfile(fileparts(thisR.outputFile),s{2});
if ~exist(skyMapFile,'file')
    fprintf('Downloading Skymap from Flywheel ... ');
    st        = scitran('stanfordlabs');
    acq       = st.fw.get(s{1});    % Get the acquisition using the ID
    thisFile  = acq.getFile(s{2});  % Get the FileEntry for this skymap
    thisFile.download(skyMapFile);  % Download the file
    fprintf('complete\n');
end

%% List material library

% This value determines the number of ray bounces.  The scene has
% glass we need to have at least 2 or more.  We start with only 1
% bounce, so it will not appear like glass or mirror.
thisR.integrator.maxdepth.value = 4;

% This adds a mirror and other materials that are used in driving.s
% piMaterialGroupAssign(thisR);

%%
%{
lensfile = '';
%}

%
% This runs but includes the 'sun', so we need HDR rendering to see it
% We are not in good shape with lenses and lens distances.
% More editing and checking of units are needed.

% lensfile = 'fisheye.87deg.6.0mm.dat';
lensfile = 'dgauss.22deg.50.0mm.dat';
fprintf('Using this lens %s\n',lensfile);
thisR.camera = piCameraCreate('realistic','lensFile',lensfile,'pbrtVersion',3);
% thisR.set('autofocus',true);
thisR.camera.focusdistance.value = 0.5;
% thisR.camera.aperturediameter.value = 5.5;
%}

thisR.set('fov',45);
thisR.film.diagonal.value=  30;
thisR.film.diagonal.type = 'float';

thisR.integrator.subtype = 'path';  % bdpt
thisR.sampler.subtype = 'sobol';

% thisR.integrator.lightsamplestrategy.type = 'string';
% thisR.integrator.lightsamplestrategy.value = 'spatial';
% thisR.lookAt.to(3) = 0;

% thisR.lookAt.from(1) = 3;
piWrite(thisR,'creatematerials',true);

%% Render mesh
% [meshImage,result] = piRender(thisR, 'render type','mesh');
% vcNewGraphWin;
% imagesc(meshImage);

%% Render.  

if isempty(lensfile)
    % Get a depth map to figure out the distances
    [scene, result] = piRender(thisR,'render type','both');
    scene = sceneSet(scene,'name',sprintf('%s',oiName));
    sceneWindow(scene);
else
    
    % Maybe we should speed this up by only returning radiance.
    [oi, result] = piRender(thisR);
    dmap = oiGet(oi,'depth map');
    ieNewGraphWin; histogram(dmap(:),100);
    xlabel('Meters');
    
    oi = oiSet(oi,'name',sprintf('%s',oiName));
    oiWindow(oi);
end

%% END