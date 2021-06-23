function fullOutPath = piAssetTreeSave(assetTree, matInRecipe, varargin)
% Save a subtree of a recipe in a mat-file for subsequent use
%
% Synopsis:
%   fullOutPath = piAssetTreeSave(asset, varargin)
%   
% Description
%   We save a subtree of assets from a recipe in order to reuse the subtree
%   in other renderings. This routine takes the subtree and the list of all
%   the materials from the original recipe as input and saves the necessary
%   terms in a mat-file.  The mat-file can be reloaded and added to the
%   root branch of another rendering.
%
% Inputs:
%   assetTree   - An asset tree, usually extracted from a larger recipe
%   matInRecipe - The materials list from the recipe.  This is a
%                 container.Map object, as in the recipe
%                 (thisR.materials.list) 
%   
% Optional key/val pair:
%   outFilePath - A directory or fullfile path.  Asset subtrees are
%                 generally saved in data/assets
%
% Returns:
%   fullOutPath    - path to the saved file.
%
% See also
%    piAssetTreeLoad

% Examples:
%{
% The Stanford Bunny
 assetSceneName = 'bunny';
 assetName = 'Bunny_B';
 thisR    = piRecipeDefault('scene name', 'bunny');
 thisST   = thisR.get('asset', assetName, 'subtree');
 fullPath = piAssetTreeSave(thisST, thisR.materials.list,'outFilePath',fullfile(piRootPath,'data','assets','bunny.mat'));
%}
%{
% XYZ coordinate axis to insert in a scene
 assetSceneName = 'coordinate';
 assetName = 'Coordinate_B';
 thisR     = piRecipeDefault('scene name', 'coordinate');
 thisST    = thisR.get('asset', assetName, 'subtree');
 fullPath  = piAssetTreeSave(thisST, thisR.materials.list,'outFilePath',fullfile(piRootPath,'data','assets','coordinate.mat'));
%}

%% Parse input

p = inputParser;

defaultOut = fullfile(piRootPath, 'local', ['assetTree', '.mat']);
p.addRequired('assetTree', @(x)isequal(class(x), 'tree'));
p.addRequired('matList', @(x)(isa(x,'containers.Map')));
p.addParameter('outFilePath',defaultOut, @ischar);

p.parse(assetTree, matInRecipe, varargin{:});

assetTree   = p.Results.assetTree;
matInRecipe = p.Results.matList;
outFilePath = p.Results.outFilePath;

%% Figure out the output file name

[~, ~, e] = fileparts(outFilePath);
if isempty(e)
    % outFilePath is a directory.
    if ~exist(outFilePath, 'dir'), mkdir(outFilePath); end
    fullOutPath = fullfile(outFilePath, [assetTree.Node{1}.name, '.mat']);
else
    % It is already a full file path.
    fullOutPath = outFilePath;
end

%% Get materials of objects in this tree

% These are the objects in the asset tree
ids = assetTree.findleaves;

% Find the materials for each of the objects
matList = containers.Map;
for ii=1:numel(ids)
    if isequal(assetTree.Node{ids(ii)}.type, 'object')
        % Leaves are objects and they have a material
        matName = piAssetGet(assetTree.Node{ids(ii)}, 'material name');
        [thisIdx, thisMat] = piMaterialFind(matInRecipe, 'name', matName);
        if ~isempty(thisIdx)
            matList(thisMat.name) = thisMat; 
        end
    end
end

%%
save(fullOutPath, 'assetTree', 'matList');

end