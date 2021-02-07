function thisR = piDeleteWorldText(thisR, indices)
% TODO: Update the description!
% Remove a light source from a render recipe.
%
% Syntax:
%   thisR = piLightDelete(thisR, index)
%
% Brief description
%   Remove a specific light source from world struct in recipe.
%
% Input:
%  thisR - the render Recipe
%  index - the index of the lightsource to be removed. You can use
%          piLightGet to see all the light sources currently in the
%          scene. Optionally, you can use the string 'all' to delete
%          all the light sources in this scene.
%
% Optional key/val
%   N/A
%
% Returns:
%   The modified recipe
%
% Description
%
% Zhenyi, TL, SCIEN, 2019
% Zheng Lyu, 2021
%
% see also: piLightGet, piLightsAdd
%%
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.addRequired('indices', @iscell);
p.parse(thisR, indices);

%%

world = thisR.world;

for ii=1:numel(indices)
    if numel(indices{ii})>1
        world(indices{ii}(1):indices{ii}(2)) = [];
    else
        world(indices{ii}(1)) = [];
    end
end

thisR.world = world;

%%
%{
%% Get list of light sources

lightSource = thisR.lights;
world = thisR.world;

%%
if ischar(indices) && strcmp(indices, 'all')
    
    lightSourceLine = [];
    for ii = 1:length(lightSource)
        
        if length(lightSource{ii}.range)>1
            lightSourceLine = horzcat(lightSourceLine, lightSource{ii}.range(1):lightSource{ii}.range(2));
        else
            lightSourceLine = horzcat(lightSourceLine, lightSource{ii}.range);
        end
    end
    
    world(lightSourceLine) = [];
    thisR.world = world;

else
    if length(lightSource{index}.range)>1
        world(lightSource{index}.range(1):lightSource{index}.range(2)) = [];
    else
        world(lightSource{index}.range) = [];
    end
    
    thisR.world = world; 
end
%}
end