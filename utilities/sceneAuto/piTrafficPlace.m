function [assetsPosList,assets] = piTrafficPlace(trafficflow,varargin)
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
p.addParameter('scitran',[]);
p.addParameter('trafficlight','red');
p.addParameter('resources',true);

p.parse(varargin{:});

nScene =p.Results.nScene;
timestamp = p.Results.timestamp;
trafficlight = p.Results.trafficlight;
resources = p.Results.resources;
st = p.Results.scitran;

if isempty(st)
    st = scitran('stanfordlabs');
end
%% Download asssets with respect to the number and class of Sumo output.
if isfield(trafficflow(timestamp).objects,'car') || isfield(trafficflow(timestamp).objects,'passenger')
    ncars = length(trafficflow(timestamp).objects.car);
%     [~,carList] = piAssetListCreate('class','car',...
%                                       'scitran',st);
else
    ncars = 0;
end

if isfield(trafficflow(timestamp).objects,'pedestrian')
    nped = length(trafficflow(timestamp).objects.pedestrian);
%     [~,pedList] = piAssetListCreate('class','pedestrian',...
%                                       'scitran',st);    
else
    nped = 0;
end

if isfield(trafficflow(timestamp).objects,'bus')
    nbuses = length(trafficflow(timestamp).objects.bus);
%     [~,busList] = piAssetListCreate('class','bus',...
%                                       'scitran',st);    
else
    nbuses = 0;
end

if isfield(trafficflow(timestamp).objects,'truck')
    ntrucks = length(trafficflow(timestamp).objects.truck);
%     [~,truckList] = piAssetListCreate('class','truck',...
%                                 'scitran',st);
else
    ntrucks = 0;
end

if isfield(trafficflow(timestamp).objects,'bicycle')
    nbikes = length(trafficflow(timestamp).objects.bicycle);
%     [~,bikeList] = piAssetListCreate('class','bike',...
%                                 'scitran',st);    
else
    nbikes = 0;
end

assets = piAssetCreate('ncars',ncars,...
                       'nped',nped,...
                       'nbuses',nbuses,...
                       'ntrucks',ntrucks,...
                       'nbikes',nbikes,...
                       'resources',resources,...
                       'scitran',st);
%% objects positions are classified by class, building/trees might be different.
assets_updated = assets;

if nScene == 1
    assetClassList = fieldnames(assets);
    for hh = 1: length(assetClassList)
        assetClass = assetClassList{hh};
        index = 1;
        order = randperm(numel(trafficflow(timestamp).objects.(assetClass)));
        for jj = 1:numel(trafficflow(timestamp).objects.(assetClass)) 
            assets_shuffled.(assetClass)(jj) = trafficflow(timestamp).objects.(assetClass)(order(jj));
        end
        for ii = 1: length(assets.(assetClass))
            
            [~,n] = size(assets.(assetClass)(ii).geometry(1).position);
            position=cell(n,1);
            rotationY=cell(n,1); % rotationY is RotY
            slope   =cell(n,1); % Slope is RotZ
            for gg = 1:n
                position{gg} = assets_shuffled.(assetClass)(index).pos;
                rotationY{gg} = assets_shuffled.(assetClass)(index).orientation-90;
                slope{gg}    = assets_shuffled.(assetClass)(index).slope;
                if isempty(slope{gg}), slope{gg}=0;end
                index = index+1;
            end
            fprintf('%s: ii = %d;jj = %d \n',assetClass,ii,jj);
            assets_updated.(assetClass)(ii).geometry = piAssetTranslate(assets.(assetClass)(ii).geometry,position,'Pos_demention',n);
            assets_updated.(assetClass)(ii).geometry = piAssetRotate(assets_updated.(assetClass)(ii).geometry,'Y',rotationY,'Z',slope,'Pos_demention',n);
        end
    end
    assetsPosList{1} = assets_updated;
end



