function piMaterialGroupAssign(thisR)
% generate a material list
mlist = fieldnames(thisR.materials.list);
for ii = 1:length(mlist)
    if  contains(mlist(ii),'carbody')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.carpaintmix;
        piMaterialAssign(thisR,material.name,target);
    elseif contains(mlist(ii),'window')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        rgbkr = [0.5 0.5 0.5];
        piMaterialAssign(thisR,material.name,target,'rgbkr',rgbkr);
    elseif contains(mlist(ii),'mirror')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.mirror;
        piMaterialAssign(thisR,material.name,target);
    elseif contains(mlist(ii),'lightsfront')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        piMaterialAssign(thisR,material.name,target);
    elseif contains(mlist(ii),'lightsback')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        rgbkr = [1 0 0];
        piMaterialAssign(thisR,material.name,target);
    elseif contains(mlist(ii),'chrome')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.chrome_spd;
        piMaterialAssign(thisR,material.name,target);
    elseif contains(mlist(ii),'wheel')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.uber;
        piMaterialAssign(thisR,material.name,target);
    elseif contains(mlist(ii),'tire')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.blackrubber;
        piMaterialAssign(thisR,material.name,target);
    elseif contains(mlist(ii),'plastic')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.plastic;
        piMaterialAssign(thisR,material.name,target);
    elseif contains(mlist(ii),'metal')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.chrome_spd;
        piMaterialAssign(thisR,material.name,target);
    elseif contains(mlist(ii),'glass')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        piMaterialAssign(thisR,material.name,target);
    elseif contains(mlist(ii),'retro')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.retroreflective;
        piMaterialAssign(thisR,material.name,target);
    else
        %otherwise, assign an default matte material.
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.matte;
        piMaterialAssign(thisR,material.name,target);
    end
end
fprintf('%d materials assigned',ii);
end