function piMaterialGroupAssign(thisR)
% Map names to material data
%
% Brief synatx
%   piMaterialGroupAssign(recipe)
%
% Describe
%  From a material string (mList), assign two structs, the material
%  and target, to the recipe.  These structs contain the information
%  used by PBRT to render the object materials.
%
% ZL, Vistasoft Team, 2018
%
% See also
%

% A scene has a set of materials represented in its recipe
mlist = fieldnames(thisR.materials.list);

% For each material in the list (mlist) we have a map that converts
% the material list name to a particular material definition in PBRT.
% We should be able to print out this assignment 

% When the material list CONTAINS one of these strings, we know what
% to do.  It doesn't necessarily match exactly.
%{
% Suppose mList(ii) is 'car_body_subaru' we would like this to be
% 'carbodysubaru'.
case contains(mList(ii),'carbody')
%}

for ii = 1:length(mlist)
    if  contains(mlist(ii),'carbody')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);    % A string labeling the material 
        target = thisR.materials.lib.carpaintmix;  % 
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
        piMaterialAssign(thisR,material.name,target,'rgbkr',rgbkr);
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
    elseif contains(mlist(ii),'rim')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.chrome_spd;
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
        target = thisR.materials.lib.uber;
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

% Announce!
fprintf('%d materials assigned \n',ii);

end

