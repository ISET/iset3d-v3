%% s_360CameraRig
% Render an ODS panorama for a scene
%
% TL, Scien Stanford, 2017
%
%% Initialize
ieInit;
if ~piDockerExists, piDockerConfig; end

% PARAMETERS
% -------------------

% Rendering parameters
sceneName = 'whiteRoom';
filmResolution = [128 128];
pixelSamples = 128;
bounces = 1;

% Save parameters
saveDir = '/sni-storage/wandell/users/tlian/360Scenes/ODS';
workingDir = fullfile(saveDir,'workingFolder'); % Save to data server directly to avoid limited space issues


% Check working directory
if(~exist(workingDir,'dir'))
    mkdir(workingDir);
end

% Check save directory
if(~exist(saveDir,'dir'))
    mkdir(saveDir);
end
    
%% Select scene
[pbrtFile,rigOrigin] = selectBitterliScene(sceneName);
recipe = piRead(pbrtFile,'version',3);

%% Figure set camera location
recipe.set('from',rigOrigin);
recipe.set('to',rigOrigin + [0 0 -1]);
recipe.set('up',[0 1 0])

% Set render quality
recipe.set('filmresolution',filmResolution);
recipe.set('pixelsamples',pixelSamples);
recipe.integrator.maxdepth.value = bounces;


for ipd = [64]
    
    recipe.camera = struct('type','Camera','subtype','environment');
    angleTo = 90; angleFrom = 90;
    recipe.camera.ipd = struct('value',ipd*10^-3,'type','float');
    recipe.camera.poleMergeAngleTo = struct('value',angleTo,'type','float');
    recipe.camera.poleMergeAngleFrom = struct('value',angleFrom,'type','float');
    %recipe.convergencedistance = struct('value',1,'type','float'); % Default
    %is infinity
    
    sceneName = sprintf('ODS_%d_%d_%d_%d.pbrt',filmResolution(1),filmResolution(2),pixelSamples,bounces);
    recipe.set('outputFile',fullfile(saveDir,sceneName));
    
    piWrite(recipe);
    [scene, result] = piRender(recipe);
    
    ieAddObject(scene);
    sceneWindow;
    
    % Save the OI along with location information
    [~,n,e] = fileparts(sceneName);
    sceneFilename = fullfile(saveDir,strcat(n,'.mat'));
    save(sceneFilename,'ipd','angleTo','angleFrom');

end