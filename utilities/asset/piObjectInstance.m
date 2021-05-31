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
p.addParameter('nodetype','branch',@(x)(ismember(ieParamFormat(x),{'branch','object'})));
p.addParameter('position',[]);
p.addParameter('rotation',[]);
p.addParameter('motion',[],@(x)isstruct);

p.parse(thisR, varargin{:});

thisR    = p.Results.thisR;
nodeType = p.Results.nodetype;
position = p.Results.position;
rotation = p.Results.rotation;
motion   = p.Results.motion;

%%
[idx,asset] = piAssetFind(thisR, 'name', assetname);
% if ~strcmp(asset{1}.type, 'branch')
%     warning('Only branch name is supported.');
%     return;
% end
switch nodeType
    case 'branch'
        OBJsubtree = thisR.get('asset', idx, 'subtree','false');
        
        OBJsubtree_branch = OBJsubtree.get(1);
        if ~isfield(OBJsubtree_branch, 'instanceCount')
            OBJsubtree_branch.instanceCount = 0;
        end
        OBJsubtree_branch.instanceCount = OBJsubtree_branch.instanceCount+1;
        thisR.assets = thisR.assets.set(idx, OBJsubtree_branch);
        InstanceSuffix = sprintf('_I_%d',OBJsubtree_branch.instanceCount);
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
        for ii = 1:numel(OBJsubtree.Node) 
                thisNode      = OBJsubtree.Node{ii};
                thisNode.name = strcat(OBJsubtree.Node{ii}.name, InstanceSuffix);
            if strcmp(OBJsubtree.Node{ii}.type,'object')
                thisNode.type = 'instance';
                thisNode.referenceObject = OBJsubtree.Node{ii}.name;
            end
                OBJsubtree = OBJsubtree.set(ii, thisNode);
        end
        OBJsubtree_branch.name = strcat(OBJsubtree_branch.name, InstanceSuffix);
        % replace branch
        OBJsubtree = OBJsubtree.set(1, OBJsubtree_branch);
        % graft object tree to scene tree
        thisR.assets = thisR.assets.graft(1, OBJsubtree);
    case 'object'
        % to add
end
thisR.assets = thisR.assets.uniqueNames;
end