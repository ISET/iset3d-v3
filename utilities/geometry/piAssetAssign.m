function asset = piAssetAssign(fname)
%% Assign properties to a asset stuct.
% 
%
%
%%
for ii = 1: length(fname)
    thisR = piRead(fname{ii},'version',3);
    asset(ii).class = 'car';
    geometry = piGeometryRead(thisR);
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
    asset(ii).name = name;
    asset(ii).geometry = geometry;
    asset(ii).material = thisR.materials.list;
    
    localFolder = fileparts(fname{ii});
    asset(ii).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
    fprintf('%d car created \n',ii);
end
end