function asset = piAssetListCreate(sessionName,acquisitionName,st)
%% Download all building/trees/cars/pedestrains or necessary assets by scene type 
hierarchy = st.projectHierarchy('Graphics assets');
sessions     = hierarchy.sessions;
containerID = idGet(session,'data type','session');
fileType = 'CG Resource';
[resourceFiles, resource_acqID] = st.dataFileList('session', containerID, fileType);
fileType_json ='source code'; % json
[recipeFiles, recipe_acqID] = st.dataFileList('session', containerID, fileType_json);
for ii=1:length(sessions)
    if isequal(lower(sessions{ii}.label),sessionName)
        targetSession = sessions{ii};
        break;
    end
end
acquisitions = st.list('acquisition',targetSession.id);

for ii=1:length(acquisitions)
    if isequal(lower(acquisitions{ii}.label),lower(acquisitionName))
        Acq_index = ii;
        break;
    end
end
files = st.list('file',acquisitions{Acq_index}.id);
kk=1;

%%
for jj = 1:length(files)
    if isequal(files{jj}.type,'source code')
        [~,n,~] = fileparts(files{jj}.name);
        [~,n,~] = fileparts(n); % extract file name
        % Download the scene to a destination zip file
        localFolder = fullfile(piRootPath,'local',n);
        destName_recipe = fullfile(localFolder,sprintf('%s.json',n));
        % we might not need to download zip files every time, use
        % resourceCombine.m 08/14 --zhenyi
        destName_resource = fullfile(localFolder,sprintf('%s.zip',n));
        if ~exist(localFolder,'dir'), mkdir(localFolder)
            st.fileDownload(recipeFiles{downloadList(ii).index}{1}.name,...
                'container type', 'acquisition' , ...
                'container id',  recipe_acqID{downloadList(ii).index} ,...
                'destination',destName_recipe);
            
            st.fileDownload(resourceFiles{downloadList(ii).index}{1}.name,...
                'container type', 'acquisition' , ...
                'container id',  resource_acqID{downloadList(ii).index} ,...
                'unzip', true, ...
                'destination',destName_resource);
        end
        assetRecipe{ii}.name   = destName_recipe;
    end
end
% for jj = 1:length(files)
%     if isequal(files{jj}.type,'source code')
%     FileInfo = st.fw.getAcquisitionFileInfo(acquisitions{Acq_index}.id,files{jj}.name);
%     InfoList{kk} = FileInfo.info;
%     kk = kk+1;
%     end
% end
%%
    thisR_tmp = jsonread(assetRecipe{ii}.name);
    fds = fieldnames(thisR_tmp);
    thisR = recipe;
    % assign the struct to a recipe class
    for dd = 1:length(fds)
        thisR.(fds{dd})= thisR_tmp.(fds{dd});
    end
    %% assign random color for carpaint
    mlist = fieldnames(thisR.materials.list);
    for kk = 1:length(mlist)
        if  contains(mlist{kk},'paint_base') && ~contains(mlist{kk},'paint_mirror')
            name = mlist{kk};
            material = thisR.materials.list.(name);    % A string labeling the material
            target = thisR.materials.lib.carpaintmix.paint_base;  %
            colorkd = piColorPick('random');
            piMaterialAssign(thisR,material.name,target,'colorkd',colorkd);
        end
    end
    %%    
    asset(ii).class = label;
    geometry = thisR.assets;
    for jj = 1:length(geometry)
        if ~isequal(lower(geometry(jj).name),'camera') && ...
                ~contains(lower(geometry(jj).name),'light')
            name = geometry(jj).name;
            break;
        end
    end
    [f,n,e] = fileparts(assetRecipe{ii}.name);
    asset(ii).name = name;
    asset(ii).index = n;
    asset(ii).geometry = geometry;
    if ~isequal(assetRecipe{ii}.count,1)
        for hh = 1: length(asset(ii).geometry)
            pos = asset(ii).geometry(hh).position;
            rot = asset(ii).geometry(hh).rotate;
            asset(ii).geometry(hh).position = repmat(pos,1,uint8(assetRecipe{ii}.count));
            asset(ii).geometry(hh).rotate = repmat(rot,1,uint8(assetRecipe{ii}.count));
        end
    end
    asset(ii).material.list = thisR.materials.list;
    asset(ii).material.txtLines = thisR.materials.txtLines;
    
    localFolder = fileparts(assetRecipe{ii}.name);
    asset(ii).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
end