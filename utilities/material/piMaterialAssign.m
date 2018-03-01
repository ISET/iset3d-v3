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
p.addRequired('material',@ischar);
p.addRequired('target',@isstruct);
p.addParameter('rgbkd',[]);
p.addParameter('rgbks',[]);
p.addParameter('rgbkr',[]);
p.addParameter('rgbkt',[]);
p.addParameter('colorkd',[]);
p.addParameter('colorks',[]);
p.parse(thisR,material,target,varargin{:});


%% Find idx for certain material

nMaterials = length(thisR.materials);
%list = cell(1,nMaterials);
for ii = 1:nMaterials
    if contains(thisR.materials(ii).name, material) 
    break
    end
end
idx = ii; 
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

%% Assign color

if ~isempty(p.Results.rgbkd)
    thisR.materials(idx).rgbkd = p.Results.rgbkd;
end

if ~isempty(p.Results.rgbkr)
    thisR.materials(idx).rgbkr = p.Results.rgbkr;
end

if ~isempty(p.Results.rgbkt)
    thisR.materials(idx).rgbkt = p.Results.rgbkt;
end

if ~isempty(p.Results.rgbks)
    thisR.materials(idx).rgbks = p.Results.rgbks;
end

if ~isempty(p.Results.rgbkd)
    thisR.materials(idx).rgbkd = p.Results.rgbkd;
end

if ~isempty(p.Results.colorkd)
    thisR.materials(idx).colorkd = p.Results.colorkd;
end

if ~isempty(p.Results.colorks)
    thisR.materials(idx).colorks = p.Results.colorks;
end

end


