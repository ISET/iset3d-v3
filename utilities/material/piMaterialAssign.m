function piMaterialAssign(thisR,idx,target)
% Assign a material (target) to the idx material in the recipe
%
%   We get a target material from the materiallib.  We add the
%   properties of that target material onto the material (idx) in the
%   recipe 
%
% ZL Scien Stanford, 2018

%{
piAssignMaterial(thisR,16,'carpaint');
%}

%%
p = inputParser;
p.addRequired('thisR',@(x)(isequal(x,'recipe'))); 
p.addRequired('idx',@isscalar);
p.addRequired('target',@isstruct);

%%
if isfield(target,'paint_base') && isfield(target,'paint_mirror')

    % add paint_mirror 
    nmaterials = length(thisR.materials);
    thisR.materials(nmaterials+1) = materialCreate;
    thisR.materials(nmaterials+1).name = 'paint_mirror';
    materialName = fieldnames(thisR.materials(nmaterials+1));
    targetmaterial = fieldnames(target.paint_mirror);
    types =intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials(nmaterials+1).(types{i}) = target.paint_mirror.(types{i});
    end
    % add paint_base
    thisR.materials(nmaterials+2) = materialCreate;
    thisR.materials(nmaterials+2).name = 'paint_base';
    targetmaterial = fieldnames(target.paint_base);
    types =intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials(nmaterials+2).(types{i}) = target.paint_base.(types{i});
    end
    
    % Assign carpaintmix
    materialName = fieldnames(thisR.materials(idx));
    targetmaterial = fieldnames(target.carpaint);
    types =intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials(idx).(types{i}) = target.carpaint.(types{i});
    end
else
    % The original material should have every possible type of slot.
    % So the intersect may not be necessary.  We just want to write
    % all of the target slots into the material.
    materialName = fieldnames(thisR.materials(idx));
    targetmaterial = fieldnames(target);
    types  = intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials(idx).(types{i}) = target.(types{i});
    end
end
end


