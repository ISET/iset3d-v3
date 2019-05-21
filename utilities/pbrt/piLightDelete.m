function thisR = piLightDelete(thisR, lightSource, index)
% Remove light source from render recipe
% Input:
%       thisR
%       lightsource struct(output of piLightGet)
%       index: the target of lightsource to be removed
% see also: piLightGet, piLightsAdd
% Zhenyi, SCIEN, 2019
world = thisR.world;
if ischar(index) && strcmp(index, 'all')
    for ii = 1:length(lightSource)
        world(lightSource{ii}.range(1):lightSource{ii}.range(2)) = {};
    end
else
    world(lightSource{index}.range(1):lightSource{index}.range(2)) = []; 
end
thisR.world = world;
end