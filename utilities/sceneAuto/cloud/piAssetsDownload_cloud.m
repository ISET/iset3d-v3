function piAssetsDownload_cloud(varargin)

error('Deprecated')

p = inputParser;
p.addParameter('session','',@ischar);
p.addParameter('acquisition','',@ischar);
p.parse(varargin{:});


sessionname = p.Results.session;
acquisitionname  = p.Results.acquisition;

%%
st = scitran('stanfordlabs');
hierarchy = st.projectHierarchy('Graphics auto assets');

% projects     = hierarchy.project;
sessions     = hierarchy.sessions;
% acquisitions = hierarchy.acquisitions;
%%
for ii=1:length(sessions)
    if isequal(lower(sessions{ii}.label),sessionname)
        thisSession = sessions{ii};
        break;
    end
end
%%
containerID = idGet(thisSession,'data type','session');
fileType = 'CG Resource';
[resourceFiles, resource_acqID] = st.dataFileList('session', containerID, fileType);

%%
nDatabaseAssets = length(resourceFiles);
if isempty(acquisitionname)
    for ii = 1:nDatabaseAssets
        [~,n,~] = fileparts(resourceFiles{ii}{1}.name);
        [~,n,~] = fileparts(n); % extract file name
        % Download the scene to a destination zip file
        localFolder = fullfile(piRootPath,'local',n);
        destName_resource = fullfile(localFolder,sprintf('%s.zip',n));
        if ~exist(localFolder,'dir')
            mkdir(localFolder)
        end
        piFwFileDownload(destName_resource, resourceFiles{ii}{1}.name, resource_acqID{ii});   
    end
    
    fprintf('%d Files downloaded.\n',nDatabaseAssets);
else
    for ii=1:length(resourceFiles)
        if piContains(lower(resourceFiles{ii}{1}.name),acquisitionname)
            thisAcq = resourceFiles{ii}{1};
            thisID =  resource_acqID{ii};
            break;
        end
    end
    [~,n,~] = fileparts(thisAcq.name);
    [~,n,~] = fileparts(n); % extract file name
    % Download the scene to a destination zip file
    localFolder = fullfile(piRootPath,'local',n);
    % we might not need to download zip files every time, use
    % resourceCombine.m 08/14 --zhenyi
    destName_resource = fullfile(localFolder,sprintf('%s.zip',n));
    if ~exist(localFolder,'dir')
        mkdir(localFolder)
    end
    piFwFileDownload(destName_resource, thisAcq, thisID);
    fprintf('%s downloaded.\n',n);
end
end