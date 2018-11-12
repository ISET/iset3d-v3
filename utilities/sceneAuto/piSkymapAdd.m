function [thisR,skymapInfo] = piSkymapAdd(thisR,input)
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

%%
sunlights = sprintf('# LightSource "distant" "point from" [ -30 100  100 ] "blackbody L" [6500 1.5]');
input = lower(input);
if isequal(input,'random')
    index = randi(3,1);
    skynamelist = {'morning','noon','sunset'};
    input = skynamelist{index};
end
switch input
    case 'morning'
        skyname = sprintf('morning_%03d.exr',randi(4,1));       
    case 'noon'
        skyname = sprintf('noon_%03d.exr',1); % favorate one, tmp
%         skyname = sprintf('noon_%03d.exr',randi(10,1));
    case 'sunset'
        skyname = sprintf('sunset_%03d.exr',randi(4,1)); 
    case 'cloudy'
        skyname = sprintf('cloudy_%03d.exr',randi(2,1));
end
skylights = sprintf('LightSource "infinite" "string mapname" "%s"',skyname);

index_m = find(contains(thisR.world,'_materials.pbrt'));
% skyview = randi(360,1);
skyview = randi(45,1)+45;% tmp
world(1,:) = thisR.world(1);
world(2,:) = cellstr(sprintf('AttributeBegin'));
world(3,:) = cellstr(sprintf('Rotate %d 0 1 0',skyview));
world(4,:) = cellstr(sprintf('Rotate -90 1 0 0'));
world(5,:) = cellstr(sprintf('Scale 1 1 1'));
world(6,:) = cellstr(skylights);
world(7,:) = cellstr(sprintf('AttributeEnd'));
jj=1;% skip materials and lightsource which are exported from C4D.
for ii=index_m:length(thisR.world)
    world(jj+7,:)=thisR.world(ii);
    jj=jj+1;
end
thisR.world = world;

% Get the information about the skymap so we can download from
% Flywheel
st          = scitran('stanfordlabs');
acquisition = st.fw.lookup('wandell/Graphics assets/data/skymaps');
dataId      = acquisition.id;
dataName    = skyname;
skymapInfo  = [dataId,' ',dataName];

%{
files = st.search('file',...
   'project label exact','Graphics assets',...
   'session label exact','data',...
   'acquisition label exact','skymaps');

dataId = files{1}.parent.id;
dataName = skyname;
skymapInfo = [dataId,' ',dataName];
%}
end
