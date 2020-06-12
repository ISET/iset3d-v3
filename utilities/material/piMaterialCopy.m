function thisMaterial = piMaterialCopy(thisMaterial, target)

materialProperties = fieldnames(target);
nProperties = length(materialProperties);
for ii = 1:nProperties
    if ~isempty(target.(materialProperties{ii}))
        thisMaterial.(materialProperties{ii}) = target.(materialProperties{ii});
    end
end

end