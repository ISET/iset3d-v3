function piAddSkymap(thisR,input)
% Choose a skybox, or random skybox, write this line to thisR.world.
% 
% Inputs 
%        thisR - A rendering recipe 
%        skymap: 'morning'                                   
%                'day'
%                'dusk'
%                'sunset'
%                'random'- pick a random skymap from skymaps folder
% retruns 
%        none;
%
% example: piAddSkymap(thisR,'day');
%
% Zhenyi,2018
%%
skymaps = fullfile(piRootPath,'data','skymaps');

switch input
    case 'morning'
    skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/morn.exr"');
    case 'day'
    skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/day.exr"');
    case 'dusk'
    skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/dusk.exr"');
    case 'sunset'
    skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/sunset.exr"');
    case'random'
    skylights = dir(skymaps);
    index = randi(length(skylights));
    if ~contains(skylights(index), '.exr')
        index = randi(length(skylights));
    else
        skyname = skylights(index).name;
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/%s.exr"',skyname);
    end
end


world(1,:) = thisR.world(1);
world(2,:) = cellstr(skylights);
for ii=3:(length(thisR.world)+1)
    world(ii,:)=thisR.world(ii-1);
end
thisR.world = world;
end
