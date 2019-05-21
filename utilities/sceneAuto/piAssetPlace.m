function [assetsPosList,assets] = piAssetPlace(trafficflow,varargin)
%%
% Place assets with the Sumo trafficflow information
% Sumo generates trafficflow with timesteps, we choose one or multiple
% timestamps, find the number and the class of vehicles for this/these
% timestamp(s) on the road. Download assets with respect to the number and
% class.
%
%
%
%
%
%
%  Zhenyi
%%
p = inputParser;

p.addParameter('nScene',1);
p.addParameter('timestamp',[]);
p.addParameter('trafficlight','red');

p.parse(varargin{:});

nScene =p.Results.nScene;
timestamp = p.Results.timestamp;
trafficlight = p.Results.trafficlight;

%% Download asssets with respect to the number and class of Sumo output.
if isfield(trafficflow(timestamp).objects,'car')
    ncars = length(trafficflow(timestamp).objects.car);
else
    ncars = 0;
end

if isfield(trafficflow(timestamp).objects,'pedestrian')
    nped = length(trafficflow(timestamp).objects.pedestrian);
else
    nped = 0;
end

if isfield(trafficflow(timestamp).objects,'bus')
    nbuses = length(trafficflow(timestamp).objects.car);
else
    nbuses = 0;
end

if isfield(trafficflow(timestamp).objects,'truck')
    ntrucks = length(trafficflow(timestamp).objects.pedestrian);
else
    ntrucks = 0;
end
assets = piAssetCreate('ncars',ncars);
% assets = piAssetCreate('ncars',ncars,'nped',nped,...
%                        'nbuses',nbuses,'ntrucks',ntrucks);

% if isfield(lower(trafficflow(timestamp).objects),'bus')
% nBuses = trafficflow(timestamp).objects.Bus;
% assets_bus = piAssetCreate('nbus',nbuses);end
%% objects positions are classified by class, building/trees might be different.
assets_updated = assets;


if nScene == 1
    assetClassList = fieldnames(assets);
    for hh = 1: length(assetClassList)
        assetClass = assetClassList{hh};
        index = 1;
        order = randperm(numel(trafficflow(timestamp).objects.(assetClass)));
        for ii = 1:numel(trafficflow(timestamp).objects.(assetClass)) 
            assets_shuffled.(assetClass)(ii) = trafficflow(timestamp).objects.(assetClass)(order(ii));
        end
        for ii = 1: length(assets.(assetClass))
            
            [~,n] = size(assets.(assetClass)(ii).geometry(1).position);
            position=cell(n,1);
            rotationY=cell(n,1);
            slope=cell(n,1);
            for gg = 1:n
                position{gg} = assets_shuffled.(assetClass)(index).pos;
                rotationY{gg} = assets_shuffled.(assetClass)(index).orientation-90;
                if isfield(assets_shuffled.(assetClass)(index),'slope')
                    slope{gg} = assets_shuffled.(assetClass)(index).slope;
                end
                index = index+1;
            end
            assets_updated.(assetClass)(ii).geometry = piAssetTranslate(assets.(assetClass)(ii).geometry,position,'instancesNum',n);
            assets_updated.(assetClass)(ii).geometry = piAssetRotate(assets_updated.(assetClass)(ii).geometry,'Y',rotationY,'Z',slope,'instancesNum',n);
        end
    end
    assetsPosList{1} = assets_updated;
end



