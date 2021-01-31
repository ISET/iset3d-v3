function thisR = piAssetSet(thisR, assetInfo, param, val, varargin)
%%
%
% Synopsis:
%   thisR = piAssetSet(thisR, assetInfo, param, val, varargin);
%
% Brief description:
%   Set the value of a parameter of a node, or replace a node.
%
% Inputs:
%   thisR     - recipe.
%   assetInfo - information of asset. Either an id or a name.
%   param     - parameter name to be changed
%   val       - new parameter value
%
% Returns:
%   thisR     - modified recipe.
%
%

% Examples:
%{
thisR = piRecipeDefault;
thisName = '013ID_colorChecker_material_Patch09Material';
newName = 'newName';
thisR = thisR.set('asset', thisName, 'name', newName);
disp(thisR.assets.tostring)
nodeName = thisR.get('asset', newName, 'name');
thisNode = thisR.get('asset', newName);
%}

% TODO: Write a routine to enforce unique names

%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('param', @ischar);
p.parse(thisR, assetInfo, param, varargin{:});

param = ieParamFormat(param);
%%
% If assetInfo is a node name, find the id
if ischar(assetInfo)
    assetName = assetInfo;
    assetInfo = piAssetFind(thisR.assets, 'name', assetInfo);
    if isempty(assetInfo)
        warning('Couldn not find an asset with name %s:', assetName);
        return;
    end
end

thisNode = thisR.assets.get(assetInfo);

% If replace the node with a new one
if isequal(param, 'node')
    thisR.assets = thisR.assets.set(assetInfo, val);
    return;
end

switch thisNode.type
    case 'object'
        switch param
            case {'name'}
                thisNode.name = val;
            case {'mediuminterface'}
                thisNode.mediumInterface = val;
            case {'material'}
                thisNode.material = val;
            case {'materialname'}
                thisNode.material.namedmaterial = val;
            case {'shape'}
                thisNode.shape = val;
            case {'output'}
                thisNode.output = val;
            otherwise
                warning('Node %s does not have field: %s. Change nothing.', thisNode.name, param)
                return;
        end
    case 'light'
        switch param
            case {'name'}
                thisNode.name = val;
            case {'lght', 'light'}
                % If it is an area light, we only allow one light since
                % area light occupies physical space. Otherwise the light
                % is appended since they don't take physical space.
                if isequal(val.type, 'area')
                    thisNode.lght{1} = val;
                else
                    thisNode.lght{end+1} = val;
                end
            otherwise
                warning('Node %s does not have field: %s. Change nothing.', thisNode.name, param)
                return;
        end
    case 'branch'
        switch param
            case {'name'}
                thisNode.name = val;
            case {'size'}
                thisNode.size = val;
            case {'scale'}
                thisNode.scale = val;
            case {'translation', 'translate'}
                thisNode.translation = val;
            case {'rotation', 'rotate'}
                thisNode.rotation = val;
            case {'motion'}
                thisNode.motion = val;
            otherwise
                warning('Node %s does not have field: %s. Change nothing.', thisNode.name, param)
                return;
        end
end

thisR.assets = thisR.assets.set(assetInfo, thisNode);
end
