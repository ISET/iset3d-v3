function thisR = piAssetMotionAdd(thisR, assetInfo, varargin)
%%
%
%

% Example:
%{
thisR = piRecipeDefault('scene name', 'Simple Scene');
disp(thisR.assets.tostring)
[~, names] = thisR.assets.tostring;

% branch node
branchName = '006ID_Sun';
thisR = thisR.set('asset', branchName, 'motion', 'rotation', [0 0 45],...
                    'translation', [0.5 0 0]);
disp(thisR.assets.tostring)

% light node
objName = '010ID_Moon Light';
thisR = thisR.set('asset', objName, 'motion', 'rotation', [0 0 45],...
                    'translation', [0.5 0 0]);
disp(thisR.assets.tostring)

thisR = thisR.set('asset', objName, 'motion', 'rotation', [0 0 45],...
                    'translation', [0.5 0 0]);
disp(thisR.assets.tostring)
%}
%%
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addParameter('translation', [0 0 0], @isvector);
p.addParameter('rotation', [0 0 0], @isvector);
p.parse(thisR, assetInfo, varargin{:});

thisR = p.Results.thisR;
assetInfo = p.Results.assetInfo;
translation = p.Results.translation;
rotation = p.Results.rotation;

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

%%
thisNode = thisR.assets.get(assetInfo);

if isempty(thisNode)
    warning('Couldn not find an asset with name %d:', assetInfo);
    return;
end

rotMatrix = [rotation(3), rotation(2), rotation(1);
             fliplr(eye(3))];

%{
If it is branch node, insert a new node with motion as the new parent of
its all children.
             
If it is object node, insert a new node with motion as the new parent of
itself.
%}
             
% Form motion struct by only having the translation and rotation
motion.position = reshape(translation, 1, 3);
motion.rotate = rotMatrix;
% New branch node
newBranch = piAssetCreate('type', 'branch');
newBranch.name = strcat(thisR.assets.stripID(assetInfo), '_', 'move');
newBranch.motion = motion;
if isequal(thisNode.type, 'branch')
    % If the node is branch
    % Get the children id of thisNode
    childID = thisR.assets.getchildren(assetInfo);
    
    % Add the new node as child of thisNode
    thisR = thisR.set('asset', thisNode.name, 'add', newBranch);
    
    % Set the parent of children of thisNode be the newBranch
    for ii=1:numel(childID)
        thisR.set('asset', childID(ii), 'parent',...
                thisR.get('asset', thisR.assets.nnodes, 'name'));
    end

else
    % Node is object or light
    % Insert the newBranch node under its parent
    thisR = thisR.set('asset', assetInfo, 'insert', newBranch);
end
end