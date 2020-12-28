function [thisR,skymapInfo] = piSkymapAdd(thisR,skyName)
% Choose a skymap, or random skybox, write this line to thisR.world.
%
% Inputs
%   thisR - A rendering recipe
%   skymap options:
%        'morning'
%        'sunset'
%        'cloudy'
%        'random'- pick a random skymap from skymaps folder
%        daytime: 06:41-17:59
% Returns
%   none, but thisR.world is modified.
%
% Example:
%    piSkymapAdd(thisR,'day');
%
% Zhenyi,2018

%%
st = scitran('stanfordlabs');
% sunlights = sprintf('# LightSource "distant" "point from" [ -30 100  100 ] "blackbody L" [6500 1.5]');

if ~piContains(skyName,':')

    skyName = lower(skyName);
    if isequal(skyName,'random')
        index = randi(4,1);
        skynamelist = {'morning','noon','sunset','cloudy'};
        skyName = skynamelist{index};
    end
    thisR.metadata.daytime = skyName;
    switch skyName
        case 'morning'
            skyname = sprintf('morning_%03d.exr',randi(4,1));
        case 'noon'
            skyname = sprintf('noon_%03d.exr',randi(10,1));
            % skyname = sprintf('noon_%03d.exr',9);
        case 'sunset'
            skyname = sprintf('sunset_%03d.exr',randi(4,1));
        case 'cloudy'
            skyname = sprintf('cloudy_%03d.exr',randi(2,1));
    end

    % Get the information about the skymap so we can download from
    % Flywheel

    % Is this data/data bit right?
    try
        acquisition = st.fw.lookup('wandell/Graphics auto/assets/data/skymaps');
        dataId      = acquisition.id;
    catch
        % We have had trouble making lookup work across Add-On toolbox
        % versions.  So we have this
        warning('Using piSkymapAdd search, not lookup')
        acquisition = st.search('acquisitions',...
            'project label exact','Graphics auto',...
            'session label exact','data',...
            'acquisition label exact','skymaps');
        dataId = st.objectParse(acquisition{1});
    end
else
    % Fix this with Flywheel and Justin E
    time = strsplit(skyName,':');
    acqName = sprintf('wandell/Graphics auto/assets/skymap_daytime/%02d00',str2double(time{1}));
    thisAcq = st.fw.lookup(acqName);
    dataId = thisAcq.id;
    skyname= sprintf('probe_%02d-%02d_latlongmap.exr',str2double(time{1}),str2double(time{2}));
end

skylights = sprintf('LightSource "infinite" "string mapname" "%s"',skyname);

index_m = find(piContains(thisR.world,'_materials.pbrt'));


% skyview = randi(360,1);
% skyview = randi(45,1)+45;% tmp
skyview = 45;% tmp

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

skymapInfo = [dataId,' ',skyname];

end
