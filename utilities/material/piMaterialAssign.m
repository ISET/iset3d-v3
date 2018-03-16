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
% list = cell(1,nMaterials);

%% Assign Material
% Check if carpaint_mix is wanted
if isfield(target,'paint_base') && isfield(target,'paint_mirror')
    % add paint_mirror
    %     nmaterials = length(thisR.materials.list);
    thisR.materials.list.paint_mirror = piMaterialCreate;
    thisR.materials.list.paint_mirror.name = 'paint_mirror';
    thisR.materials.list.paint_mirror = ...
        piCopyMaterial(thisR.materials.list.paint_mirror,target.paint_mirror);

    % find how many paint_base is there already.
    A = count(fieldnames(thisR.materials.list),'paint_base');
    cnt = 0;
    for ii = 1: length(A)
        if A(ii)~= 0
            cnt = cnt+1;
        end
    end
    if cnt~=0
        slotname = sprintf('paint_base%d',cnt);
        
        thisR.materials.list.(slotname) = piMaterialCreate;
        thisR.materials.list.(slotname).name = slotname;

        thisR.materials.list.(slotname) = ...
            piCopyMaterial(thisR.materials.list.(slotname),target.paint_base);

        material = piCopyMaterial(material,target.carpaint);

        material.carpaint.stringnamedmaterial2 = slotname;
        if ~isempty(p.Results.rgbkd)
            thisR.materials.list.(slotname).rgbkd = p.Results.rgbkd;
        end
    %% Assign color 
    if ~isempty(p.Results.rgbkd); thisR.materials.list.(slotname).rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.rgbkr); thisR.materials.list.(slotname).rgbkr = p.Results.rgbkr; end
    if ~isempty(p.Results.rgbkt); thisR.materials.list.(slotname).rgbkt = p.Results.rgbkt; end
    if ~isempty(p.Results.rgbks); thisR.materials.list.(slotname).rgbks = p.Results.rgbks; end 
    if ~isempty(p.Results.rgbkd); thisR.materials.list.(slotname).rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.colorkd);thisR.materials.list.(slotname).colorkd = p.Results.colorkd;end
    if ~isempty(p.Results.colorks);thisR.materials.list.(slotname).colorks = p.Results.colorks;end
    else
        thisR.materials.list.paint_base = piMaterialCreate;
        thisR.materials.list.paint_base.name = 'paint_base';
        
        % Paint base
        thisR.materials.list.paint_base = ...
            piCopyMaterial(thisR.materials.list.paint_base,target.paint_base);
        
        % Assign carpaintmix
        thisR.materials.list.(materialNames{idx}) = ...
            piCopyMaterial(thisR.materials.list.(materialNames{idx}),target);
        
    end
    %% Assign color 
    if ~isempty(p.Results.rgbkd);  thisR.materials.list.paint_base.rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.rgbkr);  thisR.materials.list.paint_base.rgbkr = p.Results.rgbkr; end
    if ~isempty(p.Results.rgbkt);  thisR.materials.list.paint_base.rgbkt = p.Results.rgbkt; end
    if ~isempty(p.Results.rgbks);  thisR.materials.list.paint_base.rgbks = p.Results.rgbks; end 
    if ~isempty(p.Results.rgbkd);  thisR.materials.list.paint_base.rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.colorkd);thisR.materials.list.paint_base.colorkd = p.Results.colorkd;end
    if ~isempty(p.Results.colorks);thisR.materials.list.paint_base.colorks = p.Results.colorks;end
else
    % The original material has every possible type of material slot.
    % We write all of the target slots into the corresponding material
    % slots 
    thisR.materials.list.(materialNames{idx}) = ...
        piCopyMaterial(thisR.materials.list.(materialNames{idx}),target);
    
    %% Assign color the person sent ins
    if ~isempty(p.Results.rgbkd);  thisR.materials.list.(materialNames{idx}).rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.rgbkr);  thisR.materials.list.(materialNames{idx}).rgbkr = p.Results.rgbkr; end
    if ~isempty(p.Results.rgbkt);  thisR.materials.list.(materialNames{idx}).rgbkt = p.Results.rgbkt; end
    if ~isempty(p.Results.rgbks);  thisR.materials.list.(materialNames{idx}).rgbks = p.Results.rgbks; end 
    if ~isempty(p.Results.rgbkd);  thisR.materials.list.(materialNames{idx}).rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.colorkd);thisR.materials.list.(materialNames{idx}).colorkd = p.Results.colorkd;end
    if ~isempty(p.Results.colorks);thisR.materials.list.(materialNames{idx}).colorks = p.Results.colorks;end
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


