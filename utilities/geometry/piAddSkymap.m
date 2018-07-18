function thisR = piAddSkymap(thisR,input)
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
    case 'night'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/night.exr"');
    case'random'
        curDir = pwd;
        cd(skymaps)
        skylights = dir('*.exr');
        index = randi(length(skylights));
        skyname = skylights(index).name;
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/%s"',skyname);
        cd(curDir);
end


world(1,:) = thisR.world(1);
world(2,:) = cellstr(sprintf('AttributeBegin'));
world(3,:) = cellstr(sprintf('Rotate 90 0 0 1'));
world(4,:) = cellstr(skylights);
world(5,:) = cellstr(sprintf('AttributeEnd'));
jj=2;
for ii=1:(length(thisR.world)-1)
    world(ii+5,:)=thisR.world(jj);
    jj=jj+1;
end
thisR.world = world;
end
