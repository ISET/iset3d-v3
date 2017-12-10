function [ obj ] = upload( obj, scene )

% 1. Zip all files except for the *.pbrt files from top level directory

[sceneFolder, sceneFile] = fileparts(scene.outputFile);
[~, sceneName] = fileparts(sceneFolder);

cloudFolder = fullfile(obj.cloudBucket,obj.namespace,sceneName);


zipFileName = sprintf('%s.zip',sceneName);

% Check if there is a zip file
zipFiles = dir(fullfile(sceneFolder,'*.zip'));

if isempty(zipFiles) || length(zipFiles) > 1
    
    allFiles = dir(sceneFolder);
    allFiles = cell2mat(strcat({allFiles(cellfun(@(x) x(1) ~= '.',{allFiles(:).name})).name},{' '}));


    currentPath = pwd;
    cd(sceneFolder);
    cmd = sprintf('zip -r %s %s -x *.jpg *.png *.pbrt *.zip',zipFileName,allFiles);
    system(cmd);
    cd(currentPath);
    
    cmd = sprintf('gsutil cp %s/%s %s/',sceneFolder,zipFileName,...
                                        cloudFolder);
else
    cmd = sprintf('gsutil cp %s/%s %s/',sceneFolder,zipFiles(1).name,...
                                            cloudFolder);
end
system(cmd);

cmd = sprintf('gsutil cp %s/%s.pbrt %s/',sceneFolder,sceneFile,...
                                          cloudFolder);
system(cmd);

target.camera = scene.camera;
target.local = fullfile(sceneFolder,sprintf('%s.pbrt',sceneFile));
target.remote = fullfile(cloudFolder,sprintf('%s.pbrt',sceneFile));

obj.targets = cat(1,obj.targets,target);      


end
