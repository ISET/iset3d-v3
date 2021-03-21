function thisR = piTextureAssignToMaterial(thisR, materialidx, materialparam, textureidx, varargin)
%% Deprecated since ZLY implemented a new material/texture structure.

%Place a value about a texture into a material
%
% Synopsis
%  thisR = piTextureAssignToMaterial(thisR, materialidx, materialparam, textureIdx, varargin)
%
% Brief description
%
%
% Inputs:
%   thisR           - Recipe
%   materialIdx     - Index into the material list (or material Name)
%   materialParam   - Material parameter (char)
%   textureIdx      - Index of the target texture
%
% Optional Key/value pairs
%
% Returns
%   thisR - the recipe is adjusted (and pointlessly returned)
%
% Description
%    We say more about materials and their textures here
%
%
% See also
%   piTextureList, t_piTextureSwitch, t_piTextureBasis

% Examples:
%{
  t_piTextureSwitch
%}
%{
  t_piTextureBasis
%}

%% Parse inputs

p = inputParser;
p.addRequired('thisR', @(x)(isa(x, 'recipe')));
p.addRequired('materialidx', @(x)(ischar(x) || isnumeric(x)));
p.addRequired('materialparam', @ischar);
p.addRequired('textureidx', @isnumeric);

p.parse(thisR, materialidx, materialparam, textureidx);
thisR         = p.Results.thisR;
materialidx   = p.Results.materialidx;
materialparam = p.Results.materialparam;
textureidx    = p.Results.textureidx;

%% Set the parameter

% We may be living in only recipeVer 2 land.  So we should think about
% this.
switch thisR.recipeVer
    case 2
        % Need Zheng to check this
        if ischar(materialidx)
            materialidx = piMaterialFind(thisR,'name',materialidx);
        end
        
        textureName = thisR.textures.list{textureidx}.name;
        piMaterialSet(thisR,materialidx, materialparam,textureName);
        % thisR.materials.list{materialidx}.(materialparam) = textureName;
        
    otherwise
        % Some day this will go away.  Still here for backwards
        % compatibility
        if ~isfield(thisR.materials.list, materialidx)
            error('Unknown material name: %s', materialidx);
        end
        
        paramNames = fieldnames(thisR.materials.list.(materialidx));
        
        for ii = 1:numel(paramNames)
            if contains(paramNames{ii}, name)
                if contains(paramNames{ii}, 'float')
                    thisR.material.list.(materialidx).paraNames{ii} = [];
                elseif contains(paramNames{ii}, 'spectrum')
                    thisR.material.list.(materialidx).paraNames{ii} = '';
                end
            end
        end
        
        thisR.materials.list.(materialidx).(ieParamFormat(strcat('texture ', name))) =...
            thisR.textures.list{textureidx}.name;
end

end