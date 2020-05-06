function thisR = piUpdateRecipe(thisR)
% Convert recipe from old structure to newer structure. The change(s) are:
%   1. Change material format: Extract texture from material slot and make it 
%      a separate slot.
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
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.parse(thisR);

%% 
txtLines     = thisR.materials.txtLines;
materiallist = piBlockExtractMaterial(txtLines);
thisR.materials.list = materiallist;

% Gather texture lines and assign texture info.
textureLines = piTexturesFromMaterialFileText(txtLines);
texturelist  = piBlockExtractTexture(thisR, textureLines);
thisR.textures.list = texturelist;
thisR.textures.txtLines = textureLines;
thisR.textures.inputFile_textures = thisR.materials.inputFile_materials;

end