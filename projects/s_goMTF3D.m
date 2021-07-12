%%  I would like to control the chart reflectance

% The chess set with pieces
load('ChessSetPieces-recipe','thisR');
chessR = thisR;

% The EIA chart
sbar = piAssetLoad('slantedbar');

% Merge them
piRecipeMerge(chessR,sbar.thisR,'node name',sbar.mergeNode);

% Position and scale the chart
piAssetSet(chessR,sbar.mergeNode,'translate',[0 0.5 2]);
thisScale = chessR.get('asset',sbar.mergeNode,'scale');
piAssetSet(chessR,sbar.mergeNode,'scale',thisScale.*[0.2 0.2 0.01]);  % scale should always do this
initialScale = chessR.get('asset',sbar.mergeNode,'scale');
% piWRS(chessR); % Quick check

%% Now, add a second slanted bar

%% Add a lens
% camera = piCameraCreate('omni','lensfile','dgauss.22deg.12.5mm.json');
camera = piCameraCreate('raytransfer','lensfile','dgauss-22deg-3.0mm.json');

chessR.set('camera',camera);
% piWRS(chessR);  % Write, Render, Show

% piAssetSet(chessR,sbar.mergeNode,'translate',[0 0.1 1]);
% piAssetSet(chessR,sbar.mergeNode,'translate',[0 0.1 .3]);
% piAssetSet(chessR,sbar.mergeNode,'translate',[0 0.1 0]);

% piAssetSet(chessR,sbar.mergeNode,'translate',[0 0.3 -0.1]);  % Fails.

% piWRS(chessR);  % Write, Render, Show

%%
% thisScale = chessR.get('asset',sbar.mergeNode,'scale');
% piAssetSet(chessR,sbar.mergeNode,'scale',thisScale*0.3);   % We should scale by z
piWRS(chessR);  % Write, Render, Show

%%
% scene = ieGetObject('scene');
% oi = oiCreate;
% oi = oiCompute(oi,scene);

%%
oi = ieGetObject('oi');
sensor = sensorCreate('IMX363');
sensor = sensorSet(sensor,'fov',oiGet(oi,'fov'),oi);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

ip = ipCreate;
ip = ipSet(ip,'render demosaic only',true);
ip = ipCompute(ip,sensor);
ipWindow(ip);


%% The chess set with pieces and a camera

load('ChessSetPieces-recipe','thisR');
chessR = thisR;

% The EIA chart
chart = load('slantedbar.mat');

% Merge them
piRecipeMerge(chessR,chart.thisR,'node name',chart.mergeNode);

% Position and scale the chart
piAssetSet(chessR,chart.mergeNode,'translate',[0 0.5 2]);
thisScale = chessR.get('asset',chart.mergeNode,'scale');
piAssetSet(chessR,chart.mergeNode,'scale',thisScale.*[0.2 0.2 0.01]);  % scale should always do this

% piWRS(chessR); % Quick check

%{
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
%}

%% Make a camera
lensfile  = 'dgauss.22deg.6.0mm.json';    % 30 38 18 10
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

% Set the film so that the field of view makes sense

thisR.set('film diagonal',5,'mm');
thisR.get('fov')

%%
chessR.set('spatial resolution',[256 256]);
chessR.set('rays per pixel',1024);
oi = piWRS(chessR);

chessR.set('spatial resolution',[1024 1024]);
chessR.set('rays per pixel',128);
oi = piWRS(chessR);
