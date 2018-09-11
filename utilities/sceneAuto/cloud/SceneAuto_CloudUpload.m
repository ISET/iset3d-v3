%% Combine all render resources by scene type
% To Do: upload resouces to cloud bucket by pre defined scene types
%       
%%
ieInit;

if ~mcGcloudExists, mcGcloudConfig; end

%% Create a download list
roadname = 'city_cross_4lanes_002';
sessionname = 'city_1';
downloadbikes = 1;
downloadcars   = 1;
downloadtrucks = 1;
downloadbuses   = 1;
downloadpedestrians = 1;
downloadtrees_tall = 1;
downloadothers = 1;
%% Download all required assets
% piAssetsDownload_cloud('session','car');
% piAssetsDownload_cloud('session','bike');
% piAssetsDownload_cloud('session','truck');
% piAssetsDownload_cloud('session','bus');
% piAssetsDownload_cloud('session','pedestrian');
% piAssetsDownload_cloud('session','others');
% piAssetsDownload_cloud('session','tree');
% 
% 
% piAssetsDownload_cloud('session','others','acquisition','streetlight_short_001');
% piAssetsDownload_cloud('session','others','acquisition','streetlight_short_002');
% piAssetsDownload_cloud('session','others','acquisition','streetlight_tall_001');
%% Download building

piAssetsDownload_cloud('session',sessionname);
%% Combine resources together(iset3d/data, textures, scene)
cityname = 'city1';
resourcesCombine(roadname,cityname,25);

%% Zip and upload them to google cloud, only upload once.
zipFileName = 'city1_cross_4lanes_002';
sceneFolder = fullfile(piRootPath,'local',zipFileName);
chdir(sceneFolder);
allFiles = dir(sceneFolder);

% Convert the listing into a set of file names, excluding the
% listings that start with a dot (.)
allFiles = cell2mat(strcat({allFiles(cellfun(@(x) x(1) ~= '.',{allFiles(:).name})).name},{' '}));

% Remember where you are, and then change to the scene folder

% Zip recursively but excluding certain file types and any other
% zip files that might have been put here.
fprintf('Zipping into %s\n',zipFileName);
cmd = sprintf('zip -r %s %s -x *.jpg renderings/* *.zip *.json',zipFileName,allFiles);
status = system(cmd);
zipFileFullPath = fullfile(sceneFolder,[zipFileName,'.zip']);
% upload
cloudFolder = fullfile(gcp.cloudBucket,gcp.namespace,zipFileName);
cmd = sprintf('gsutil cp %s %s/',  ...
    zipFileFullPath,...
    cloudFolder);
system(cmd);



