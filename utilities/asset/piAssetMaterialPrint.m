function piAssetMaterialPrint(thisR)
% List materials type in this PBRT scene
%
% Syntax:
%   piAssetMaterialPrint(thisR)
%
% Brief description
%   Prints out a list of the corresponding materials used by each asset. 
%
%
% Inputs:
%   thisR:   A recipe.  If missing, the whole library is printed
%
% Outputs:
%   N/A
%
% Zhenyi, 2021
%
% See also:
%   
%

% Examples:
%{
% Print the material types
 piAssetMaterialPrint(thisR)
%}

%% 

fprintf('\Assets materials\n');
fprintf('-------------------------------\n');
nn = 1;
for ii =2:numel(thisR.assets.Node)
    if strcmp(thisR.assets.Node{ii}.type,'object')
        rows{nn, :} = num2str(nn);
        names{nn,:} = thisR.assets.Node{ii}.name;
        materialName{nn,:} = thisR.assets.Node{ii}.material.namedmaterial;
        nn = nn+1;
    end
end
T = table(categorical(names), categorical(materialName),'VariableNames',{'assetName','materialName'}, 'RowNames',rows);
disp(T);
fprintf('-------------------------------\n');

end