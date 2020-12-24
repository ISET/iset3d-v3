function [assetTree, matList] = piAssetTreeLoad(assetTreeName, varargin)
%%
% Synopsis:
%   [assetTree, matList] = piAsseTreetLoad(assetName, varargin)
%
% Inputs:
%   filePath    - path to the asset file
%
% Returns:
%   thisAsset   - loaded asset
%

% Examples:
%{
    [assetTree, matList] = piAssetTreeLoad('bunny');
%}
%% Parse input
p = inputParser;
p.addRequired('assetTreeName', @ischar);
p.parse(assetTreeName, varargin{:})

%%
filePath = which([assetTreeName, '.mat']);
if ~isempty(filePath)
    load(filePath, 'assetTree', 'matList');
else
    warning('Could not find asset file: %s', assetTreeName)
    assetTree = [];
    matList = {};
end

end