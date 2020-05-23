function piMaterialList(thisR)
% List materials type in this PBRT scene
%
% Syntax:
%   piMaterialList(thisR)
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
%
% See also:
%   piMaterial*
%   piMateriallib - Lists all the possible materials in our library
%

% Examples:
%{
% List the material types
 mTypes = piMateriallib;
 disp(mTypes)
%}
%%

if notDefined('thisR')
    fprintf('The material library\n-------------------\n');
    mlib = piMateriallib;
    disp(mlib);
    return;
end


%% The user sent in a recipe.  So print the materials in this scene

nMaterials = numel(thisR.materials.list);

[~,sceneName] = fileparts(thisR.inputFile);
fprintf('\nMaterials in the scene %s\n',sceneName);
fprintf('-------------------------------\n');

fprintf('  Name  \t [Type]\n');
fprintf('-------------------------------\n');

list = cell(1,nMaterials);

for ii =1:nMaterials
    list{ii} = sprintf('%d: %s: \t [ %s ]\n', ii, ...
        thisR.materials.list{ii}.name, ...
        thisR.materials.list{ii}.stringtype);
end
for ii =1:nMaterials
    fprintf('%s',list{ii});
end

fprintf('-------------------------------\n');


end