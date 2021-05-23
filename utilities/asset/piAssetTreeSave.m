function fullPath = piAssetTreeSave(assetTree, matInRecipe, varargin)
%%
% Synopsis:
%   fullPath = piAssetTreeSave(asset, varargin)
%   
% Inputs:
%   thisST   - asset tree.
%   
% Optional key/val pair:
%   outFilePath - path to save the asset. Either a directory or fullfile
%   path.
%
% Returns:
%   fullPath    - path to the saved file.
%

% Examples:
%{
assetSceneName = 'bunny';
assetName = 'Bunny_B';
thisR = piRecipeDefault('scene name', 'bunny');
thisST = thisR.get('asset', assetName, 'subtree');

fullPath = piAssetTreeSave(thisST, thisR.materials.list);
%}
%% Parse input

p = inputParser;
p.addRequired('assetTree', @(x)isequal(class(x), 'tree'));
p.addRequired('matList', @iscell);
p.addParameter('outFilePath',...
    fullfile(piRootPath, 'local', ['assetTree', '.mat']), @ischar);
p.parse(assetTree, matInRecipe, varargin{:});
assetTree = p.Results.assetTree;
matInRecipe = p.Results.matList;
outFilePath = p.Results.outFilePath;

%% Figure out asset name

[~, ~, e] = fileparts(outFilePath);
if isempty(e)
    % outFilePath is a directory.
    if ~exist(outFilePath, 'dir'), mkdir(outFilePath); end
    fullPath = fullfile(outFilePath, [assetTree.Node{1}.name, '.mat']);
else
    % It is a full file path.
    fullPath = outFilePath;
end

%% Get materials of objects in this tree
ids = assetTree.findleaves;

matList = {};
for ii=1:numel(ids)
    if isequal(assetTree.Node{ids(ii)}.type, 'object')
        matName = piAssetGet(assetTree.Node{ids(ii)}, 'material name');
        [thisIdx, thisMat] = piMaterialFind(matInRecipe, 'name', matName);
        if ~isempty(thisIdx)
            matList(thisMat.name) = thisMat; 
        end
    end
end
%%
save(fullPath, 'assetTree', 'matList');

end