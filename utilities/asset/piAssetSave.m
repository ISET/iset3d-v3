function fullPath = piAssetSave(asset, varargin)
%%
% Synopsis:
%   fullPath = piAssetSave(thisAsset, varargin)
%   
% Inputs:
%   thisAsset   - asset node. Only accept object or light.
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
assetName = 'Bunny_material_BunnyMat';
thisR = piRecipeDefault('scene name', 'bunny');
thisAsset = thisR.get('asset', assetName);

fullPath = piAssetSave(thisAsset);
%}
%% Parse input

p = inputParser;
p.addRequired('thisAsset', @isstruct);
p.addParameter('outFilePath',...
    fullfile(piRootPath, 'local', [asset.name, '.mat']), @ischar);
p.parse(asset, varargin{:});
asset = p.Results.thisAsset;
outFilePath = p.Results.outFilePath;

%%
if ~isequal(asset.type, 'object') || isequal(asset.type, 'light')
    warning('Only object or light can be saved.')
    return;
end

[~, n, e] = fileparts(outFilePath);
if isempty(e)
    % outFilePath is a directory.
    if ~exist(outFilePath, 'dir'), mkdir(outFilePath); end
    fullPath = fullfile(outFilePath, [asset.name, '.mat']);
else
    % It is a full file path.
    asset.name = n;
    fullPath = outFilePath;
end
    

save(fullPath, 'asset')

end