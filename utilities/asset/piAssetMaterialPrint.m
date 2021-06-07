function T = piAssetMaterialPrint(thisR)
% List each asset and its materials type of the ISET3d recipe
%
% Syntax:
%   piAssetMaterialPrint(thisR)
%
% Brief description
%   Prints out a table of the assets and its corresponding material 
%
% Inputs:
%   thisR:   An ISET3d recipe. 
%
% Outputs:
%   T -   The table of indices, object names, and material name
%
% Zhenyi, 2021
%
% See also:
%   recipe.show(), piMaterialPrint, piLightPrint
%

% Examples:
%{
 thisR = piRecipeDefault('scene name','simple scene');
 T = piAssetMaterialPrint(thisR);
%}

%% Only the objects, not all the nodes, are printed

fprintf('\n');
ids = thisR.get('objects');
for ii=1:numel(ids)
    rows{ii, :} = sprintf('%d',ii); %#ok<*AGROW>
    names{ii,:} = thisR.assets.Node{ids(ii)}.name;
    materialName{ii,:} = thisR.assets.Node{ids(ii)}.material.namedmaterial;
end

T = table(categorical(names), categorical(materialName),'VariableNames',{'assetName','materialName'}, 'RowNames',rows);
disp(T);
fprintf('-------------------------------\n');

end