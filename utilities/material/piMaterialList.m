function piMaterialList(thisR)
% List materials type in this PBRT scene
%
% Syntax:
%   piMaterialList(thisR)
%
% Description:
%    List the materials type in the provided PBRT scene.
%
% Inputs:
%    thisR - Object. A PBRT scene object.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%

% History:
%    XX/XX/18  ZL   SCIEN Stanford, 2018
%    04/03/19  JNM  Documentation pass

%%
% materials = fieldnames(thisR.materials.list);
fields = fieldnames(thisR.materials.list);
nMaterials = length(fieldnames(thisR.materials.list));

fprintf('***  Name  \t [Type]\n');
list = cell(1, nMaterials);

for ii = 1:nMaterials
    list{ii} = sprintf('%d: %s: \t [ %s ]\n', ii, ...
        thisR.materials.list.(cell2mat(fields(ii))).name, ...
        thisR.materials.list.(cell2mat(fields(ii))).string);
end

for ii = 1:nMaterials
    fprintf('%s', list{ii});
end

fprintf('***End \n');
end