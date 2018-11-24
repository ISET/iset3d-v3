
function StreetlightList = piStreetlightListCreate()
% Download from flywheel
% Test now
currentPath = pwd;
BuildingFolder = '/Volumes/group/wandell/data/NN_Camera_Generalization/Pbrt_Assets_Generation/pbrt_assets/streetlight';
cd(BuildingFolder)
count=0;
% for ii = 1:2
count=count+1;
fname = fullfile(BuildingFolder,sprintf('streetlight_tall_%03d',1),sprintf('streetlight_tall_%03d.pbrt',1));
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
    
    StreetlightList(1).name = name;
    
    StreetlightList(1).geometry = geometry;
    StreetlightList(1).material.list = thisR.materials.list;
    StreetlightList(1).material.txtLines = thisR.materials.txtLines;
    localFolder = fileparts(fname);
    StreetlightList(1).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
for ii = 1:2
count=count+1;
fname = fullfile(BuildingFolder,sprintf('streetlight_short_%03d',ii),sprintf('streetlight_short_%03d.pbrt',ii));
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
    
    StreetlightList(count).name = name;
    
    StreetlightList(count).geometry = geometry;
    StreetlightList(count).material.list = thisR.materials.list;
    StreetlightList(count).material.txtLines = thisR.materials.txtLines;
    localFolder = fileparts(fname);
    StreetlightList(count).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
end
fprintf('%d streetlights created \n',count); 
cd(currentPath);
end

