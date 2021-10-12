function thisR = piAssetRemoveLastTrans(thisR, assetName, varargin)
%
% Inputs:
%   thisR     - recipe
%   assetName - node info
%
% Outputs:
%   thisR     - modified recipe
%   
% Description:
%   Remove the last transformation action (but keep at least 3, T, R, S 
%   one for each).
% 
%%
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetName', @(x)(ischar(x) || isscalar(x)));
p.parse(thisR, assetName, varargin{:});

%% If assetInfo is a name, find the id
if ischar(assetName)
    assetName = piAssetFind(thisR.assets, 'name', assetName);
    if isempty(assetName)
        warning('Could not find an asset with name %s:', assetName);
        return;
    end
end

%%
thisNode = thisR.assets.get(assetName);
if isempty(thisNode)
    warning('Could not find an asset with name %d:', assetInfo);
    return;
end

%%
% Check if the number of transformations is larger than 3, if not, return
if numel(thisNode.transorder) <= 3
    disp(fprintf('Ignoring the request: a node should have at least a translation, rotation and scale\n'))
else
    switch thisNode.transorder(end)
        case 'T'
            thisNode.translation(end) = []; 
        case 'R'
            thisNode.rotation(end) = []; 
        case 'S'
            thisNode.scale(end) = []; 
    end
    thisNode.transorder = thisNode.transorder(1:end-1);
end
thisR.set('assets', assetName, thisNode);
end