function piMaterialList(thisR)
% List materials type in this PBRT scene
%
% ZL, SCIEN Stanford, 2018

%%
materials =thisR.materials;
nMaterials = length(materials);
%%
fprintf('***  Name  \t [Type]\n');

list = cell(1,nMaterials);
for ii =1:nMaterials
    list{ii} = sprintf('%d: %s:\t [ %s ]\n', ii, materials(ii).name,materials(ii).string);
    fprintf('%s',list{ii});
end

fprintf('***End \n');
end