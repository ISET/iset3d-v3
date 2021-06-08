function [id, thisAsset] = piAssetFind(assets, param, val)
% Find the id of an asset such that the parameter matches the val
%
% Synopsis:
%   [id, theAsset] = piAssetFind(assets, param, val)
%
% Inputs:
%   assets  - An ISET3d recipe or the assets from a recipe (a tree object)
%   param   - parameter  (e.g., name)
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
 % thisR = piRecipeDefault;
 thisR = piRecipeDefault('scene name','simple scene');
 thisR.show('objects materials');
 thisR.show('node names');

 id = piAssetFind(thisR.assets, 'name', 'root');
 [id, theAsset]  = piAssetFind(thisR, 'name', 'Camera_B');
 [id, theAsset]  = piAssetFind(thisR, 'id', 13); theAsset{1}
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

shortNameLists = assets.stripID;
assetNames     = assets.names;
while curIdx <= numel(nodeList)
    IDs = assets.getchildren(nodeList(curIdx));
    for ii = 1:numel(IDs)
        if isequal(param, 'name')
            % Users are allowed to look for node with the ID prepended or
            % just the base asset name.  That is why 'name' is a special
            % case.
            shortName = shortNameLists{IDs(ii)};
            if isequal(val, shortName )|| ...
                    isequal(val, assetNames{IDs(ii)})
                id = [id IDs(ii)];
                if nargout > 1, thisAsset{end + 1} = assets.get(IDs(ii)); end %#ok<*AGROW>
                if strcmp(val, 'root')
                    % for some scene, there are a large number of assets,
                    % so we do not want to loop all the assets if we are
                    % looking for the 'root'.
                 return;
                end
            end
        else
            % A parameter other than 'name' must match.  Returns all the
            % instances that match.
            if IDs(ii) > 1
                thisAsset{end + 1} = assets.get(IDs(ii));
                if isequal(val, piAssetGet(thisAsset{end}, param))
                    id = [id IDs(ii)];
                end
            end
        end
        nodeList = [nodeList IDs(ii)]; 
    end
    
    curIdx = curIdx + 1;
end

end