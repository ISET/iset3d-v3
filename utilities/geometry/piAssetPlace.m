function assetsPosList = piAssetPlace(trafficflow,varargin)
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
if isfield(trafficflow(timestamp).objects,'Car')
ncars = length(trafficflow(timestamp).objects.Car);
else ncars = 0;end

if isfield(trafficflow(timestamp).objects,'Pedestrian')
nped = length(trafficflow(timestamp).objects.Pedestrian);
else nped = 0;end

assets = piAssetCreate('ncars',ncars,'nped',nped);

% if isfield(lower(trafficflow(timestamp).objects),'bus')
% nBuses = trafficflow(timestamp).objects.Bus;
% assets_bus = piAssetCreate('nbus',nbuses);end
%% objects positions are classified by class.
assets_updated = assets;
if nScene == 1
    for ii = 1: length(assets)
        if isequal(lower(assets(ii).class), 'car')
            position = trafficflow(timestamp).objects.Car(ii).pos;
            assets_updated(ii).geometry = piAssetTranslate(assets(ii).geometry,position);
            rotation = -trafficflow(timestamp).objects.Car(ii).orientation-90;
            assets_updated(ii).geometry = piAssetRotate(assets_updated(ii).geometry,rotation);
        end
        if isequal(lower(assets(ii).class), 'pedestrian')
            position = trafficflow(timestamp).objects.Pedestrian(ii).pos;
            assets_updated(ii).geometry = piAssetTranslate(assets(ii).geometry,position);
            rotation = -trafficflow(timestamp).objects.Pedestrian(ii).orientation-90;
            assets_updated(ii).geometry = piAssetRotate(assets_updated(ii).geometry,rotation);
        end
    end
    assetsPosList{1} = assets_updated;
else
    % Generate random multiple scenes
    timestampList = randperm(length(trafficflow),nScene);
    for jj = 1: length(nScene)
        if isequal(lower(assets(ii).class), 'car')
            position = trafficflow(timestamp).objects.Car(ii).pos;
            assets_updated(ii).geometry = piAssetTranslate(assets(ii).geometry,position);
            rotation = -trafficflow(timestamp).objects.Car(ii).orientation-90;
            assets_updated(ii).geometry = piAssetRotate(assets_updated(ii).geometry,rotation);
        end
        if isequal(lower(assets(ii).class), 'pedestrian')
            position = trafficflow(timestamp).objects.Pedestrian(ii).pos;
            assets_updated(ii).geometry = piAssetTranslate(assets(ii).geometry,position);
            rotation = -trafficflow(timestamp).objects.Pedestrian(ii).orientation-90;
            assets_updated(ii).geometry = piAssetRotate(assets_updated(ii).geometry,rotation);
        end
        assetsPosList{jj} = assets_updated;
    end
end
end


