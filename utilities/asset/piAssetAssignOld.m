function asset = piAssetAssignOld(assetRecipe,varargin)
%% Assign properties from an assetRecipe on Flywheel to an asset struct
%
% Syntax:
%  asset = piAssetAssign(assetRecipe,varargin)
%
% Inputs
%  assetRecipe
%
% Key/val pairs
%
% Outputs
%   asset
%
% Zhenyi Liu
%
% See also
%

%% Parse
%
varargin =ieParamFormat(varargin);

p = inputParser;
p.addParameter('label','');
p.parse(varargin{:});

label = p.Results.label;

%% Reads the json file for the recipe and assigns fields to the asset
for ii = 1: length(assetRecipe)
    %{
    % Read the json recipe into the Matlab recipe class
    thisR_tmp =  (assetRecipe{ii}.name);
    fds = fieldnames(thisR_tmp);
    thisR = recipe;
    % assign the struct to a recipe class
    for dd = 1:length(fds)
        thisR.(fds{dd})= thisR_tmp.(fds{dd});
    end
    %}
    thisR = piJson2Recipe(assetRecipe{ii}.name, 'update', false);
    thisR.materials.lib = piMateriallib;
    %% force y=0
    for ll = 1:length(thisR.assets)
        thisR.assets(ll).position = [0;0;0];
    end
    thisR.assets(ll).motion = [];
    
    %% Assign random color for carpaint
    mlist = fieldnames(thisR.materials.list);
    for kk = 1:length(mlist)
        if  piContains(mlist{kk},'paint_base') && ~piContains(mlist{kk},'paint_mirror')
            name = mlist{kk};
            material = thisR.materials.list.(name);    % A string labeling the material
            target = thisR.materials.lib.carpaintmix.paint_base;  %
            colorkd = piColorPick('random');
            piMaterialAssign(thisR,material.name,target,'colorkd',colorkd);
        elseif piContains(mlist{kk},'carpaint') && ~piContains(mlist{kk},'paint_base')
            name = cell2mat(mlist(kk));
            material = thisR.materials.list.(name);    % A string labeling the material
            target = thisR.materials.lib.carpaintmix;  %
            colorkd = piColorPick('random');
            piMaterialAssign(thisR,material.name,target,'colorkd',colorkd);
        elseif piContains(mlist(kk),'lightsback') || piContains(mlist(kk),'lightback')
            name = cell2mat(mlist(kk));
            material = thisR.materials.list.(name);
            target = thisR.materials.lib.glass;
            rgbkr = [1 0.1 0.1];
            piMaterialAssign(thisR,material.name,target,'rgbkr',rgbkr);
            thisR.materials.list.(name).rgbkt = [0.7 0.1 0.1];
        elseif piContains(mlist(kk),'tire') % empty the slot if there is a texture assigned
            name = cell2mat(mlist(kk));
            thisR.materials.list.(name).texturekd = [];
        end
    end
    
    %% We need to describe this (ZL).
    asset(ii).class = label;
    geometry = thisR.assets;
    [~,scenename] = fileparts(thisR.outputFile);
    for jj = 1:length(geometry)
        if ~isequal(lower(geometry(jj).name),'camera') && ...
                ~piContains(lower(geometry(jj).name),'light') && ...
                ~piContains(lower(geometry(jj).name),'rider_bike')
            name = geometry(jj).name;
            geometry(jj).name = sprintf('%s_%s',label,scenename);% name on 'flywheel_label'
            break;
        end
    end
    [~,n,~] = fileparts(assetRecipe{ii}.name);
    if ~exist('name'), break;end
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
    
    %%
    localFolder = fileparts(assetRecipe{ii}.name);
    asset(ii).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
    asset(ii).fwInfo       = assetRecipe{ii}.fwInfo;
    % fprintf('%d %s created \n',ii,label);
end
end