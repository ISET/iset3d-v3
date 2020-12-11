function val = piAssetGet(thisR, assetInfo, param, varargin)
%%
%
% Synopsis:
%   val = piAssetGet(thisR, assetInfo, param)
%
% Brief description:
%   Get the value of a node parameter in the asset tree or the node 
%   itself.
%
% Inputs:
%   thisR     - recipe
%   assetInfo - information of asset. Either an id or a name.
%
% Optional:
%   param     - the parameter to look for, or empty to return the node.
%
% Returns:
%   val       - the parameter value or the node (if param is empty or
%               omitted).
%

% Examples:
%{
thisR = piRecipeDefault;
disp(thisR.assets.tostring)
thisName = 'colorChecker_material_Patch13Material';
node = thisR.get('asset', thisName);
shape = thisR.get('asset', thisName, 'shape');
scale = thisR.get('asset', 'colorChecker', 'scale');
%}
%%
if notDefined('param'), param = ''; end

%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('param', @ischar);
p.parse(thisR, assetInfo, param, varargin{:});
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

thisTree = thisR.assets;
thisNode = thisTree.get(assetInfo);

if isempty(param)
    val = thisNode;
else
    if isequal(param, 'parent')
        parent = thisTree.getparent(assetInfo);
        if isempty(parent)
            val = [];
        else
            val = piAssetGet(thisR, parent);
        end
        return;
        
    elseif isequal(param, 'children')
        childrenList = thisTree.getchildren(assetInfo);
        
        if isempty(childrenList)
            val = [];
        elseif numel(childrenList) == 1
            val = piAssetGet(thisR, childrenList);
        else
            val = cell(1, numel(childrenList));
            for ii=1:numel(childrenList)
                val{ii} = piAssetGet(thisR, childrenList(ii));
            end
        end
        return;
    elseif isequal(thisNode, 'root')
        val = [];
        return;
    end
    
    switch thisNode.type
        case 'object'
            switch param
                case {'name'}
                    val = thisNode.name;
                case {'mediumInterface'}
                    val = thisNode.mediumInterface;
                case {'material'}
                    val = thisNode.material;
                case {'shape'}
                    val = thisNode.shape;
                case {'output'}
                    val = thisNode.output;
                case {'position'}
                    val = piAssetGet(thisR, thisR.assets.getparent(assetInfo), param);
                otherwise
                    warning('Node %s does not have field: %s. Empty return', thisNode.name, param)
                    return;
            end
        case 'light'
            switch param
                case {'name'}
                    val = thisNode.name;
                case {'lght'}
                    val = thisNode.lght;
                case {'position'}
                    val = piAssetGet(thisR, thisR.assets.getparent(assetInfo), param);
                otherwise
                    warning('Node %s does not have field: %s. Empty return', thisNode.name, param)
                    return;
            end
        case 'branch'
            switch param
                case {'name'}
                    val = thisNode.name;
                case {'size'}
                    val = thisNode.size;
                case {'scale'}
                    val = thisNode.scale;
                case {'position'}
                    val = thisNode.position;
                case {'rotate'}
                    val = thisNode.rotate;
                case {'motion'}
                    val = thisNode.motion;
                otherwise
                    warning('Node %s does not have field: %s. Empty return', thisNode.name, param)
                    return;
            end
    end
    
end
end