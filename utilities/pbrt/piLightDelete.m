function thisR = piLightDelete(thisR, index)
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
% Zhenyi, TL, SCIEN, 2019
%
% see also: piLightGet, piLightsAdd

% Get list of light sources
lightSource = piLightGet(thisR, 'print', false);
world = thisR.world;

if ischar(index) && strcmp(index, 'all')
    
    for ii = 1:length(lightSource)
        
        % TL: This doesn't look right to me...I've replaced "thislight"
        % with "lightSource{ii}" instead. 
        % thislight = piLightGet(thisR,'print',false);
        
        % Range indicates the line index (within the cell matrix that
        % represents the "world") with lights. Sometimes a light can be
        % blocked out by AttributeBegin and AttributeEnd. If this is the
        % case, range will be a 2x1 vector indicating the block of lines to
        % remove. Otherwise a we just remove the single line associated
        % with the light.
        if length(lightSource{ii}.range)>1
            world(lightSource{ii}.range(1):lightSource{ii}.range(2)) = [];
        else
            world(lightSource{ii}.range) = [];
        end
        
        thisR.world = world;
    end
else
    if length(lightSource{index}.range)>1
        world(lightSource{index}.range(1):lightSource{index}.range(2)) = [];
    else
        world(lightSource{index}.range) = [];
    end
        
    thisR.world = world;
end

end