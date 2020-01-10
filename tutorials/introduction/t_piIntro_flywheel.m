%% Gets a skymap from Flywheel; also uses special scene materials
%
% We store the automotive Graphics auto in the Flywheel database.
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
sceneName = 'checkerboard';
FilePath = fullfile(piRootPath,'data','V3',sceneName);
fname = fullfile(FilePath,[sceneName,'.pbrt']);
if ~exist(fname,'file'), error('File not found'); end

thisR = piRead(fname);

%% get a random car and a random person from flywheel
% take some time, maybe you dont want to run this everytime when you debug
% assets = piAssetCreate('ncars',1, 'nped',1);
st = scitran('stanfordlabs');
subject = st.lookup('wandell/Graphics auto/assets');
session = subject.sessions.findOne('label=car');
inputs.ncars = 1;
assetRecipe = piAssetDownload(session,inputs.ncars,'acquisition label','Car_085');
asset.car   = piAssetAssign(assetRecipe,'label','car');

%% add downloaded asset information to Render recipe.
thisR = piAssetAddBatch(thisR, asset);

%% Set render quality

% This is a low resolution for speed.
thisR.set('film resolution',[1280 720]/2);
thisR.set('pixel samples',16);

%% Get a sky map from Flywheel, and use it in the scene
thisTime = '10:15';
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

%% This adds materials to all assets in this scene
thisR.materials.lib=piMateriallib;
piMaterialGroupAssign(thisR);   % We like the glass better this way.

%
colorkd = piColorPick('red');
name = 'HDM_06_002_carbody_black';
material = thisR.materials.list.(name);    % A string labeling the material
target = thisR.materials.lib.carpaint;  % This is the assignment
piMaterialAssign(thisR,material.name,target,'colorkd',colorkd);

% Assign a nice position.
thisR.assets(end).position = [0 0 0]';

thisR.assets(1).scale = [50;50;1];
thisR.assets(1).rotate = piRotationMatrix('xrot',90);

%% Write out the pbrt scene file, based on thisR.
lensname = 'wide.40deg.3.0mm.dat';
thisR_scene.camera = piCameraCreate('pinhole');

thisR.set('fov',45);
thisR.film.diagonal.value = 10;
thisR.lookAt.from = [1 1.3 10];
thisR.lookAt.to = [0 1.2 0];
thisR.film.diagonal.type  = 'float';
thisR.integrator.subtype = 'bdpt';  
thisR.sampler.subtype = 'sobol';
% Changing the name!!!!  Important to comment and explain!!! ZL, BW
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s.pbrt',sceneName));
thisR.set('outputFile',outFile);

piWrite(thisR,'creatematerials',true);


%% Render.

% Maybe we should speed this up by only returning radiance.
[scene, result] = piRender(thisR,'render type','radiance');
if strcmp(scene.type, 'scene')
%     scene = piAIdenoise(scene);
    sceneWindow(scene);
else
    scene = piAIdenoise(scene);
    oiWindow(scene);
end


%% END
function colorR = colorRemove(thisR)
% convert all material surfaces to be gray
colorR = thisR;
materialNameList = fieldnames(thisR.materials.list);
for ii = 1:length(materialNameList)
    target = colorR.materials.lib.matte;
    piMaterialAssign(colorR, ...
        materialNameList{ii}, target,...
        'rgbkd',[0.7 0.7 0.7], 'colorkd',[0.7 0.7 0.7]);
end

end

function matteR = simpleMat(thisR)
% convert all material to be matte material
matteR = thisR;
materialNameList = fieldnames(thisR.materials.list);
for ii = 1:length(materialNameList)
    target = matteR.materials.lib.matte;
    piMaterialAssign(matteR, ...
        materialNameList{ii}, target);
end

end

function motionR = motionRemove(thisR)
% remove all motion effect
motionR = thisR;


end

function lightR = simpleLighting(thisR)
% replace hdr skymap with color skymap
lightR = thisR;
lightR = piLightDelete(lightR, 'all');
blackbody = randi([4500,6500],1);
position = [-30 40 100];
position(1) = position(1)+randi([-40,40],1);
position(3) = position(3)+randi([-40,40],1);
lightR = piLightAdd(lightR, 'type','infinite',...
    'rgbSpectrum',[0.6 0.7 0.8]);
lightR = piLightAdd(lightR, 'type','distant',...
    'blackbody',[blackbody, 1.5],...
    'from', position);
end
