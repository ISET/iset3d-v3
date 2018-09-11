
function bikerackList = piBikerackListCreate()
% Download from flywheel
% Test now
currentPath = pwd;
BuildingFolder = '/Volumes/group/wandell/data/NN_Camera_Generalization/Pbrt_Assets_Generation/pbrt_assets/bikerack';
cd(BuildingFolder)
count=0;
for ii = 1:2
count=count+1;
fname = fullfile(BuildingFolder,sprintf('bikerack_%03d',ii),sprintf('bikerack_%03d.pbrt',ii));
    thisR_tmp = piRead(fname,'version',3);
    fds = fieldnames(thisR_tmp);
    thisR = recipe;
    % assign the struct to a recipe class
    for dd = 1:length(fds)
        thisR.(fds{dd})= thisR_tmp.(fds{dd});
    end
        geometry = thisR.assets;
    for jj = 1:length(geometry)
        if ~isequal(lower(geometry(jj).name),'camera')
            index = strfind(geometry(jj).name,'_');
            if isempty(index)
                name = geometry(jj).name;
            else
            name = geometry(jj).name(1:index(1)-1);
            end
            break;
        end
    end
    
    bikerackList(ii).name = name;
    
    bikerackList(ii).geometry = geometry;
    bikerackList(ii).material.list = thisR.materials.list;
    bikerackList(ii).material.txtLines = thisR.materials.txtLines;
    localFolder = fileparts(fname);
    bikerackList(ii).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
end

% for ii = 1:12
% count=count+1;
% fname = fullfile(BuildingFolder,sprintf('tree_short_%03d',ii),sprintf('tree_short_%03d.pbrt',ii));
%     thisR_tmp = piRead(fname,'version',3);
%     fds = fieldnames(thisR_tmp);
%     thisR = recipe;
%     % assign the struct to a recipe class
%     for dd = 1:length(fds)
%         thisR.(fds{dd})= thisR_tmp.(fds{dd});
%     end
%         geometry = thisR.assets;
%     for jj = 1:length(geometry)
%         if ~isequal(lower(geometry(jj).name),'camera')
%             index = strfind(geometry(jj).name,'_');
%             if isempty(index)
%                 name = geometry(jj).name;
%             else
%             name = geometry(jj).name(1:index(1)-1);
%             end
%             break;
%         end
%     end
%     
%     TreeList(count).name = name;
%     
%     TreeList(count).geometry = geometry;
%     TreeList(count).material.list = thisR.materials.list;
%     TreeList(count).material.txtLines = thisR.materials.txtLines;
%     localFolder = fileparts(fname);
%     TreeList(count).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
% end

fprintf('%d bikeracks created \n',count); 
cd(currentPath);
end