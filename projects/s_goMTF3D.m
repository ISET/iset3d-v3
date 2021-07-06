%%  I would like to control the chart reflectance

% The chess set with pieces
load('ChessSetPieces-recipe','thisR');
chessR = thisR;

% The EIA chart
chart = load('slantedbar.mat');

% Merge them
piRecipeMerge(chessR,chart.thisR,'node name',chart.mergeNode);

% wRotate = chessR.get('asset', eiachart.mergeNode, 'rotation', rotMatrix);

% Position and scale the chart
piAssetSet(chessR,chart.mergeNode,'translate',[0 0.5 2]);
thisScale = chessR.get('asset',chart.mergeNode,'scale');
piAssetSet(chessR,chart.mergeNode,'scale',thisScale.*[0.2 0.2 0.01]);  % scale should always do this

% piWRS(chessR); % Quick check

gridchart = load('gridlines.mat');

piRecipeMerge(chessR,gridchart.thisR,'node name',gridchart.mergeNode);

piAssetSet(chessR,gridchart.mergeNode,'translate',[0.1 0.2 0.2]);
thisScale = chessR.get('asset',gridchart.mergeNode,'scale');
piAssetSet(chessR,gridchart.mergeNode,'scale',thisScale.*[0.05 0.05 0.05]);  % scale should always do this

% z y x
rotMatrix = [-35 10 0; fliplr(eye(3))];
piAssetSet(chessR, gridchart.mergeNode, 'rotation', rotMatrix);

chessR.set('spatial resolution',[1024 1024]);
chessR.set('rays per pixel',128);
scene = piWRS(chessR);

%%
% scene = ieGetObject('scene');
oi = oiCreate;
oi = oiCompute(oi,scene);

sensor = sensorCreate('IMX363');
sensor = sensorSet(sensor,'fov',oiGet(oi,'fov'),oi);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

ip = ipCreate;
ip = ipSet(ip,'render demosaic only',true);
ip = ipCompute(ip,sensor);
ipWindow(ip);





