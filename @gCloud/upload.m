function [ obj ] = upload( obj, scene )

% TL Note: Scene == recipe here, maybe we should rename? 

% 1. Zip all files except for the *.pbrt files from top level directory

[sceneFolder, sceneFile] = fileparts(scene.outputFile);
[~, sceneName] = fileparts(sceneFolder);

cloudFolder = fullfile(obj.cloudBucket,obj.namespace,sceneName);

% If renderDepth flag is on, generate depth files
if(obj.renderDepth)
    
    depthScene = piRecipeConvertToMetadata(scene);
    
    % Always overwrite the depth file, but don't copy over the whole directory
    piWrite(depthScene,'overwritepbrtfile',true,...
        'overwritelensfile',false,...
        'overwriteresources',false);
end

% Check if there is a zip file
zipFileName = sprintf('%s.zip',sceneName);
zipFiles = dir(fullfile(sceneFolder,'*.zip'));

if isempty(zipFiles) || length(zipFiles) > 1
    
    allFiles = dir(sceneFolder);
    allFiles = strcat({allFiles(cellfun(@(x) x(1) ~= '.',{allFiles(:).name})).name},{' '});
    toRemove = strcmp(allFiles,'renderings ');
    allFiles = cell2mat(allFiles(toRemove==false));

    currentPath = pwd;
    cd(sceneFolder);
    cmd = sprintf('zip -r %s %s -x *.jpg *.png *.pbrt *.zip *.mat ',zipFileName,allFiles);
    system(cmd);
    cd(currentPath);
end

% Rsync is not recursive
cmd = sprintf('gsutil rsync %s %s',sceneFolder,cloudFolder);
system(cmd);

target.camera = scene.camera;
target.local = fullfile(sceneFolder,sprintf('%s.pbrt',sceneFile));
target.remote = fullfile(cloudFolder,sprintf('%s.pbrt',sceneFile));
target.renderingComplete = 0;
target.depthRender = 0;

obj.targets = cat(1,obj.targets,target);      

% Add depth target
if(obj.renderDepth)
    
    target.camera = depthScene.camera;
    target.local = fullfile(sceneFolder,sprintf('%s_depth.pbrt',sceneFile));
    target.remote = fullfile(cloudFolder,sprintf('%s_depth.pbrt',sceneFile));
    target.renderingComplete = 0;
    target.depthRender = 1;
    
    obj.targets = cat(1,obj.targets,target);

end

end

