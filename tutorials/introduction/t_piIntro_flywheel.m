%% Gets a skymap from Flywheel; also uses special scene materials
%
% We store the automotive graphics assets in the Flywheel database.
% This script shows how to download a file from Flywheel.  This
% technique is used much more extensively in creating complex driving
% scenes.
%
% This example scene also includes glass and other materials that
% were created for driving scenes.  The script sets up the glass
% material and number of bounces to make the glass appear reasonable.
%
% It also uses piMaterialsGroupAssign() to set a list of materials (in
% this case a mirror) that are part of the scene.
%
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), JSONio, SCITRAN
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntroduction01, t_piIntroduction02


%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
if ~piScitranExists, error('scitran installation required'); end

%% Read pbrt files
sceneName = 'checkerboard_new';
FilePath = fullfile(piRootPath,'data','V3',sceneName);
fname = fullfile(FilePath,[sceneName,'.pbrt']);
if ~exist(fname,'file'), error('File not found'); end

thisR = piRead(fname);

%% get a random car and a random person from flywheel
% take some time, maybe you dont want to run this everytime when you debug
assets = piAssetCreate('ncars',1, 'nped',1);

%% add downloaded asset information to Render recipe.
thisR = piAssetAdd(thisR, assets);
% change position of person
thisR.assets(end).position = [3; 0; 0];
%% Set render quality

% This is a low resolution for speed.
thisR.set('film resolution',[400 300]);
thisR.set('pixel samples',64);

%% Get a sky map from Flywheel, and use it in the scene
thisTime = '16:30';
% We will put a skymap in the local directory so people without
% Flywheel can see the output
if piScitranExists
    [~, skymapInfo] = piSkymapAdd(thisR,thisTime);
    
    % The skymapInfo is structured according to python rules.  We convert
    % to Matlab format here. The first cell is the acquisition ID
    % and the second cell is the file name of the skymap
    s = split(skymapInfo,' ');
    
    % The destination of the skymap file
    skyMapFile = fullfile(fileparts(thisR.outputFile),s{2});
    
    % If it exists, move on. Otherwise open up Flywheel and
    % download the skypmap file.
    if ~exist(skyMapFile,'file')
        fprintf('Downloading Skymap from Flywheel ... ');
        st        = scitran('stanfordlabs');
        % Download the file from acq using fileName
        piFwFileDownload(skyMapFile, s{2}, s{1})% (dest, FileName, AcqID)
        fprintf('complete\n');
    end
end

% This value determines the number of ray bounces.  The scene has
% glass we need to have at least 2 or more.  We start with only 1
% bounce, so it will not appear like glass or mirror.
thisR.integrator.maxdepth.value = 10;

%% This adds materials to all assets in this scene
piMaterialGroupAssign(thisR);

%% Write out the pbrt scene file, based on thisR.

thisR.set('fov',45);
thisR.film.diagonal.value = 10;
thisR.film.diagonal.type  = 'float';
thisR.integrator.subtype = 'bdpt';  
thisR.sampler.subtype = 'sobol';
% Changing the name!!!!  Important to comment and explain!!! ZL, BW
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s.pbrt',sceneName));
thisR.set('outputFile',outFile);

piWrite(thisR,'creatematerials',true);

%% Render.

% Maybe we should speed this up by only returning radiance.
[scene, result] = piRender(thisR);

scene = sceneSet(scene,'name',sprintf('Time: %s',thisTime));
sceneWindow(scene);

%% END