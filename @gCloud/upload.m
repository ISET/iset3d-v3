function [ obj ] = upload( obj, scene )

% 1. Zip all files except for the *.pbrt files from top level directory

[sceneFolder, sceneFile] = fileparts(scene.outputFile);
[~, sceneName] = fileparts(sceneFolder);

zipFileName = sprintf('%s.zip',sceneName);

% Check if there is a zip file
zipFiles = dir(fullfile(sceneFolder,'*.zip'));

if isempty(zipFiles) || length(zipFiles) > 1
    
    allFiles = dir(sceneFolder);
    allFiles = cell2mat(strcat({allFiles(cellfun(@(x) x(1) ~= '.',{allFiles(:).name})).name},{' '}));


    currentPath = pwd;
    cd(sceneFolder);
    cmd = sprintf('zip -r %s %s -x *.jpg *.png *.pbrt *.dat *.zip',zipFileName,allFiles);
    system(cmd);
    cd(currentPath);
end

cloudFolder = fullfile(obj.cloudBucket,obj.namespace,sceneName);

cmd = sprintf('gsutil cp %s/%s %s/%s.pbrt %s/',sceneFolder,zipFileName,...
                                          sceneFolder,sceneFile,...
                                          cloudFolder);
system(cmd);




end

