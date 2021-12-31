function [thisR, textureNames] = piTexturesInsert(thisR)
% Insert common textures into the recipe
%
% Synopsis
%    [thisR, textureNames] = piTextureInsert(thisR)
%
% Adding a wood grain and a brickwall
%
% We will build this up over time to allow adding different groups and
% making it easier to program up interesting scenes
%

%% Variable checking needed.
textureNames = {};

%%

% Wood grain
woodName = 'wood';
woodTexture = piTextureCreate(woodName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'woodgrain001.png');
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