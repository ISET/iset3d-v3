function piMaterialAssign(thisR, materialName, target, varargin)
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
piMaterialAssign(thisR,'material','carpaint','rgbkr',[1,0,0]);
%}

%%
p = inputParser;
p.KeepUnmatched = true;

vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addRequired('materialName',@ischar);
p.addRequired('target',@isstruct);

p.addParameter('rgbkd',[]);
p.addParameter('rgbks',[]);
p.addParameter('rgbkr',[]);
p.addParameter('rgbkt',[]);
p.addParameter('colorkd',[]);
p.addParameter('colorks',[]);
p.addParameter('colorreflect',[]);
p.addParameter('colortransmit',[]);

p.addParameter('spectrumkd',[]);
p.addParameter('spectrumks',[]);
p.addParameter('spectrumkr',[]);
p.addParameter('spectrumkt',[]);
p.addParameter('spectrumeta',[]);
p.addParameter('spectrumk',[]); % Not sure what is this

p.parse(thisR, materialName,target,varargin{:});

%% Find which material in the list matches the material string

idx = piMaterialFind(thisR.materials.list, 'name', materialName);

%% Assign Material
% Check if carpaint_mix is wanted
if isfield(target,'paint_base') && isfield(target,'paint_mirror')
    
    % add paint_mirror
    %     nmaterials = length(thisR.materials.list);
    if ~isfield(thisR.materials.list,'paint_mirror')
        % Create paint_mirro material in the mat list, not sure why we need
        % it? ZLY
        
        piMaterialCreate(thisR, 'name', 'paint_mirror');
        
        
        thisR.materials.list{end} = ...
            piMaterialCopy(thisR.materials.list{end},target.paint_mirror);
        
        slotname1 = sprintf('%s_paint_base',materialName);
        [~, thisIdx] = piMaterialCreate(thisR, 'name', slotname1);
        % Paint base
        thisR.materials.list{thisIdx} = ...
            piMaterialCopy(thisR.materials.list{thisIdx},target.paint_base);
        % Assign color
        thisR.materials.list{thisIdx} = ...
            piCopyColor(thisR.materials.list{thisIdx}, p);

        % Assign carpaintmix
        thisR.materials.list{idx} = ...
            piMaterialCopy(thisR.materials.list{idx},target.carpaint);

        % Change paint_base to carname_paint_base
        thisR.materials.list{idx}.stringnamedmaterial2 = sprintf('%s_paint_base',materialName);    

    else
        thispaint_base = sprintf('%s_paint_base',materialName);

        paint = piMaterialFind(thisR, 'name', thispaint_base);
        
        if ~isempty(paint)
            thisR.materials.list{paint} = ...
                piCopyColor(thisR.materials.list{paint}, p);
            thisR.materials.list{idx}.stringnamedmaterial2 = sprintf('%s_paint_base',materialName);
        else
            slotname1 = sprintf('%s_paint_base',materialName);
            [~, thisIdx] = piMaterialCreate(thisR, 'name', slotname1);
            % Paint base
            thisR.materials.list{thisIdx} = ...
                piMaterialCopy(thisR.materials.list{thisIdx},target.paint_base);
            % Assign color
            thisR.materials.list{thisIdx} = ...
                piCopyColor(thisR.materials.list{thisIdx}, p);
            
            % Assign carpaintmix
            thisR.materials.list{idx} = ...
                piMaterialCopy(thisR.materials.list{idx},target.carpaint);
            % change paint_base to carname_paint_base
            thisR.materials.list{idx}.stringnamedmaterial2 = sprintf('%s_paint_base',materialName);

        end
    end
%     %% Assign color
%     thisR.materials.list.(slotname1) = ...
%         piCopyColor(thisR.materials.list.(slotname1), p);
    
else
    % The original material has every possible type of material slot.
    % We write all of the target slots into the corresponding material
    % slots
    thisR.materials.list{idx} = ...
        piMaterialCopy(thisR.materials.list{idx},target);
    
    %% Assign color the person sent ins
    thisR.materials.list{idx} = ...
        piCopyColor(thisR.materials.list{idx}, p);
    
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
