function piMaterialPrint(thisR)
% List materials type in this PBRT scene
%
% Syntax:
%   piMaterialPrint(thisR)
%
% Brief description
%   Prints out a list of the materials in this recipe (thisR).  The
%   materials are stored in the slot thisR.materials.list.  Each entry
%   in the list is a struct with a specific name that was assigned to
%   that specific material, and a string that describes its material
%   type.
%
%   At present our library contains 13 material types.
%
% Inputs:
%   thisR:   A recipe.  If missing, the whole library is printed
%
% Outputs:
%   N/A
%
% ZL, SCIEN Stanford, 2018
% Zhenyi, updated, 2021
%
% See also:
%   piMaterial*
%

% Examples:
%{
% Print the material types
 piMaterialPrint(thisR)
%}

%% Whole library

if notDefined('thisR')
    fprintf('The material library\n-------------------\n');
    mlib = piMateriallib;
    disp(mlib);
    return;
end

%% Just the materials of this scene

MatNames = thisR.get('material', 'names');

[~,sceneName] = fileparts(thisR.inputFile);
fprintf('\nScene materials: %s\n',sceneName);
fprintf('-------------------------------\n');
for ii =1:numel(MatNames)
    rows{ii, :} = num2str(ii);
    names{ii,:} = MatNames{ii};
    types{ii,:} = thisR.materials.list(MatNames{ii}).type;
end
T = table(categorical(names), categorical(types),'VariableNames',{'name','type'}, 'RowNames',rows);
disp(T);
fprintf('-------------------------------\n');

end