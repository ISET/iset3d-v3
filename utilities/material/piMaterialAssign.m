function piMaterialAssign(thisR, material, target, varargin)
% Assign a material (target) to the idx material in the recipe
%
%   We get a target material from the materiallib.  We add the
%   properties of that target material onto the material (idx) in the
%   recipe 
%   Adding functions for changing color appearance.
%   Supported color parameters shown below,
%   rgbkr:   [0 0 1]
%   rgbks:   [0 0 1]
%   rgbkd:   [0 0 1]
%   rgbkt:   [0 0 1]
%   colorkd: [0 0 1]
%   colorks: [0 0 1]
%
% ZL Scien Stanford, 2018

%{
piAssignMaterial(thisR,'material','carpaint','rgbkr',[1,0,0]);
%}

%%
p = inputParser;
p.KeepUnmatched = true;

vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addRequired('material',@ischar);
p.addRequired('target',@isstruct);

p.addParameter('rgbkd',[]);
p.addParameter('rgbks',[]);
p.addParameter('rgbkr',[]);
p.addParameter('rgbkt',[]);
p.addParameter('colorkd',[]);
p.addParameter('colorks',[]);

p.parse(thisR, material,target,varargin{:});

%% Find which material in the list matches the material string
materialNames = fieldnames(thisR.materials.list);
for ii = 1:length(materialNames)
    if strcmp(materialNames{ii}, material)
        idx = ii;
        break;
    end
end
% find obj name

%% Assign Material
% Check if carpaint_mix is wanted
if isfield(target,'paint_base') && isfield(target,'paint_mirror')
    % add paint_mirror
    %     nmaterials = length(thisR.materials.list);
    thisR.materials.list.paint_mirror = piMaterialCreate;
    thisR.materials.list.paint_mirror.name = 'paint_mirror';
    thisR.materials.list.paint_mirror = ...
        piCopyMaterial(thisR.materials.list.paint_mirror,target.paint_mirror);

%     % find how many paint_base is there already.
%     A = count(fieldnames(thisR.materials.list),'paint_base');
%     cnt = 0;
%     for ii = 1: length(A)
%         if A(ii)~= 0
%             cnt = cnt+1;
%         end
%     end

%     if cnt~=0
%         slotname = sprintf('%s_paint_base%d',material,cnt);
%         thisR.materials.list.(slotname) = piMaterialCreate;
%         thisR.materials.list.(slotname).name = slotname;
% 
%         thisR.materials.list.(slotname) = ...
%             piCopyMaterial(thisR.materials.list.(slotname),target.paint_base);
% 
%         material = piCopyMaterial(material,target.carpaint);
% 
%         material.carpaint.stringnamedmaterial2 = slotname;
%         if ~isempty(p.Results.rgbkd)
%             thisR.materials.list.(slotname).rgbkd = p.Results.rgbkd;
%         end
%     %% Assign color
%     thisR.materials.list.(slotname) = ...
%         piCopyColor(thisR.materials.list.(slotname), p);
% 
% %     else
        slotname1 = sprintf('%s_paint_base',material);
        thisR.materials.list.(slotname1) = piMaterialCreate;
        thisR.materials.list.(slotname1).name = slotname1;
        
        % Paint base
        thisR.materials.list.(slotname1) = ...
            piCopyMaterial(thisR.materials.list.(slotname1),target.paint_base);
        
        % Assign carpaintmix
        thisR.materials.list.(materialNames{idx}) = ...
            piCopyMaterial(thisR.materials.list.(materialNames{idx}),target.carpaint);
        % change paint_base to carname_paint_base
        thisR.materials.list.(materialNames{idx}).stringnamedmaterial2 = sprintf('%s_paint_base',material);
        
%     end
    %% Assign color
    thisR.materials.list.(slotname1) = ...
        piCopyColor(thisR.materials.list.(slotname1), p);

else
    % The original material has every possible type of material slot.
    % We write all of the target slots into the corresponding material
    % slots 
    thisR.materials.list.(materialNames{idx}) = ...
        piCopyMaterial(thisR.materials.list.(materialNames{idx}),target);
    
    %% Assign color the person sent ins
    thisR.materials.list.(materialNames{idx}) = ...
        piCopyColor(thisR.materials.list.(materialNames{idx}), p);

end


end

%% Material assignment
function thisMaterial = piCopyMaterial(thisMaterial,target)

materialProperties = fieldnames(target);
nProperties = length(materialProperties);
for ii = 1:nProperties
    thisMaterial.(materialProperties{ii}) = target.(materialProperties{ii});
end

end

%% Color assignment
function thisColor = piCopyColor(thisColor, p)
    if ~isempty(p.Results.rgbkd);  thisColor.rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.rgbkr);  thisColor.rgbkr = p.Results.rgbkr; end
    if ~isempty(p.Results.rgbkt);  thisColor.rgbkt = p.Results.rgbkt; end
    if ~isempty(p.Results.rgbks);  thisColor.rgbks = p.Results.rgbks; end 
    if ~isempty(p.Results.rgbkd);  thisColor.rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.colorkd);thisColor.colorkd = p.Results.colorkd;end
    if ~isempty(p.Results.colorks);thisColor.colorks = p.Results.colorks;end
end


