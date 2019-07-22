function thisR = piLightDelete(thisR, index)
% Remove a light source from a render recipe.
% Input:
%       thisR - the render Recipe
%       index - the target index of lightsource to be removed. You can use
%               piLightGet to see all the light sources currently in the
%               scene. Can be a number or the string 'all'
%
% see also: piLightGet, piLightsAdd
% Zhenyi, TL, SCIEN, 2019

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