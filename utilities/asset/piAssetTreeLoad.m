function [assetTree, matList] = piAssetTreeLoad(assetTreeFile, varargin)
% Load an asset subtree and materials to insert in a recipe
%
% Synopsis:
%   [assetTree, matList] = piAsseTreetLoad(assetName, varargin)
%
% Description
%
% Inputs:
%   filePath    - path to the asset file.  Must be a mat-file.
%
% Key/val pairs
%   N/A
%
% Returns:
%   assetTree   - Asset subtree nodes (both object and branch nodes)
%   matList     - List of materials used by the objects in the asset tree,
%                 stored as a container.Map
%
% See also
%   piAssetTreeSave, recipeSet(... 'graft with materials' ...)

% Examples:
%{
  [assetTree, matList] = piAssetTreeLoad('bunny');
%}
%{
  [assetTree, matList] = piAssetTreeLoad('/Users/wandell/Documents/MATLAB/iset3d/local/coordinate');
%}

%% Parse input
p = inputParser;

% The file must exist
p.addRequired('assetTreeFile', @(x)(exist(x,'file')));

p.parse(assetTreeFile, varargin{:})

%% The input file must be a mat-file

filePath = which([assetTreeFile, '.mat']);

if ~isempty(filePath)
    load(filePath, 'assetTree', 'matList');
else
    warning('Could not find asset file: %s', assetTreeFile)
    assetTree = [];
    matList = {};
end

end