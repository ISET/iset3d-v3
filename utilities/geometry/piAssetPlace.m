function assetsPosList = piAssetPlace(trafficflow,assets,varargin)
%%
% Place assets with the Sumo trafficflow information
%
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
% objects positions are classified by class.
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


