function piMaterialGroupAssign(thisR)
% Map materials.list names into material data using piMaterialAssign
%
% Brief syntax:
%   piMaterialGroupAssign(recipe)
%
% Describe:
%  This function was built by ZL to manage the material assignments
%  when there are many asset parts. This is frequently the case in the
%  isetauto driving scenes. The known part names are from cars or
%  pedestrian (bodymat).  This list is
%
%  This function processes all the entries in the materials.list in
%  the recipe and invokes the piMaterialAssign for the cars in the
%  isetauto simulation. That function assigns the material to the
%  recipe.  This information is used by PBRT to render the object
%  materials.
%
% Materials recognized in this function
%   (carbody ~paint_base), carpaint , window, mirror, lightsfront, lightsback
%   chrome, wheel, rim, tire, plastic, metal, glass, bodymat, translucent,
%   wall, paint_base
%
% ZL, Vistasoft Team, 2018
%
% See also
%  piMaterial*



%% A scene has a set of materials represented in its recipe
mlist = fieldnames(thisR.materials.list);

% Check whether each entry in mlist contains a known string, such as
% 'carbody'.  If it does contain that string, do a particular
% assignment using (piMaterialAssign).
%
% For each string in the mlist, there is a rule that converts the
% string to a particular material definition in PBRT. That conversion
% is implemented in the if then/else statement below.
%
% The mlist entry might be, say, 'carbody black'.  Then we would
% assign the colorkd to the materal, and we would assign the material
% with the colorkd to the recipe.

for ii = 1:length(mlist)
    if  piContains(lower(mlist(ii)),'carbody') && ~piContains(lower(mlist(ii)),'paint_base')
        % We seem to always be picking a random color for the car body
        % pain base.  This could get adjusted.
        %         if piContains(mlist(ii),'black')
        %             colorkd = piColorPick('black');
        %         elseif piContains(mlist(ii),'white')
        %             colorkd = piColorPick('white');
        %         else
        % Default
        colorkd = piColorPick('random');
        %         end
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);    % A string labeling the material 
        target = thisR.materials.lib.carpaint;  % This is the assignment
        piMaterialAssign(thisR, material.name,target,'colorkd',colorkd);
    elseif piContains(lower(mlist(ii)),'carpaint') && ~piContains(mlist(ii),'paint_base')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);    % A string labeling the material 
        target = thisR.materials.lib.carpaintmix;  % 
        colorkd = piColorPick('random');
        piMaterialAssign(thisR, material.name,target,'colorkd',colorkd);
    elseif piContains(lower(mlist(ii)),'window')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        piMaterialAssign(thisR, material.name,target,'spectrumkr',[400 0.5 800 0.5]);
    elseif piContains(lower(mlist(ii)),'mirror') && ~strcmpi(mlist(ii),'paint_mirror')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.mirror;
        piMaterialAssign(thisR, material.name,target);
    elseif piContains(lower(mlist(ii)),'lightsfront') || piContains(lower(mlist(ii)),'lightfront')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        piMaterialAssign(thisR, material.name,target);
    elseif piContains(lower(mlist(ii)),'lightsback') || piContains(lower(mlist(ii)),'lightback')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        rgbkr = [1 0.1 0.1];
        piMaterialAssign(thisR, material.name,target,'rgbkr',rgbkr);
        thisR.materials.list.(name).rgbkt = [1 0.1 0.1];
        thisR.materials.list.(name).spectrumkr =[];
        thisR.materials.list.(name).spectrumkt =[];
    elseif piContains(lower(mlist(ii)),'chrome')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.chrome_spd;
        piMaterialAssign(thisR, material.name,target);
        copyfile(fullfile(piRootPath,'data','spds'), [fileparts(thisR.inputFile),'/spds']);
    elseif piContains(lower(mlist(ii)),'wheel')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.uber;
        piMaterialAssign(thisR,material.name,target);
    elseif piContains(lower(mlist(ii)),'rim')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.chrome_spd;
        piMaterialAssign(thisR, material.name,target);
    elseif piContains(lower(mlist(ii)),'tire')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.blackrubber;
        piMaterialAssign(thisR, material.name,target);
    elseif piContains(lower(mlist(ii)),'plastic')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.plastic;
        piMaterialAssign(thisR, material.name,target);
    elseif piContains(lower(mlist(ii)),'metal')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.uber;
        piMaterialAssign(thisR, material.name,target);
    elseif piContains(lower(mlist(ii)),'glass')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.glass;
        piMaterialAssign(thisR, material.name,target);
%     elseif piContains(lower(mlist(ii)),'bodymat')
%         name = cell2mat(mlist(ii));
%         material = thisR.materials.list.(name);
%         target = thisR.materials.lib.substrate;
%         piMaterialAssign(thisR, material.name,target);
    elseif piContains(mlist(ii),'translucent')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.translucent;
        piMaterialAssign(thisR, material.name,target);
    elseif piContains(lower(mlist(ii)),'wall')
        name = cell2mat(mlist(ii));
        thisR.materials.list.(name).texturebumpmap = 'windy_bump';
    else
        % Assign an default matte material.
        if ~piContains(mlist(ii),'paint_base')
        name = cell2mat(mlist(ii));
        material = thisR.materials.list.(name);
        target = thisR.materials.lib.uber;
        piMaterialAssign(thisR, material.name,target);
        end
    end
end

% Announce!
fprintf('%d materials assigned \n',ii);

end

