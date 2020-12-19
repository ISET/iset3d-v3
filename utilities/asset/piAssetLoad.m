function asset = piAssetLoad(assetName, varargin)
%%
% Synopsis:
%   thisAsset = piAssetLoad(filePath, varargin)
%
% Inputs:
%   filePath    - path to the asset file
%
% Returns:
%   thisAsset   - loaded asset
%

% Examples:
%{
    thisAsset = piAssetLoad('bunny');
%}
%% Parse input
p = inputParser;
p.addRequired('assetName', @ischar);
p.parse(assetName, varargin{:})

%%
filePath = which([assetName, '.mat']);
if ~isempty(filePath)
    load(filePath, 'asset')
else
    warning('Could not find asset file: %s: ', assetName)
    asset = [];
end

end