function [assetList, missingAssets,...
          textureList, missingTextures,...
          lightList, missingLights] = piRenderValidate(thisR)
% Validate the existence of files needed for rendering.
%
% Synopsis:
%   [assetList, missingAssets,...
%    textureList, missingTextures,...
%    lightList, missingLights] = piRenderValidate(thisR)
%
% Inputs:
%   thisR:
%
% Outputs:
%   
%
% Examples:
%{
  thisR = piJson2Recipe('SimpleScene.json');

  [assetList, missingAssets,...
   textureList, missingTextures,...
   lightList, missingLights] = piRenderValidate(thisR);
%}
%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(thisR), 'recipe'));
p.parse(thisR);

%% Textures
textureList = {};
missingTextures = [];

tList = thisR.textures.list;
for ii = 1:numel(tList)
    if isfield(tList{ii}, 'filename') && ~isempty(tList{ii}.filename.value)
        fpath = fullfile(thisR.get('output dir'), tList{ii}.filename.value);
        textureList{end + 1} = fpath;
        if exist(fpath, 'file')
        else
            missingTextures(end + 1) = numel(textureList);
        end
    end
end
%% Lights
lightList = {};
missingLights = [];

lgtList = thisR.lights;
for ii = 1:numel(lgtList)
    curLight = lgtList{ii};
    % Infinite lights needs an image map
    if isfield(curLight, 'mapname') && ~isempty(curLight.mapname.value)
        fpath = fullfile(thisR.get('output dir'), curLight.mapname.value);
        lightList{end + 1} = fpath;
        if exist(fpath, 'file')
        else
            missingLights(end + 1) = numel(lightList);
        end
    end
    
    % Sometimes the light needs .spd spectrum file
    if ischar(curLight.spd.value)
        [~, ~, e] = fileparts(curLight.spd.value);
        % If it has extension, it is a file.
        if ~isempty(e)
            fpath = fullfile(thisR.get('output dir'), curLight.spd.value);
            lightList{end + 1} = fpath;
            if exist(fpath, 'file')
            else
                missingLights(end + 1) = numel(lightList);
            end
        end
    end
end

%% Shape filenames of the leaf nodes
assetList = {};
missingAssets = [];

ids = thisR.assets.findleaves;
for ii = 1:numel(ids)
    curNode = thisR.get('assets', ids(ii));
    if isequal(curNode.type, 'object')
        if isfield(curNode.shape, 'filename') && ~isempty(curNode.shape.filename)
            fpath = fullfile(thisR.get('output dir'), curNode.shape.filename);
            assetList{end + 1} = fpath;
            if exist(fpath, 'file')
            else 
                missingAssets(end + 1) = numel(assetList);
            end
        end
    elseif isequal(curNode.type, 'light')
        for jj = 1:numel(curNode.lght)
            curLight = curNode.lght{jj};
            if isfield(curLight, 'mapname') && ~isempty(curLight.mapname.value)
                fpath = fullfile(thisR.get('output dir'), curLight.mapname.value);
                lightList{end + 1} = fpath;
                if exist(fpath, 'file')
                else
                    missingLights(end + 1) = numel(lightList);
                end
            end
            
            if ischar(curLight.spd.value)
                [~, ~, e] = fileparts(curLight.spd.value);
                % If it has extension, it is a file.
                if ~isempty(e)
                    fpath = fullfile(thisR.get('output dir'), curLight.spd.value);
                    lightList{end + 1} = fpath;
                    if exist(fpath, 'file')
                    else
                        missingLights(end + 1) = numel(lightList);
                    end
                end
            end
        end

    end
end

if sum(missingAssets) + sum(missingTextures) +  sum(missingLights)> 0
    warning('Some files are not found, please check')
end
end