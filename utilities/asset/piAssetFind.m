function [id, thisAsset] = piAssetFind(assets, param, val)
% Find the id of an asset such that the parameter matches the val
%
% Synopsis:
%   [id, theAsset] = piAssetFind(assets, param, val)
%
% Inputs:
%   assets  - recipe
%   param   - parameter
%   val     - value to match
%
% Returns:
%   id       - id of the matching node
%   theAsset - the asset struct
%
% See also:
%   piAssetGet, piAssetSet;

% Examples:
%{
 thisR = piRecipeDefault;
 id = piAssetFind(thisR.assets, 'name', 'Camera');
 [id, theAsset]  = piAssetFind(thisR, 'name', '002ID_Camera');
 id = piAssetFind(thisR.assets, 'scale', [1 1 1]);
%}

%%  In the past, we allowed a recipe

% So now we check if it is a recipe and then we get the assets.
if isa(assets,'recipe')
    assets = assets.assets;
end
if ~isa(assets,'tree'), error('Assets must be a tree.'); end

% If the input is a node id (number), return the node
if isscalar(val)
    id = val;
    thisAsset = {assets.get(val)};
    return;
end
%%
nodeList = 0; % 0 is always the index for root node

curIdx = 1; %

id = [];
thisAsset = {};

while curIdx <= numel(nodeList)
    IDs = assets.getchildren(nodeList(curIdx));
    for ii = 1:numel(IDs)
        if isequal(param, 'name')
            % Users are allowed to look for node with the ID prepended or
            % just the base asset name.  That is why 'name' is a special
            % case. 
            if isequal(val, assets.stripID(IDs(ii))) || ...
                    isequal(val, assets.names(IDs(ii)))
                id = [id IDs(ii)];
                if nargout > 1, thisAsset{end + 1} = assets.get(IDs(ii)); end
                % return;
            end
        else
            % Another parameter must match.  Returns the first instance of
            % the match.  Maybe it should return all the instances?
            if IDs(ii) > 1
                thisAsset{end + 1} = assets.get(IDs(ii));
                if isequal(val, piAssetGet(thisAsset, param))
                    id = [id IDs(ii)];
                    % return;
                end
            end
        end
        nodeList = [nodeList IDs(ii)]; %#ok<AGROW>
    end
    
    curIdx = curIdx + 1;
end



end