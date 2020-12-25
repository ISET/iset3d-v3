function list = piMaterialList(thisR)
% List materials type in this PBRT scene
%
% Syntax:
%   list = piMaterialList(thisR)
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

%% Whole library

if notDefined('thisR')
    fprintf('The material library\n-------------------\n');
    mlib = piMateriallib;
    disp(mlib);
    return;
end

%% Just the materials of this scene

nMaterials = thisR.get('n material');

[~,sceneName] = fileparts(thisR.inputFile);
fprintf('\nScene materials: %s\n',sceneName);
fprintf('-------------------------------\n');

fprintf('  Name  \t [Type]\n');
fprintf('-------------------------------\n');

for ii =1:nMaterials
    fprintf('%d: %s: \t [ %s ]\n', ii, ...
        thisR.materials.list{ii}.name, ...
        thisR.materials.list{ii}.type);
end

fprintf('-------------------------------\n');

end