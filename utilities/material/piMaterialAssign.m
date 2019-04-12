function piMaterialAssign(thisR, material, target, varargin)
% Assign a material (target) to the list of material in the recipe
%
% Syntax:
%   piMaterialAssign(thisR, material, target, [varargin])
%
% Description:
%    Assign the material in target to the list of materials in the provided
%    recipe, with the material variable containing the material's name.
%
%    We get a target material from the materiallib. We add the properties
%    of that target material onto the material (idx) in the recipe
%    Adding functions for changing color appearance.
%    Supported color parameters shown below, 
%       rgbkr:   [0 0 1]
%       rgbks:   [0 0 1]
%       rgbkd:   [0 0 1]
%       rgbkt:   [0 0 1]
%       colorkd: [0 0 1]
%       colorks: [0 0 1]
%
% Inputs:
%    thisR    - Object. A recipe object.
%    material - String. A string indicating the material.
%    target   - Struct. The material structure.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    rgbkd    - Matrix. A color changing parameter, the 1x3 matrix
%               representing RGB values for KD. Default is [].
%    rgbks    - Matrix. A color changing parameter, the 1x3 matrix
%               representing RGB values for KS. Default is [].
%    rgbkr    - Matrix. A color changing parameter, the 1x3 matrix
%               representing RGB values for KR. Default is [].
%    rgbkt    - Matrix. A color changing parameter, the 1x3 matrix
%               representing RGB values for KT. Default is [].
%    colorkd  - Matrix. A color changing parameter, the 1x3 matrix
%               representing color values for KD. Default is [].
%    colorks  - Matrix. A color changing parameter, the 1x3 matrix
%               representing color values for KS. Default is [].
%

% History:
%    XX/XX/18  ZL   Scien Stanford, 2018
%    04/03/19  JNM  Documentation pass

%{
    piAssignMaterial(thisR, 'material', 'carpaint', 'rgbkr', [1, 0, 0]);
%}

%%
p = inputParser;
p.KeepUnmatched = true;

vFunc = @(x)(isequal(class(x), 'recipe'));
p.addRequired('thisR', vFunc);
p.addRequired('material', @ischar);
p.addRequired('target', @isstruct);
p.addParameter('rgbkd', []);
p.addParameter('rgbks', []);
p.addParameter('rgbkr', []);
p.addParameter('rgbkt', []);
p.addParameter('colorkd', []);
p.addParameter('colorks', []);

p.parse(thisR, material, target, varargin{:});

%% Find which material in the list matches the material string
materialNames = fieldnames(thisR.materials.list);
for ii = 1:length(materialNames)
    if strcmp(materialNames{ii}, material)
        idx = ii;
        break;
    end
end

%% Assign Material
% Check if carpaint_mix is wanted
if isfield(target, 'paint_base') && isfield(target, 'paint_mirror')
    % add paint_mirror
    %     nmaterials = length(thisR.materials.list);
    if ~isfield(thisR.materials.list, 'paint_mirror')
    thisR.materials.list.paint_mirror = piMaterialCreate;
    thisR.materials.list.paint_mirror.name = 'paint_mirror';
    thisR.materials.list.paint_mirror = piCopyMaterial(...
        thisR.materials.list.paint_mirror, target.paint_mirror);
    slotname1 = sprintf('%s_paint_base', material);
    thisR.materials.list.(slotname1) = piMaterialCreate;
    thisR.materials.list.(slotname1).name = slotname1;

    % Paint base
    thisR.materials.list.(slotname1) = piCopyMaterial(...
        thisR.materials.list.(slotname1), target.paint_base);

    % Assign carpaintmix
    thisR.materials.list.(materialNames{idx}) = piCopyMaterial(...
        thisR.materials.list.(materialNames{idx}), target.carpaint);
    % change paint_base to carname_paint_base
    thisR.materials.list.(materialNames{idx}).stringnamedmaterial2 = ...
        sprintf('%s_paint_base', material);    
    %% Assign color
    thisR.materials.list.(slotname1) = ...
        piCopyColor(thisR.materials.list.(slotname1), p);
    else
        thispaint_base = sprintf('%s_paint_base', material);
        for jj = 1:length(materialNames)
            if isequal(materialNames{jj}, thispaint_base)
                paint = jj;
            else
                paint = 0;
            end    
        end
        if paint
        thisR.materials.list.(materialNames{paint}) = ...
            piCopyColor(thisR.materials.list.(materialNames{paint}), p);
        thisR.materials.list.(materialNames{idx}).stringnamedmaterial2 ...
            = sprintf('%s_paint_base', material);
        else
            slotname1 = sprintf('%s_paint_base', material);
            thisR.materials.list.(slotname1) = piMaterialCreate;
            thisR.materials.list.(slotname1).name = slotname1;

            % Paint base
            thisR.materials.list.(slotname1) = piCopyMaterial(...
                thisR.materials.list.(slotname1), target.paint_base);

            % Assign carpaintmix
            thisR.materials.list.(materialNames{idx}) = ...
                piCopyMaterial(thisR.materials.list.(...
                materialNames{idx}), target.carpaint);
            % change paint_base to carname_paint_base
            thisR.materials.list.(...
                materialNames{idx}).stringnamedmaterial2 = ...
                sprintf('%s_paint_base', material);
            %% Assign color
            thisR.materials.list.(slotname1) = ...
                piCopyColor(thisR.materials.list.(slotname1), p);
        end
    end
