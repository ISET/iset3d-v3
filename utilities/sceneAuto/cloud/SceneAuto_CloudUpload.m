%% Combine all render resources by scene type%
%
% Deprecated, we think
%
% To Do: upload resouces to cloud bucket by pre defined scene types
%       
%%
% ieInit;
% 
% if ~mcGcloudExists, mcGcloudConfig; end

%% Create a download list
% roadname = 'city_cross_4lanes_002';
% roadname = 'city_cross_4lanes_construct_001';
% roadname = 'city_cross_6lanes_construct_001';
% roadname = 'city_cross_6lanes_001';
% sessionname = 'city3';
sessionname = [];
% downloadbikes = 1;
% downloadcars   = 1;
% downloadtrucks = 1;
% downloadbuses   = 1;
% downloadpedestrians = 1;
% downloadtrees_tall = 1;
% downloadothers = 1;
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
%%
% roadnamelist{1} = 'city_cross_4lanes_001';
% roadnamelist{1} = 'city_cross_4lanes_002';
% roadnamelist{1} = 'city_cross_6lanes_001';
% % roadnamelist{4} = 'city_cross_4lanes_001_construct';
% roadnamelist{3} = 'city_cross_4lanes_002_construct';
% roadnamelist{2} = 'city_cross_6lanes_001_construct';
% roadnamelist{1} = 'curve_6lanes_001';
% roadnamelist{2} = 'straight_2lanes_parking';
roadnamelist{1} = 'bridge';

roadnamelist{1} = 'highway_straight_4lanes_001';
%% Download Road
for jj = 1:length(roadnamelist)
    roadname = roadnamelist{jj};
st = scitran('stanfordlabs');
hierarchy = st.projectHierarchy('Graphics auto assets');
sessions     = hierarchy.sessions;
for ii=1:length(sessions)
    if isequal(lower(sessions{ii}.label),'road')
        roadSession = sessions{ii};
        break;
    end
end
assetRecipe = piAssetDownload(roadSession,1,...
                              'acquisition',roadname,...
                              'resources',1,...
                              'scitran',st);
%% Combine resources together(iset3d/data, textures, scene)
cityname = sessionname;
tic
% about 90 seconds
% roadname = strcat('suburb_',roadname);
% resourcesCombine(roadname,cityname,52);toc
tic
roadname ='highway_straight_4lanes_001';
resourcesCombineVehiclesOnly(roadname);toc
%% Zip and upload them to google cloud, only upload once.
% about 350 seconds
tic
% zipFileName = strrep(roadname,'suburb',cityname);
if ~piContains(roadname,'city')
    zipFileName = strcat(sessionname,'_',roadname);
else
    zipFileName = strrep(roadname,'city',cityname);
end
    
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
disp('ALL DONE!!!');
toc
end

