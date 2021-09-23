function modifiedBranch = piAssetTranslate(thisR, assetInfo, translation,varargin)
%% Translate an asset
%
% Synopsis:
%   newBranch = piAssetTranslate(thisR, assetInfo, translation, varargin)
%
% Description:
%   Translate an asset.
%
%   If the asset is a branch node, translate it.
%
%   If the asset is an object or light, insert a branch node representing 
%   translation between the node and its parent.
%
% Inputs:
%   thisR       - recipe
%   assetInfo   - asset node name or id
%   translation - translation vector
%
% Outputs:
%   newBranch   - the newly inserted branch
%
% See also
%   piAsset*
%

% History:
%   ZL, Vistasoft Team, 2018
%   ZLY, Vistasoft Team, 2020
%
%   01/05/21  dhb  Put comments closer to ISETBio standard form.
%                  Little bit of commenting
%                  Fix example so it runs


% Examples:
%{
% The asset name syntax:
%
% A branch node that contains the transforms will have a name like
this:
%
%   XXXXID_nodeName_B
%
% Four digits followed by ID.  The four digits are the node number.
% Then there is a name that typically would describe the object it is
% transforming.  Then a _B to indicate this is a branch node, not a
% leaf.
% 
% Object nodes are a little different.
%
%   XXXXID_YYY_nodeName_O
%
% The same ID numbering.  But there is an extra three-digit number (YYY) 
% that says which part this is within the node name.  So the top might
% be car, and the car might have 001_car, 002_car, ... and so forth.
% 

thisR = piRecipeDefault('scene name', 'Simple scene');
% thisR.show;
scene = piWRS(thisR);
assetName = '0014ID_figure_3m_B';  % This node name has an _ in it, sigh.
curTrans = thisR.get('asset', assetName, 'translation')
thisR.set('asset', assetName, 'translate', [0.5, 0.5, 0.5]);
newTrans = thisR.get('asset', assetName, 'translation')
% thisR.show;
scene = piWRS(thisR);
scene = sceneSet(scene,'render flag','hdr');
ieReplaceObject(scene);
sceneWindow;
%}


%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('translation', @isvector);
p.parse(thisR, assetInfo, translation, varargin{:})

%% If assetInfo is a node name, find the id
if ischar(assetInfo)
    assetName = assetInfo;
    assetInfo = piAssetFind(thisR.assets, 'name', assetInfo);
    if isempty(assetInfo)
        warning('Could not find an asset named: %s', assetName);
        return;
    end
end

%% Get asset node
thisNode = thisR.assets.get(assetInfo);
if isempty(thisNode)
    warning('Couldn not find an asset named: %d', assetInfo);
    return;
end

%% Add translation to the target node
if isequal(thisNode.type, 'branch')
    % If the node is branch(transformation) node, add the translation to
    % itself.
    thisNode.translation{end+1} = reshape(translation, size(thisNode.translation{1}));
    thisNode.transorder(end+1) = 'T';
    [~, modifiedBranch] = thisR.set('asset', assetInfo, thisNode);
else
    % Node is object or light
    parentNodeID = thisR.assets.getparent(assetInfo);
    modifiedBranch = piAssetTranslate(thisR, parentNodeID, translation);
end
    
%% Commenting out the old code, deprecated in the future
%{
%% Put translation onto a new branch node
newBranch = piAssetCreate('type', 'branch');
newBranch.name = strcat(thisR.assets.stripID(assetInfo), '_', 'T');
newBranch.translation = reshape(translation, 1, 3);

if isequal(thisNode.type, 'branch')
    % If the node is branch
    % Get the children id of thisNode
    childID = thisR.assets.getchildren(assetInfo);
    
    % Add the new node as child of thisNode
    thisR.set('asset', thisNode.name, 'add', newBranch);
    
    % Set the parent of children of thisNode be the newBranch
    for ii=1:numel(childID)
        thisR.set('asset', childID(ii), 'parent',...
                thisR.get('asset', thisR.assets.nnodes, 'name'));
    end
else
    % Node is object or light
    % Insert the newBranch node under its parent
    thisR.set('asset', assetInfo, 'insert', newBranch);
end
%}

end
