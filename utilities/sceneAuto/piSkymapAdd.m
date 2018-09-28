function thisR = piSkymapAdd(thisR,input)
% Choose a skymap, or random skybox, write this line to thisR.world.
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
%        'sunny_park'
%        'grass'
%        'city'
%        'cityscape'
%        'park'
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
sunlights = sprintf('LightSource "distant" "point from" [ -30 100  100 ] "blackbody L" [6500 1.5]');
input = lower(input);
switch input
    case 'morning'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/morn.exr"');
    case 'sunny_park'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/sunny_park.exr"');        
    case 'day'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/day.exr"');
    case 'dusk'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/dusk.exr" ');
    case 'sunset'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/sunset_1.exr"');
    case 'night'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/night.exr"');
    case 'cloudy'
        cloud = randi(3,1);
%         cloud = 3; % tmp
        if cloud ==1, cloud = 'cloudy';elseif cloud==2, cloud = 'cloudy_1'; else cloud = 'cloudy_large'; end
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/%s.exr"',cloud);
    case 'city'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/city.exr"');
    case 'grass'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/grass.exr"');
    case 'cityscape'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/cityscape.exr"');
    case 'park'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/park.exr"');
    case 'doge2'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/doge2_latlong.exr"');
    case 'noon'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/noon.exr"');  
    case 'cloudynoon'
        skylights = sprintf('LightSource "infinite" "string mapname" "skymaps/cloudynoon.exr"');         
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
switch input
    case {'morning','sunny_park','day','grass','cloudy','park','cityscape'}
        if isempty(index_sky)
            world(1,:) = thisR.world(1);
            world(2,:) = cellstr(sprintf('AttributeBegin'));
            world(3,:) = cellstr(sprintf('Rotate -90 1 0 0'));
            world(4,:) = cellstr(sprintf('Scale 1 1 1'));
            world(5,:) = cellstr(skylights);
            world(6,:) = cellstr(sprintf('AttributeEnd'));
            world(7,:) = cellstr(sunlights); % add sunlight
            jj=1;% skip materials and lightsource which are exported from C4D.
            for ii=index_m:length(thisR.world)
                world(jj+7,:)=thisR.world(ii);
                jj=jj+1;
            end
            thisR.world = world;
        else
            thisR.world{index_sky} = skylights;
        end
    otherwise
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
end
