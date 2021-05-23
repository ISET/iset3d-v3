function thisRV2 = piRecipeUpdate(thisRV2)
% Convert a render recipe from V1 structure to V2 structure. 
%
% Synopsis
%   thisRV2 = piRecipeUpdate(thisRV2)
%
% The change(s) are:
%
%   1. Change material format: Extract texture from material slot and make it 
%      a separate slot.
%   2. Rearrange assets to new structure
%
% Syntax:
%
% Description:
%   
% Inputs:
%   thisR - recipe
%
% Outputs:
%   thisR - modified recipe
%
%
% Zheng Lyu, 2020

%% Parse input

p = inputParser;

p.addRequired('thisRV2', @(x)isequal(class(x),'recipe'));
p.parse(thisRV2);

%% Lights

thisRV2 = piRecipeUpdateLights(thisRV2);

%%  Materials

thisRV2 = piRecipeUpdateMaterials(thisRV2);

%% Assets

thisRV2 = piRecipeUpdateAssets(thisRV2);

end

function thisRV2 = piRecipeUpdateLights(thisRV2)
thisRV2.lights = piLightGetFromText(thisRV2.world, 'print info', false);
end

function thisRV2 = piRecipeUpdateAssets(thisRV2)
% Update the asset format

% Each asset will become a node, these are the nodes at first level.
nAssets = numel(thisRV2.assets);
% Initialize the tree.
assetsTree = tree('root');

for ii=1:nAssets
   thisAsset = thisRV2.assets(ii);
   
   % The V1 assets are a cell array and each entry can have multiple
   % children. But children do not have children. We attach the first level
   % to the root, and the children to the entry in the first level. 
   
   % For every asset we figure out its node type  
   thisNode = parseV1Assets(thisAsset);
   [assetsTree, id] = assetsTree.addnode(1, thisNode);
   % Check the children
   if isfield(thisAsset, 'children') && ~isempty(thisAsset.children)
       for jj=1:numel(thisAsset.children)
           childNode = parseV1Assets(thisAsset.children(jj));
           % Add object index: index_objectname_O
           childNode.name = sprintf('%03d_%s',jj,childNode.name);
           assetsTree = assetsTree.addnode(id, childNode);
       end
   end
end
% Make the name unique
thisRV2.assets = assetsTree.uniqueNames;
end

function node = parseV1Assets(thisAsset)
    % Rules:
    %   If children is empty and material does not exist, it is a marker
    %                        and material exists,         it is an object
    %
    %   If children is not empty it is a branch. Version 1 has no slot for
    %   lights.
    %      
    
    if isfield(thisAsset, 'material') && ~isfield(thisAsset, 'children')
        % An object
        node = piAssetCreate('type', 'object');
        node.name = strcat(thisAsset.name, '_O');
        node.material = piParseGeometryMaterial(thisAsset.material);
        node.index = thisAsset.index; % Not clear
        node.shape.filename = thisAsset.output;
    elseif isfield(thisAsset, 'children') && isempty(thisAsset.children)
        % A marker
        node = piAssetCreate('type', 'marker');
        node.size = thisAsset.size;
        node.size.pmin = node.size.pmin(:)';
        node.size.pmax = node.size.pmax(:)';
        node.name = strcat(thisAsset.name, '_M');
        node.translation = thisAsset.position(:)';
        node.rotation = thisAsset.rotate;
        if isfield(thisAsset, 'motion')
            node.motion = thisAsset.motion;
        end
    else
        % A branch node
        node = piAssetCreate('type', 'branch');
        node.size = thisAsset.size;
        node.size.pmin = node.size.pmin(:)';
        node.size.pmax = node.size.pmax(:)';
        node.name = strcat(thisAsset.name, '_B');
        node.translation = thisAsset.position(:)';
        node.rotation = thisAsset.rotate;
        if isfield(thisAsset, 'motion')
            node.motion = thisAsset.motion;
        end
    end
end
    
function thisRV2 = piRecipeUpdateMaterials(thisRV2)
% Update the materials AND textures

%% In version 1 everything was in the materials text
txtLines = thisRV2.materials.txtLines;

% We parse the text into the format needed for the materials and textures,
% separately, in Version 2
[thisRV2.materials.list, thisRV2.textures.list] = parseMaterialTexture(txtLines); 

end
