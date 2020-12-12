function thisR = piAssetTranslate(thisR, assetInfo, translation,varargin)
%%
%
% Synopsis:
%   thisR = piAssetTranslate(thisR, assetInfo, translation, varargin)
%
% Brief description:
%   Translate the position of an asset. Function rewritten by Zheng Lyu.
%
% Inputs:
%   thisR       - recipe
%   assetInfo   - asset node name or id
%   translation - translation vector
%
% Return
%   thisR       - the modified recipe
%
% Description
%   Translate an asset. If the asset is a branch node, move it.
%   If the asset is an object or light, insert a branch node representing 
%   translation between the node and its parent.
%
% ZL, Vistasoft Team, 2018
% ZLY, Vistasoft Team, 2020
%
% See also
%   piAsset*
%

% Example:
%{
thisR = piRecipeDefault('scene name', 'Simple scene');
disp(thisR.assets.tostring)

thisR = thisR.set('asset', 'Sky1', 'translate', [1, 1, 1]);
disp(thisR.assets.tostring)
%}
%% Parse input

p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('translation', @isvector);
p.addParameter('instancesnum',1);
p.parse(thisR, assetInfo, translation, varargin{:})

%%
% If assetInfo is a node name, find the id
if ischar(assetInfo)
    assetName = assetInfo;
    assetInfo = piAssetFind(thisR, 'name', assetInfo);
    if isempty(assetInfo)
        warning('Couldn not find an asset with name %s:', assetName);
        return;
    end
end

%%
thisNode = thisR.assets.get(assetInfo);

if isempty(thisNode)
    warning('Couldn not find an asset with name %d:', assetInfo);
    return;
end

if isequal(thisNode.type, 'branch')
    % If the node is branch
    curPos = thisR.get('asset', assetInfo, 'position');
    curPos = curPos + reshape(translation, 1, 3);
    thisR = thisR.set('asset', assetInfo, 'position', curPos);
else
    % Node is object or light
    newBranch = piAssetCreate('type', 'branch');
    newBranch.position = reshape(translation, 1, 3);
    newBranch.name = strcat('new_translation', '_', thisNode.name);
    thisR = thisR.set('asset', assetInfo, 'insert', newBranch);
end

end
