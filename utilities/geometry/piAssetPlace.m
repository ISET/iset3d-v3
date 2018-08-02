function assets = piAssetPlace(trafficflow,assets,varargin)
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
timestamp = p.Results.nScene;
trafficlight = p.Result.trafficlight;
trafficflow;
assets.geometry;


end


