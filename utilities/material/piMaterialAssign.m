function piMaterialAssign(thisR,material,target,varargin)
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
% p.addRequired('material',@ischar);
p.addRequired('target',@isstruct);
p.addParameter('rgbkd',[]);
p.addParameter('rgbks',[]);
p.addParameter('rgbkr',[]);
p.addParameter('rgbkt',[]);
p.addParameter('colorkd',[]);
p.addParameter('colorks',[]);
p.parse(thisR,material,target,varargin{:});


%% Find idx for certain material

% nMaterials = length(thisR.materials);
%list = cell(1,nMaterials);
% % for ii = 1:nMaterials
%     if contains(thisR.materials(ii).name, material)
%     idx = ii;
% Assign Material

% Check if carpaint_mix is wanted
if isfield(target,'paint_base') && isfield(target,'paint_mirror')
    % add paint_mirror
    %     nmaterials = length(thisR.materials.list);
    thisR.materials.list.paint_mirror = piMaterialCreate;
    thisR.materials.list.paint_mirror.name = 'paint_mirror';
    materialName = fieldnames(thisR.materials.list.paint_mirror);
    targetmaterial = fieldnames(target.paint_mirror);
    types =intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        thisR.materials.list.paint_mirror.(types{i}) = target.paint_mirror.(types{i});
    end
    % add paint_base  
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
        targetmaterial = fieldnames(target.paint_base);
        types =intersect(materialName, targetmaterial);
        nTypes = length(types);
        for i = 1:nTypes
            thisR.materials.list.(slotname).(types{i}) = target.paint_base.(types{i});
        end
        % Assign a different paint_base to carpaintmix
        materialName = fieldnames(material);
        targetmaterial = fieldnames(target.carpaint);
        types =intersect(materialName, targetmaterial);
        nTypes = length(types);
        for i = 1:nTypes
            material.(types{i}) = target.carpaint.(types{i});
        end
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
        targetmaterial = fieldnames(target.paint_base);
        types =intersect(materialName, targetmaterial);
        nTypes = length(types);
        for i = 1:nTypes
            thisR.materials.list.paint_base.(types{i}) = target.paint_base.(types{i});
        end
        
        
        % Assign carpaintmix
        materialName = fieldnames(material);
        targetmaterial = fieldnames(target.carpaint);
        types =intersect(materialName, targetmaterial);
        nTypes = length(types);
        for i = 1:nTypes
            material.(types{i}) = target.carpaint.(types{i});
        end
    end
    %% Assign color 
    if ~isempty(p.Results.rgbkd); thisR.materials.list.paint_base.rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.rgbkr); thisR.materials.list.paint_base.rgbkr = p.Results.rgbkr; end
    if ~isempty(p.Results.rgbkt); thisR.materials.list.paint_base.rgbkt = p.Results.rgbkt; end
    if ~isempty(p.Results.rgbks); thisR.materials.list.paint_base.rgbks = p.Results.rgbks; end 
    if ~isempty(p.Results.rgbkd); thisR.materials.list.paint_base.rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.colorkd);thisR.materials.list.paint_base.colorkd = p.Results.colorkd;end
    if ~isempty(p.Results.colorks);thisR.materials.list.paint_base.colorks = p.Results.colorks;end
else
    % The original material should have every possible type of slot.
    % So the intersect may not be necessary.  We just want to write
    % all of the target slots into the material.
    materialName = fieldnames(material);
    targetmaterial = fieldnames(target);
    types  = intersect(materialName, targetmaterial);
    nTypes = length(types);
    for i = 1:nTypes
        material.(types{i}) = target.(types{i});
    end
    %% Assign color
    if ~isempty(p.Results.rgbkd); material.rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.rgbkr); material.rgbkr = p.Results.rgbkr; end
    if ~isempty(p.Results.rgbkt); material.rgbkt = p.Results.rgbkt; end
    if ~isempty(p.Results.rgbks); material.rgbks = p.Results.rgbks; end 
    if ~isempty(p.Results.rgbkd); material.rgbkd = p.Results.rgbkd; end
    if ~isempty(p.Results.colorkd);material.colorkd = p.Results.colorkd;end
    if ~isempty(p.Results.colorks);material.colorks = p.Results.colorks;end
end


end


