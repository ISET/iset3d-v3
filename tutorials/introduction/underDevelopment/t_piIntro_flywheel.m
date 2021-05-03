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

%% Problem (11/01/20, DHB): This won't run without a flywheel key,
%                           which most people don't have.


%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
if ~piScitranExists, error('scitran installation required'); end

%% Read pbrt files
sceneName = 'plane';
% FilePath = fullfile(piRootPath,'data','V3',sceneName);
fname = '/Users/zhenyi/Desktop/plane/plane.pbrt';
if ~exist(fname,'file'), error('File not found'); end

scene = piRead(fname);

scene.set('fov',45);
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s.pbrt',sceneName));
scene.set('outputFile',outFile);
%% get a random car and a random person from flywheel
% take some time, maybe you dont want to run this everytime when you debug
% assets = piFWAssetCreate('ncars',1, 'nped',1);
st = scitran('stanfordlabs');
acq = st.fw.lookup('wandell/Graphics auto/assets/car/Car_085');
assetRecipe = piFWRecipeDownload(acq);
asset.car = assetRecipe;
dstDir = fullfile(iaRootPath, 'local','Car_085');
assetRecipe.set('outputFile', fullfile(dstDir,'Car_085.pbrt'));
% download assets
piFWResourceDownload(acq, dstDir)

%% add downloaded asset information to Render recipe.
scene = iaAddObject(scene, assetRecipe);
%% Set render quality

% This is a low resolution for speed.
scene.set('film resolution',[400 300]);
scene.set('pixel samples',64);


%% Get a sky map from Flywheel, and use it in the scene
thisTime = '16:30';
% We will put a skymap in the local directory so people without
% Flywheel can see the output
if piScitranExists
    [~, skymapInfo] = piSkymapAdd(scene,thisTime);
    
    % The skymapInfo is structured according to python rules.  We convert
    % to Matlab format here. The first cell is the acquisition ID
    % and the second cell is the file name of the skymap
    s = split(skymapInfo,' ');
    
    % The destination of the skymap file
    skyMapFile = fullfile(fileparts(scene.outputFile),s{2});
    
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

scene.set('max depth',10);

%% This adds materials to all assets in this scene

piAutoMaterialGroupAssign(scene);  

%%
colorkd = piColorPick('black');
name = 'HDM_06_002_carbody_black';
% material = scene.materials.list.(name);    % A string labeling the material
% target = scene.materials.lib.carpaint;  % This is the assignment
% piMaterialAssign(scene,material.name,target,'colorkd',colorkd);
scene.set('material',name,'kd value',colorkd);
% Assign a nice position.
scene.set('asset','0004ID_HDM_06_002_B','translation',[3.5 0 -2]);

%% Write out the pbrt scene file, based on scene, and render

piWrite(scene);

% Maybe we should speed this up by only returning radiance.
[renderingScene, result] = piRender(scene,'render type','radiance');

renderingScene = sceneSet(renderingScene,'name',sprintf('Time: %s',thisTime));
sceneWindow(renderingScene);
sceneSet(renderingScene,'display mode','hdr');         
%% END
