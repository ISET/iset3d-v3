function thisR = piAssetRotate(thisR, assetInfo, rotation, varargin)
%%
%
% Synopsis:
%   thisR = piAssetRotate(thisR, assetInfo, rotation, varargin)
%
% Brief description:
%   Rotate an asset. Function reweitten by Zheng Lyu.
% 
% Inputs:
%   thisR       - recipe.
%   assetInfo   - asset node name or id.
%   rotation    - rotation vector 
% 
% Returns:
%   thisR       - modified recipe.
%
% Description:
%   Rotate an asset. If the asset is a branch node, move it.
%   If the asset is an object or light, insert a branch node representing
%   rotation between the node and its parent.
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

thisR = thisR.set('asset', 'Sky1', 'rotation', [45, 0, 0]);
disp(thisR.assets.tostring)
%}
%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('rotation', @isvector);
p.parse(thisR, assetInfo, rotation, varargin{:});

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

% Form rotation matrix
rotMatrix = [rotation(3), rotation(2), rotation(1);
             fliplr(eye(3))];

if isequal(thisNode.type, 'branch')
    % If the node is branch
    curRot = thisR.get('asset', assetInfo, 'rotation');
    curRot = curRot + rotMatrix;
    thisR = thisR.set('asset', assetInfo, 'rotation', curRot);
else
    % Node is object or light
    newBranch = piAssetCreate('type', 'branch');
    newBranch.rotation = rotMatrix;
    newBranch.name = strcat('new_rotation', '_', thisNode.name);
    thisR = thisR.set('asset', assetInfo, 'insert', newBranch);
end

end