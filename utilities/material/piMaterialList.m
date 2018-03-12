function piMaterialList(thisR)
% List materials type in this PBRT scene
%
% ZL, SCIEN Stanford, 2018

%%

%materials = fieldnames(thisR.materials.list);
fields = fieldnames(thisR.materials.list);
nMaterials = length(fieldnames(thisR.materials.list));
%%
fprintf('***  Name  \t [Type]\n');

list = cell(1,nMaterials);

for ii =1:nMaterials
    list{ii} = sprintf('%d: %s: \t [ %s ]\n', ii, thisR.materials.list.(cell2mat(fields(ii))).name,thisR.materials.list.(cell2mat(fields(ii))).string);
end
for ii =1:nMaterials
    fprintf('%s',list{ii});
end

fprintf('***End \n');
end