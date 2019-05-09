function thisR = piLightDelete(thisR, lightSource, index)
% Remove light source from render recipe
% Input:
%       thisR
%       lightsource struct(output of piLightGet)
%       index: the target of lightsource to be removed
% see also: piLightGet, piLightsAdd
% Zhenyi, SCIEN, 2019
world = thisR.world;
world(lightSource{index}.range(1):lightSource{index}.range(2)) = [];
thisR.world = world;
end