function newBranch = piAssetMotionAdd(thisR, assetInfo, varargin)
% Add a motion branch to the asset tree
%
% Synopsis
%    newBranch = piAssetMotionAdd(thisR, assetInfo, varargin)
%
% Description
%    Add a branch describing object/light motion.
%
% Inputs
%    thisR
%    assetInfo
%
% Optional Key/val
%    translation:   3-vector in units of meters
%    rotation:      3-vector in units of degrees
%
% Return
%    newBranch:    Branch inserted above object or below branch
%
% ZLy, BW
%
% See also
%    piAsset*

% Example:
%{
thisR = piRecipeDefault('scene name', 'Simple Scene');
thisR.assets.show;

% Add motion to the Sun_B node
branchName = 'Sun_B';
thisR.set('asset', branchName, 'motion', 'rotation', [0 0 45],...
                    'translation', [0.5 0 0]);
thisR.assets.show;

% Add to light node
objName = 'Moon Light_L';
thisR.set('asset', objName, 'motion', 'rotation', [0 0 45],...
                    'translation', [0.5 0 0]);
thisR.assets.show;

% Add a combination of translate/rotate
thisR.set('asset', objName, ...
            'motion', 'rotation', [0 0 45],...
            'translation', [0.5 0 0]);

thisR.assets.show;
%}

%% Parse
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addParameter('translation', [0 0 0], @isvector);
p.addParameter('rotation', [0 0 0], @isvector);
p.parse(thisR, assetInfo, varargin{:});

thisR       = p.Results.thisR;
assetInfo   = p.Results.assetInfo;
translation = p.Results.translation;
rotation    = p.Results.rotation;

%% If assetInfo is a node name, find the id

if ischar(assetInfo)
    assetName = assetInfo;
    assetInfo = piAssetFind(thisR.assets, 'name', assetInfo);
    if isempty(assetInfo)
        warning('Couldn not find an asset with name %s:', assetName);
        return;
    end
end

% It is an id now, so
thisNode = thisR.assets.get(assetInfo);

if isempty(thisNode)
    warning('Could not find an asset with id %d:', assetInfo);
    return;
end

%%  Set the rotation and translation terms 

% Form motion struct by only having the translation and rotation
rotMatrix = [rotation(3), rotation(2), rotation(1);
             fliplr(eye(3))];
motion.rotation = rotMatrix;
motion.translation = reshape(translation, 1, 3);

%% New branch node

newBranch = piAssetCreate('type', 'branch');
newBranch.name = strcat(thisR.assets.stripID(assetInfo), '_', 'move');
newBranch.motion = motion;

% If thisNode is a branch, insert a motion node below and make a new parent
% of all its children. 
if isequal(thisNode.type, 'branch')
    % The node is branch. Get the children id of thisNode
    childID = thisR.assets.getchildren(assetInfo);
    
    % Add the new branch node as child of thisNode
    thisR.set('asset', thisNode.name, 'add', newBranch);
    
    % Assign all the children to have the newBranch as their parent.
    for ii=1:numel(childID)
        thisR.set('asset', childID(ii), 'parent',...
                thisR.get('asset', thisR.assets.nnodes, 'name'));
    end

else
    % Node is object or light. Insert the newBranch node under its parent
    thisR.set('asset', assetInfo, 'insert', newBranch);
end

end