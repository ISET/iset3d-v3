function thisMaterial = piMaterialCopy(thisMaterial,target)

materialProperties = fieldnames(target);
nProperties = length(materialProperties);
for ii = 1:nProperties
    thisMaterial.(materialProperties{ii}) = target.(materialProperties{ii});
end

end