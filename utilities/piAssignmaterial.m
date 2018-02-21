function piAssignmaterial(thisR,indexnum,target)
%% Assign material in materiallib to materials

%{
Assignmaterial(thisR,16,'carpaint');
%}
%%
if strcmp(target,'carpaintmix')
    materialName = fieldnames(thisR.materials(indexnum));
    targetmaterial = fieldnames(thisR.materiallib.(target).carpaint);
    types =intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials(indexnum).(types{i}) = thisR.materiallib.(target).carpaint.(types{i});
    end
    % add paint_mirror 
    nmaterials = length(thisR.materials);
    thisR.materials(nmaterials+1) = thisR.materials(indexnum);
    thisR.materials(nmaterials+1).name = 'paint_mirror';
    materialName = fieldnames(thisR.materials(nmaterials+1));
    targetmaterial = fieldnames(thisR.materiallib.(target).paint_mirror);
    types =intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials(nmaterials+1).(types{i}) = thisR.materiallib.(target).paint_mirror.(types{i});
    end
    % add paint_base
    thisR.materials(nmaterials+2) = thisR.materials(indexnum);
    thisR.materials(nmaterials+2).name = 'paint_base';
    targetmaterial = fieldnames(thisR.materiallib.(target).paint_base);
    types =intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials(nmaterials+2).(types{i}) = thisR.materiallib.(target).paint_base.(types{i});
    end
else
    materialName = fieldnames(thisR.materials(indexnum));
    targetmaterial = fieldnames(thisR.materiallib.(target));
    types =intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials(indexnum).(types{i}) = thisR.materiallib.(target).(types{i});
    end
end
end
