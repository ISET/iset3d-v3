function thisR = piUpdateRecipe(thisR)
% Convert recipe from old structure to newer structure. The change(s) are:
%   1. Change material format: Extract texture from material slot and make it 
%      a separate slot.
%   2. Rearrange assets to new structure
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
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.parse(thisR);

%% 
txtLines = thisR.materials.txtLines;
thisR = piMaterialField2Cell(thisR);
% Material number mismatch observed from some of Zhenyi's recipe on
% FlyWheel between the materials in the list nad in txtLines.
thisR.materials.txtLines= piMaterialsFromText(txtLines); 

% Gather texture lines and assign texture info.
textureLines = piTexturesFromText(txtLines);
texturelist  = piBlockExtractTexture(thisR, textureLines);
thisR.textures.list = texturelist;
thisR.textures.txtLines = textureLines;
thisR.textures.inputFile_textures = thisR.materials.inputFile_materials;

%% Update assets
if isprop(thisR, 'assets') && ~isfield(thisR.assets, 'groupobjs')
    thisR = piAssetsRebuild(thisR);
end


end