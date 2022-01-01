function [thisR, textureNames] = piTextureInsert(thisR)
% Deprecate:  Insert some common textures into the recipe
%
% I think we create the textures and then add them to materials in
% piMaterialsInsert, rather than adding the textures to the recipe.  Just a
% thought for now.
%
% Synopsis
%    [thisR, textureNames] = piTextureInsert(thisR)
%
% Brief description
%   Adding a wood grain and a brickwall textures.  More later, such as
%   marble and mahogany.  Though
%
% Inputs
%   thisR:  Recipe
%
% Output
%   thisR:  Modified recipe
%   textureNames:  Names that were added
%
% Description
%   This routine makes it easier to access some standard textures. We will
%   build up this list over time. 
%

% Variable checking needed.
textureNames = {};

% Wood grain
woodName = 'wood';
woodTexture = piTextureCreate(woodName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'woodgrain001.png');
thisR.set('texture', 'add', woodTexture);
textureNames{end+1} = woodName;

woodName = 'mahogany';
woodTexture = piTextureCreate(woodName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'mahoganyDark.exr');
thisR.set('texture', 'add', woodTexture);
textureNames{end+1} = woodName;

% Brick wall
brickwallName = 'brickwall';
brickwallTexture = piTextureCreate(brickwallName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'brickwall001.png');
thisR.set('texture', 'add', brickwallTexture);
textureNames{end+1} = brickwallName;

end