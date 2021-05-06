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
% see also: 
%   piLightGet, piLightsAdd

%% Parse
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.addRequired('indices', @iscell);
p.parse(thisR, indices);

%% Get the text in the world

world = thisR.world;

% Delete the lines from the highest range to the lowest. That way  we don't
% change the line number by the deletion
for ii=numel(indices):-1:1
    if numel(indices{ii})>1
        world(indices{ii}(1):indices{ii}(2)) = [];
    else
        world(indices{ii}(1)) = [];
    end
end

thisR.world = world;

end