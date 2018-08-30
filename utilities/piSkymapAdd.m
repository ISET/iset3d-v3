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
    case 'sunny_park'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/sunny_park.exr"');        
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
    case 'city'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/city.exr"');
    case 'grass'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/grass.exr"');
    case 'cityscape'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/cityscape.exr"');
    case 'park'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/park.exr"');
    case'random'
        curDir = pwd;
        cd(skymaps)
        skylights = dir('*.exr');
        index = randi(length(skylights));
        skyname = skylights(index).name;
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/%s"',skyname);
        cd(curDir);
end

index_m = find(contains(thisR.world,'_materials.pbrt'));
index_sky = find(contains(thisR.world,'mapname'), 1);

if isempty(index_sky) 
        world(1,:) = thisR.world(1);
        world(2,:) = cellstr(sprintf('AttributeBegin'));
        world(3,:) = cellstr(sprintf('Rotate -90 1 0 0'));
        world(4,:) = cellstr(sprintf('Scale 1 1 1'));
        world(5,:) = cellstr(skylights);
        world(6,:) = cellstr(sprintf('AttributeEnd'));
        jj=1;% skip materials and lightsource which are exported from C4D.
        for ii=index_m:length(thisR.world)
            world(jj+6,:)=thisR.world(ii);
            jj=jj+1;
        end
    thisR.world = world;
else
    thisR.world{index_sky} = skylights;
end
end
