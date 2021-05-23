function thisR = piObjectInstance(thisR, assetname, varargin)
%% Create object instance
%
% Synopsis:
%   thisR = piCreateObjectInstance(thisR, assetname, position, rotation, motion)
%
% Brief description:
%   Create object instance using a different position/rotation/motion.
%   If a complex object is used repeatedly in a scene, object instancing
%   may be desirable; this lets the system store a single instance of the
%   object in memory and just record multiple transformations to place it
%   in the scene.
%
% Inputs:
%   thisR     - scene recipe
%   assetname - assetname, only branch is supported
%
% Output:
%   thisR     - scene recipe
%
%
% Zhenyi, 2021
%%
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addParameter('position',[]);
p.addParameter('rotation',[]);
p.addParameter('motion',[],@(x)isstruct);

p.parse(thisR, varargin{:});

thisR    = p.Results.thisR;
position = p.Results.position;
rotation = p.Results.rotation;
motion   = p.Results.motion;

%%
[idx,asset] = piAssetFind(thisR, 'name', assetname);
if ~strcmp(asset{1}.type, 'branch')
    warning('Only branch name is supported.');
    return;
end
OBJsubtree = thisR.get('asset', idx, 'subtree','false');

OBJsubtree_branch = OBJsubtree.get(1);
if ~isempty(position)
    OBJsubtree_branch.translation = position;
end
if ~isempty(rotation)
    OBJsubtree_branch.rotation    = rotation;
end
if ~isempty(motion) 
    OBJsubtree_branch.motion.position = motion.position;
    OBJsubtree_branch.motion.rotation = motion.rotation;
end
% add _I suffix to indicate instance type
OBJsubtree_branch.name = strcat(OBJsubtree_branch.name, '_I');
% replace branch
OBJsubtree = OBJsubtree.set(1, OBJsubtree_branch);
% graft object tree to scene tree
thisR.assets = thisR.assets.graft(1, OBJsubtree);
thisR.assets = thisR.assets.uniqueNames;
end