%     %% Assign color
%     thisR.materials.list.(slotname1) = ...
%         piCopyColor(thisR.materials.list.(slotname1), p);

else
    % The original material has every possible type of material slot.
    % We write all of the target slots into the corresponding material
    % slots
    thisR.materials.list.(materialNames{idx}) = ...
        piCopyMaterial(thisR.materials.list.(materialNames{idx}), target);

    %% Assign color the person sent ins
    thisR.materials.list.(materialNames{idx}) = ...
        piCopyColor(thisR.materials.list.(materialNames{idx}), p);

end

end

%% Material assignment
function thisMaterial = piCopyMaterial(thisMaterial, target)
% Assign a material (target) to the provided material thisMaterial
%
% Syntax:
%    thisMaterial = piCopyMaterial(thisMaterial, target)
%
% Description:
%    Assign the material in target to the material thisMaterial, and return
%    the modified thisMaterial material.
%
% Inputs:
%    thisMaterial - Struct. A material structure.
%    target       - Struct. A material structure.
%
% Outputs:
%    thisMaterial - Struct. The modified material structure.
%
% Optional key/value pairs:
%    None.
%

materialProperties = fieldnames(target);
nProperties = length(materialProperties);
for ii = 1:nProperties
    thisMaterial.(materialProperties{ii}) = ...
        target.(materialProperties{ii});
end

end

%% Color assignment
function thisColor = piCopyColor(thisColor, p)
% Assign the color within the input parser p to thisColor
%
% Syntax:
%   thisColor = piCopyColor(thisColor, p)
%
% Description:
%    Assign the color stored in the input parser p to the structure
%    thisColor, and return thisColor. Assign the following values from
%    within p:
%       rgbkd
%       rgbkr
%       rgbkt
%       rgbks
%       colorkd
%       colorks
%
% Inputs:
%    thisColor - Struct. A color structure.
%    p         - Object. An input parser object.
%
% Outputs:
%    thisColor - Struct. The modified structure.
%
% Optional key/value pairs:
%    None.
%
if ~isempty(p.Results.rgbkd), thisColor.rgbkd = p.Results.rgbkd; end
if ~isempty(p.Results.rgbkr), thisColor.rgbkr = p.Results.rgbkr; end
if ~isempty(p.Results.rgbkt), thisColor.rgbkt = p.Results.rgbkt; end
if ~isempty(p.Results.rgbks), thisColor.rgbks = p.Results.rgbks; end
if ~isempty(p.Results.rgbkd), thisColor.rgbkd = p.Results.rgbkd; end
if ~isempty(p.Results.colorkd), thisColor.colorkd = p.Results.colorkd; end
if ~isempty(p.Results.colorks), thisColor.colorks = p.Results.colorks; end
end


