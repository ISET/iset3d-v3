function thisR = piAssetObject2Light(thisR, assetInfo, lght, varargin)

%
% Synopsis
%   thisR = piAssetObject2Light(thisR, assetInfo, lght, varargin)
%
% Brief description:
%   Change an object node to area light.
%   
% Inputs:
%   thisR - recipe
%   index - index of the asset 
%   light - a light struct
%
% Returns:
%   thisR - modified recipe
%

% Example
%{
thisR = piRecipeDefault;
thisName = 'colorChecker_material_Patch13Material';

% Create a new area light
newLight = piLightCreate('type', 'area', 'lightspectrum', 'D65');

thisR = thisR.set('asset', thisName, 'obj2light', newLight);
thisNode = thisR.get('asset', thisName);
%}
%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('lght', @isstruct);
p.parse(thisR, assetInfo, lght, varargin{:});

%% If assetInfo is a node name, find the assetID
if ischar(assetInfo)
    assetID = piAssetFind(thisR.assets, 'name', assetInfo);
    if isempty(assetID)
        warning('Could not find an asset named %s:', assetInfo);
        return;
    end
end

%% Extract the information from object node
objectNode = thisR.assets.get(assetID);
objectName = objectNode.name;
shape = objectNode.shape;

%% Create a new node to replace the object node
lightNode = piAssetCreate('type', 'light');
lightNode.lght = {lght}; % Convert the light to cell
lightNode.name = objectName;
if isequal(lght.type, 'area')
    lightNode.lght{1} = piLightSet(lightNode.lght{1}, 'shape val', shape);
end

thisR.assets = thisR.assets.set(assetID, lightNode);
end