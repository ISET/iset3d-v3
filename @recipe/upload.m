function obj = upload(obj, scene)
% Zip all files (save top-level *.pbrt files) and upload.
%
% Syntax:
%   obj = upload(obj, scene)
%
% Description:
%    1. Zip all files except for the *.pbrt files from top level directory
%
% Inputs:
%    obj   - Object. The object housing the relevant bucket & target info.
%    scene - Struct. A scene structure.
%
% Outputs:
%    obj   - Object. The modified object.
%
% Optional key/value pairs:
%    None.
%

[sceneFolder, sceneFile] = fileparts(scene.outputFile);
[~, sceneName] = fileparts(sceneFolder);

cloudFolder = fullfile(obj.cloudBucket, obj.namespace, sceneName);


% Check if there is a zip file
zipFileName = sprintf('%s.zip', sceneName);
zipFiles = dir(fullfile(sceneFolder, '*.zip'));

if isempty(zipFiles) || length(zipFiles) > 1

    allFiles = dir(sceneFolder);
    allFiles = strcat({allFiles(cellfun(@(x) x(1) ~= '.', ...
        {allFiles(:).name})).name}, {' '});
    toRemove = strcmp(allFiles, 'renderings ');
    allFiles = cell2mat(allFiles(toRemove == false));

    currentPath = pwd;
    cd(sceneFolder);
    cmd = sprintf('zip -r %s %s -x *.jpg *.png *.pbrt *.zip *.mat ', ...
        zipFileName, allFiles);
    system(cmd);
    cd(currentPath);
end

% Rsync is not recursive
cmd = sprintf('gsutil rsync %s %s', sceneFolder, cloudFolder);
system(cmd);

target.camera = scene.camera;
target.local = fullfile(sceneFolder, sprintf('%s.pbrt', sceneFile));
target.remote = fullfile(cloudFolder, sprintf('%s.pbrt', sceneFile));

obj.targets = cat(1, obj.targets, target);

end
