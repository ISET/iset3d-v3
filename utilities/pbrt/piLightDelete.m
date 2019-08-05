function thisR = piLightDelete(thisR, index)
% Remove light source from render recipe
% Input:
%       thisR
%       lightsource struct(output of piLightGet)
%       index: the target of lightsource to be removed, options: an number
%       of 'all'
% see also: piLightGet, piLightsAdd
% Zhenyi, SCIEN, 2019
lightSource = piLightGet(thisR, 'print', false);
world = thisR.world;
if ischar(index) && strcmp(index, 'all')
    for ii = 1:length(lightSource)
        thislight = piLightGet(thisR,'print',false);
        if length(thislight{1}.range)>1
            world(thislight{1}.range(1):thislight{1}.range(2)) = [];
        else
            world(thislight{1}.range) = [];
        end
        thisR.world = world;
    end
else
    world(lightSource{index}.range(1):lightSource{index}.range(2)) = [];
    thisR.world = world;
end

end