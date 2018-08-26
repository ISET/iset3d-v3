function thisR = piSkymapAdd(thisR,input)
% Choose a skybox, or random skybox, write this line to thisR.world.
%
% Inputs
%   thisR - A rendering recipe
%   skymap options:
%        'morning'
%        'day'
%        'dusk'
%        'sunset'
%        'night'
%        'cloudy'
%        'random'- pick a random skymap from skymaps folder
%
% Returns
%   none, but thisR.world is modified.
%
% Example: 
%    piAddSkymap(thisR,'day');
%
% Zhenyi,2018

%% Programming TODO
%  We need to check whether we are replacing a skymap or adding a new
%  one.  If one exists, then we are replacing it!
%

%%
skymaps = fullfile(piRootPath,'data','skymaps');
input = lower(input);
switch input
    case 'morning'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/morn.exr" "rgb L" [2 2 2]');
    case 'day'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/day.exr" "rgb L" [2 2 2]');
    case 'dusk'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/dusk.exr" ');
    case 'sunset'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/sunset_1.exr"');
    case 'night'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/night.exr"');
    case 'cloudy'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/cloudy.exr" "rgb L" [2 2 2]');
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
world(3,:) = cellstr(sprintf('Rotate -90 1 0 0'));
world(4,:) = cellstr(sprintf('Scale 1 1 1'));
world(5,:) = cellstr(skylights);
world(6,:) = cellstr(sprintf('AttributeEnd'));
world(7,:) = cellstr(sprintf('LightSource "distant" "point from" [ -30 40  100 ] "blackbody L" [6500 2]'));
jj=4;% skip materials and lightsource which are exported from C4D.
for ii=1:(length(thisR.world)-3)
    world(ii+7,:)=thisR.world(jj);
    jj=jj+1;
end

thisR.world = world;
end
