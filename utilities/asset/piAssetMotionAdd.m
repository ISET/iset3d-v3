function thisR = piAssetMotionAdd(thisR, assetInfo, varargin)
%%
%
%

% Example:
%{
thisR = piRecipeDefault;
disp(thisR.assets.tostring)

nodeName = 'colorChecker_material_Patch13Material';
thisR = thisR.set('asset', nodeName, 'motion', 'rotation', [0 0 45],...
                    'translation', [0.5 0 0]);
disp(thisR.assets.tostring)
piWrite(thisR);
[scene, result] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
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
    assetInfo = piAssetFind(thisR, 'name', assetInfo);
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

if isequal(thisNode.type, 'branch')
    % If the node is branch
    % Get current position and rotation
    curPos = thisR.get('asset', assetInfo, 'position');
    curRot = thisR.get('asset', assetInfo, 'rotation');
    % Form motion struct by adding together
    motion.position = curPos + reshape(translation, 1, 3);
    motion.rotate = curRot + rotMatrix;
    thisR = thisR.set('asset', assetInfo, 'motion', motion);
else
    % Node is object or light
    % Form motion struct by only having the translation and rotation
    motion.position = reshape(translation, 1, 3);
    motion.rotate = rotMatrix;
    
    newBranch = piAssetCreate('type', 'branch');
    newBranch.name = strcat('new_motion', '_', thisNode.name);
    newBranch.motion = motion;
    thisR = thisR.set('asset', assetInfo, 'insert', newBranch);
end
end