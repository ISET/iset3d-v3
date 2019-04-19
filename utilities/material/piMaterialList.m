function piMaterialList(thisR)
% List materials type in this PBRT scene
%
% Syntax:
%   piMaterialList(thisR)
%
% Description:
%    Prints out a list of the materials in this recipe (thisR). The
%    materials are stored in the slot thisR.materials.list. Each entry in
%    the list is a struct with a specific name that was assigned to that
%    specific material, and a string that describes its material type.
%
%    At present our library contains 13 material types.
%
% Inputs:
%    thisR - Object. A PBRT scene recipe object. If missing, the whole
%            library is printed.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%
% See Also:
%   piMaterial*
%   piMateriallib - Lists all the possible materials in our library
%

% History:
%    XX/XX/18  ZL   SCIEN Stanford, 2018
%    04/03/19  JNM  Documentation pass
%    04/18/19  JNM  Merge Master in (resolve conflicts)

% Examples:
%{
    % List the material types
    mTypes = piMateriallib;
    disp(mTypes)
%}

%% Check if thisR has not been defined, and if so, return the whole library
if notDefined('thisR')
    fprintf('The material library\n-------------------\n');
    mlib = piMateriallib;
    disp(mlib);
    return;
end

%% The user sent in a recipe.  So print the materials in this scene
fields = fieldnames(thisR.materials.list);
nMaterials = length(fieldnames(thisR.materials.list));

[~,sceneName] = fileparts(thisR.inputFile);
fprintf('\nMaterials in the scene %s\n', sceneName);
fprintf('-------------------------------\n');

fprintf('  Name  \t [Type]\n');
fprintf('-------------------------------\n');
list = cell(1, nMaterials);

for ii = 1:nMaterials
    list{ii} = sprintf('%d: %s: \t [ %s ]\n', ii, ...
        thisR.materials.list.(cell2mat(fields(ii))).name, ...
        thisR.materials.list.(cell2mat(fields(ii))).string);
end

for ii = 1:nMaterials
    fprintf('%s', list{ii});
end

fprintf('-------------------------------\n');

end
