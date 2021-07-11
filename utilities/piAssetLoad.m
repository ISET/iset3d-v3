function asset = piAssetLoad(fname)
% Load a mat-file containing an asset recipe
%
% Synopsis
%   asset = piAssetLoad(fname)
%
% Input
%   fname - filename of the asset mat-file
%
% Output
%  asset - a struct containing the recipe and the mergeNode
%
%   asset.thisR     - recipe for the asset
%   asset.mergeNode - Node in the asset tree to be used for merging 
%
% Description
%   We store certain simple asset recipes as mat-files for easy loading and
%   insertion into scenes.  The assets are created in the script
%   s_assetsCreate
%
%   The piRecipeMerge function works to combine
%   these with general scenes.
%
%   The asset recipes are stored along with the critical node used for
%   merging. The mat-file slot for the input is just the name of the 
%
% See also
%   s_assetsCreate, piRootPath/data/assets
%

%%
if ~exist('fname','var') || isempty(fname)
    error('The asset name must be specified');
end

%%
[p,n,e] = fileparts(fname);
if isempty(e), e = '.mat'; end
fname = fullfile(p,[n,e]);

fname = which(fname);
if ~exist(fname,'file'), error('Could not find %s\n',fname); end

asset = load(fname);


%% Adjust the input slot in the recipe for the local user

[~,n,e] = fileparts(asset.thisR.get('input file'));
inFile = which([n,e]);
if isempty(inFile), error('Cannot find the PBRT input file %s\n',asset.thisR.inputFile); end
asset.thisR.set('input file',inFile);

end

    