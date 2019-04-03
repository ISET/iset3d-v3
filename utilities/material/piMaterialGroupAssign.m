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
%  piMaterial*


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
case piContains(mList(ii),'carbody')
%}

for ii = 1:length(mlist)
    if  piContains(lower(mlist(ii)),'carbody') && ~piContains(lower(mlist(ii)),'paint_base')
        if piContains(mlist(ii),'black')
            colorkd = piColorPick('black');
        elseif piContains(mlist(ii),'white')
            colorkd = piColorPick('white');
        else
            colorkd = piColorPick('random');
        end
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);    % A string labeling the material 
        target = thisR.materials.lib.carpaintmix;  % 
        piMaterialAssign(thisR,material.name,target,'colorkd',colorkd);
    elseif piContains(lower(mlist(ii)),'carpaint') && ~piContains(mlist(ii),'paint_base')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);    % A string labeling the material 
        target = thisR.materials.lib.carpaintmix;  % 
        colorkd = piColorPick('random');
        piMaterialAssign(thisR,material.name,target,'colorkd',colorkd);
    elseif piContains(lower(mlist(ii)),'window')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        rgbkr = [0.5 0.5 0.5];
        piMaterialAssign(thisR,material.name,target,'rgbkr',rgbkr);
    elseif piContains(lower(mlist(ii)),'mirror')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.mirror;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(lower(mlist(ii)),'lightsfront') || piContains(lower(mlist(ii)),'lightfront')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(lower(mlist(ii)),'lightsback') || piContains(lower(mlist(ii)),'lightback')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        rgbkr = [1 0.1 0.1];
        piMaterialAssign(thisR,material.name,target,'rgbkr',rgbkr);
        thisR.materials.list.(name).rgbkt = [0.7 0.1 0.1];
    elseif piContains(lower(mlist(ii)),'chrome')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.chrome_spd;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(lower(mlist(ii)),'wheel')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.uber;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(lower(mlist(ii)),'rim')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.chrome_spd;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(lower(mlist(ii)),'tire')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.blackrubber;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(lower(mlist(ii)),'plastic')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.plastic;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(lower(mlist(ii)),'metal')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.uber;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(lower(mlist(ii)),'glass')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(lower(mlist(ii)),'bodymat')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.substrate;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(mlist(ii),'translucent')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.translucent;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(lower(mlist(ii)),'wall')
        name = cell2mat(mlist(ii));
        thisR.materials.list.(name).texturebumpmap = 'windy_bump';
    else
        %otherwise, assign an default matte material.
        if ~piContains(mlist(ii),'paint_base')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.uber;
        piMaterialAssign(thisR,material.name,target);
        end
    end
end

% Announce!
fprintf('%d materials assigned \n',ii);

end

