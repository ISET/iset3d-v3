function piAssignmaterial(thisR,indexnum,target)
%% Assign material in materiallib to materials

%{
Assignmaterial(thisR,16,'carpaint');
%}
%%
if strcmp(target,'carpaintmix')

    % add paint_mirror 
    nmaterials = length(thisR.materials);
    thisR.materials(nmaterials+1) = materialCreate;
    thisR.materials(nmaterials+1).name = 'paint_mirror';
    materialName = fieldnames(thisR.materials(nmaterials+1));
    targetmaterial = fieldnames(thisR.materiallib.(target).paint_mirror);
    types =intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials(nmaterials+1).(types{i}) = thisR.materiallib.(target).paint_mirror.(types{i});
    end
    % add paint_base
    thisR.materials(nmaterials+2) = materialCreate;
    thisR.materials(nmaterials+2).name = 'paint_base';
    targetmaterial = fieldnames(thisR.materiallib.(target).paint_base);
    types =intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials(nmaterials+2).(types{i}) = thisR.materiallib.(target).paint_base.(types{i});
    end
    % Assign carpaintmix
    materialName = fieldnames(thisR.materials(indexnum));
    targetmaterial = fieldnames(thisR.materiallib.(target).carpaint);
    types =intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials(indexnum).(types{i}) = thisR.materiallib.(target).carpaint.(types{i});
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

function m = materialCreate
% Template for the material structure.
% We have noticed these as possible additions
%    spectrum Kd
%    xyz Kd
%
% V2 had a specifier 'texture bumpmap' that we don't think is V3.
%

m.name = '';
m.linenumber = [];

m.string = '';
m.floatindex = [];

m.texturekd = '';
m.texturekr = '';
m.textureks = '';

m.rgbkr =[];
m.rgbks =[];
m.rgbkd =[];
m.rgbkt =[];

m.colorkd = [];
m.colorks = [];

m.floaturoughness = [];
m.floatvroughness = [];
m.floatroughness =[];
m.spectrumkd = '';
m.spectrumks ='';
m.stringnamedmaterial1 = '';
m.stringnamedmaterial2 = '';
end

