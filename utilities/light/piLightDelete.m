function thisR = piLightDelete(thisR, index)
%% This function is going to be deprecated
% Remove a light source from a render recipe.
%
% Syntax:
%   thisR = piLightDelete(thisR, index)
%
% Brief description
%   Remove a specific light source from a scene.
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
% ZLY, SCIEN, 2020
%
% see also: piLightGetNew, piLightsAddNew

if ischar(index) && strcmp(index, 'all')
%% Clear the lights
    thisR.lights = {};
else
    if numel(thisR.lights) <= 1 && index == 1
        thisR.lights = [];
    else
        if index > numel(thisR.lights)
            error('Total light number %d, but input index %d', numel(thisR.lights), index);
        end
        thisR.lights(index) = [];
    end
end

end