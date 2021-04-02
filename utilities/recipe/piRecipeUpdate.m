function thisRV2 = piRecipeUpdate(thisRV2)
% Convert recipe from V1 structure to V2 structure. 
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
thisRV2.lights = piLightGetFromText(thisRV2.world);
end

function thisRV2 = piRecipeUpdateAssets(thisRV2)
% Update the asset format


% Each asset will become a node.
nAssets = numel(thisRV2.assets);
assets.Node   = cell(nAssets,1);
assets.Parent = cell(nAssets,1);

if isfield(thisRV2.assets(1)


for ii=1:nAssets
   thisAsset = thisRV2.assets(ii);
   
   % Figure out which type of asset
   % Create a node of that type and assign it to assets.Node{ii} using
   % piAssetCreate.
   % Copy the parameters in the V1 recipe to proper slots in the version 2
   % recipe
   % Figure the parent and copy that node number
   
   % Rules:
   %   If children is empty and material does not exist, it is a marker
   %                        and material exists,         it is an object
   %
   %   If children is not empty it is a branch. Version 1 has not slot for
   %   lights.
   %      
   [assets.Node{ii}, assets.Parent{ii}] = parse(thisAsset);
end


% Each node will have a parent

% Convert each node's format to the V2 format given its V1 format


%{
if isprop(thisR, 'assets') && ~isfield(thisR.assets, 'groupobjs')
    thisRV2 = piAssetsRebuild(thisRV1);
end
%}

end
    
function thisRV2 = piRecipeUpdateMaterials(thisRV2)
% Update the materials AND textures

%% In version 1 everything was in the materials text
txtLines = thisRV2.materials.txtLines;

% We parse the text into the format needed for the materials and textures,
% separately, in Version 2
[thisRV2.materials.list, thisRV2.textures.list] = parseMaterialTexture(txtLines); 

end
