function thisR = piLightDeleteWorld(thisR, index)
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
%
% see also: piLightGet, piLightsAdd

%% Get list of light sources

lightSource = piLightGetFromWorld(thisR, 'print', false);
world = thisR.world;

%%
if ischar(index) && strcmp(index, 'all')
    
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

end