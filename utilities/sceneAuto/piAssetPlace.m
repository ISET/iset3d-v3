function [assetsPosList, assets] = piAssetPlace(trafficflow, varargin)
% Use SUMO trafficflow to download & place assets
%
% Syntax:
%   [assetPosList, assets] = piAssetPlace(trafficflow, [varargin])
%
% Description:
%    Place assets with the Sumo trafficflow information. Sumo generates
%    trafficflow with timesteps, we choose one or multiple timestamps, find
%    the number and the class of vehicles for this/these timestamp(s) on
%    the road. Download assets with respect to the number and class.
%
%    trafficflow structure is as follows:
%
%    tf---|---timestamp: the time stamp of traffic simulation
%         |
%         |---objects---car---|
%         |             |     |---class:vehicle/pedestrian
%         |             |     |---name: sumo assigned ID
%         |             |     |---type: police/emergency/...
%         |             |     |---pos : 3d position;
%         |             |     |---speed : m/s
%         |             |     |---orientation: The angle of the vehicle
%         |             |         in navigational standard (0-360
%         |             |         degrees, going clockwise with the 0 at
%         |             |         the 12'o clock position.)
%         |             pedestrian---|
%         |             |            |---class:pedestrian
%         |             |            |---name: sumo assigned ID
%         |             |            |---type: []
%         |             |            |---pos : 3d position;
%         |             |            |---speed : m/s
%         |             |            |---orientation: same as 'car' class
%         |             |
%         |             bus--- same as 'car' class
%         |             |
%         |             |
%         |             truck--- same as 'car' class
%         |             |
%         |             |
%         |             bicycle--- same as 'car' class
%         |             |
%         |             |
%         |             motorcycle--- same as 'car' class
%         |
%         |---light---|
%         |           |--Name: trafficlights' name
%         |           |--State: green/yellow/red
%
% Inputs:
%    trafficflow   - Struct. A structure containing information on the
%                    objects within the scene. These objects include
%                    vehicles, people, and traffic lights(status). The
%                    information's organization is shown above in the
%                    description section.
%
% Outputs:
%    assetsPosList - Struct. The modified structure with assets positions.
%    assets        - Struct. The asset structure with information taken
%                    from trafficflow.
%
% Optional key/value pairs:
%    nScene        - Numeric. The scene number. Default is 1.
%    timestamp     - Array. A numeric array of one or more timestamps
%                    within the scene. Default is [].
%    trafficlight  - String. A string indicating the color of the
%                    trafficlight. Default is 'red'.
%

% History:
%    XX/XX/XX   Z   Zhenyi, Created
%    04/10/19  JNM  Documentation pass
%    05/09/19  JNM  Merge Master in again

%% Initialize & check parameters
p = inputParser;
p.addParameter('nScene', 1);
p.addParameter('timestamp', []);
p.addParameter('trafficlight', 'red');
p.parse(varargin{:});

nScene = p.Results.nScene;
timestamp = p.Results.timestamp;
trafficlight = p.Results.trafficlight;

%% Download asssets with respect to the number and class of Sumo output.
if isfield(trafficflow(timestamp).objects, 'car')
    ncars = length(trafficflow(timestamp).objects.car);
else
    ncars = 0;
end

if isfield(trafficflow(timestamp).objects, 'pedestrian')
    nped = length(trafficflow(timestamp).objects.pedestrian);
else
    nped = 0;
end

if isfield(trafficflow(timestamp).objects, 'bus')
    nbuses = length(trafficflow(timestamp).objects.bus);
else
    nbuses = 0;
end

if isfield(trafficflow(timestamp).objects, 'truck')
    ntrucks = length(trafficflow(timestamp).objects.pedestrian);
else
    ntrucks = 0;
end
assets = piAssetCreate('ncars', ncars);
% assets = piAssetCreate('ncars', ncars, 'nped', nped, ...
%                        'nbuses', nbuses, 'ntrucks', ntrucks);

% if isfield(lower(trafficflow(timestamp).objects), 'bus')
%     nBuses = trafficflow(timestamp).objects.bus;
%     assets_bus = piAssetCreate('nbus', nbuses);
% end

%% objects' positions are classified by class
% Note: building/trees might be different.
assets_updated = assets;
if nScene == 1
    assetClassList = fieldnames(assets);
    for hh = 1: length(assetClassList)
        assetClass = assetClassList{hh};
        index = 1;
        order = ...
            randperm(numel(trafficflow(timestamp).objects.(assetClass)));
        for ii = 1:numel(trafficflow(timestamp).objects.(assetClass))
            assets_shuffled.(assetClass)(ii) = ...
                trafficflow(timestamp).objects.(assetClass)(order(ii));
        end
        for ii = 1: length(assets.(assetClass))
            [~, n] = size(assets.(assetClass)(ii).geometry(1).position);
            position = cell(n, 1);
            rotationY = cell(n, 1);
            slope = cell(n, 1);
            for gg = 1:n
                position{gg} = assets_shuffled.(assetClass)(index).pos;
                rotationY{gg} = ...
                    assets_shuffled.(assetClass)(index).orientation - 90;
                if isfield(assets_shuffled.(assetClass)(index), 'slope')
                    slope{gg} = assets_shuffled.(assetClass)(index).slope;
                end
                index = index + 1;
            end
            assets_updated.(assetClass)(ii).geometry = ...
                piAssetTranslate(assets.(assetClass)(ii).geometry, ...
                position, 'instancesNum', n);
            assets_updated.(assetClass)(ii).geometry = ...
                piAssetRotate(assets_updated.(assetClass)(ii).geometry, ...
                'Y', rotationY, 'Z', slope, 'instancesNum', n);
        end
    end
    assetsPosList{1} = assets_updated;
end
end
