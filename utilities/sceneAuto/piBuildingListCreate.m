% function buildingList = piBuildingListCreate()
% % Download from flywheel
% % Test now
% currentPath = pwd;
% BuildingFolder = '/Volumes/group/data/NN_Camera_Generalization/Pbrt_Assets_Generation/pbrt_assets/building';
% cd(BuildingFolder)
% kk=1;
% for ii = 5:20
% fname = fullfile(BuildingFolder,sprintf('building_%03d',ii),sprintf('building_%03d.json',ii));
%     thisR_tmp = jsonread(fname);
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
%     buildingList(kk).name = name;
%     buildingList(kk).geometry = geometry;
%     buildingList(kk).material = thisR.materials.list;
%     localFolder = fileparts(fname);
%     buildingList(kk).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');kk = kk+1;
% end
% fprintf('%d building created \n',kk-1); 
% cd(currentPath);
% end
function buildingList = piBuildingListCreate()
% Download from flywheel
% Test now
currentPath = pwd;
BuildingFolder = '/Volumes/group/data/NN_Camera_Generalization/Pbrt_Assets_Generation/pbrt_assets/building';
cd(BuildingFolder)

for ii = 1:24
fname = fullfile(BuildingFolder,sprintf('building_%03d',ii),sprintf('building_%03d.pbrt',ii));
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
    
    buildingList(ii).name = name;
    
    buildingList(ii).geometry = geometry;
    buildingList(ii).material.list = thisR.materials.list;
    buildingList(ii).material.txtLines = thisR.materials.txtLines;
    localFolder = fileparts(fname);
    buildingList(ii).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
end
fprintf('%d building created \n',ii); 
cd(currentPath);
end