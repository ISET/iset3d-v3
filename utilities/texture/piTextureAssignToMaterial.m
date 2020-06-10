function thisR = piTextureAssignToMaterial(thisR, materialName,...
                        materialParam, textureIdx, varargin)
%
% Inputs:
%   thisR           - Recipe
%   materialName    - Name of the material
%   materialParam   - Name of the material parameter
%   textureIdx      - Index of the target texture

%% Parse inputs
p = inputParser;
p.addRequired('thisR', @(x)(isa(x, 'recipe')));
p.addRequired('materialName', @ischar);
p.addRequired('materialParam', @ischar);
p.addRequired('textureIdx', @isnumeric);

p.parse(thisR, materialName, materialParam, textureIdx);
thisR = p.Results.thisR;
materialName = p.Results.materialName;
materialParam = p.Results.materialParam;
textureIdx = p.Results.textureIdx;

%%
typeNname= split(materialParam, ' ');
type = typeNname{1}; name = typeNname{2};

switch thisR.recipeVer
    case 2
        % Need Zheng to check this
        error('No idea what to do here.  ZLY needs to deal with this');
        
        idx = piMaterialFind(thisR,'name','Mat');
        thisMaterial = thisR.materials.list{idx};
        
        thisR.materials.list{textureIdx}.name = materialName;
        thisR.materials.list{textureIdx}.(materialName) = materialName;

        for ii = 1:numel(paramNames)
            if contains(paramNames{ii}, name)
                if contains(paramNames{ii}, 'float')
                    thisR.material.list.(materialName).paraNames{ii} = [];
                elseif contains(paramNames{ii}, 'spectrum')
                    thisR.material.list.(materialName).paraNames{ii} = '';
                end
            end
        end
        
        thisR.materials.list.(materialName).(ieParamFormat(strcat('texture ', name))) =...
            thisR.textures.list{textureIdx}.name;
        
    otherwise
        % Some day this will go away.  Still here for backwards
        % compatibility
        if ~isfield(thisR.materials.list, materialName)
            error('Unknown material name: %s', materialName);
        end
        
        paramNames = fieldnames(thisR.materials.list.(materialName));
        
        for ii = 1:numel(paramNames)
            if contains(paramNames{ii}, name)
                if contains(paramNames{ii}, 'float')
                    thisR.material.list.(materialName).paraNames{ii} = [];
                elseif contains(paramNames{ii}, 'spectrum')
                    thisR.material.list.(materialName).paraNames{ii} = '';
                end
            end
        end
        
        thisR.materials.list.(materialName).(ieParamFormat(strcat('texture ', name))) =...
            thisR.textures.list{textureIdx}.name;
end
end