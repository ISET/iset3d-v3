function asset = piAssetAssign(fname,varargin)
%% Assign properties to a asset stuct.
% 
%
%%
p = inputParser;
varargin = ieParamFormat(varargin);
p.addParameter('label','');
p.parse(varargin{:});
label = p.Results.label;
%%
for ii = 1: length(fname)
    thisR = piRead(fname{ii},'version',3);
    % assign random color for carpaint of cloth, 
    piMaterialGroupAssign(thisR);
    asset(ii).class = label;
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
    asset(ii).name = name;
    asset(ii).geometry = geometry;
    asset(ii).material = thisR.materials.list;
    
    localFolder = fileparts(fname{ii});
    asset(ii).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
    fprintf('%d %s created \n',ii,label);
end
end