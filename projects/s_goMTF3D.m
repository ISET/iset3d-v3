%%  s_goMTF3D
%
% Questions:
%   * I am unsure whether the focal distance is in z or in distance from
%   the camera.  So if the camera is at 0, these are the same.  But if the
%   camera is at -0.5, these are not the same.
%
%  * There is trouble scaling the object size.  When the number gets small,
%  the object disappears.  This may be some numerical issue reading the
%  scale factor in the pbrt geometry file?
%

%%
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces

fname = 'ChessSetPieces-recipe';
chessR = piRecipeLoad(fname);

% The EIA chart
sbar = piAssetLoad('slantedbar');


%{
% Adjust the input slot in the recipe for the local user
[~,n,e] = fileparts(chessR.get('input file'));
inFile = which([n,e]);
if isempty(inFile), error('Cannot find the PBRT input file %s\n',chessR.inputFile); end
chessR.set('input file',inFile);

% Adjust the input slot in the recipe for the local user
[p,n,e] = fileparts(chessR.get('output file'));
temp=split(p,'/');
outFile=fullfile(piRootPath,'local',temp{end});
chessR.set('output file',outFile);
%}
% For efficience check
chessR.set('pixel samples',1)

%%
% Merge them
piRecipeMerge(chessR,sbar.thisR,'node name',sbar.mergeNode);

% Position and scale the chart
piAssetSet(chessR,sbar.mergeNode,'translate',[0 0.5 2]);
thisScale = chessR.get('asset',sbar.mergeNode,'scale');
piAssetSet(chessR,sbar.mergeNode,'scale',thisScale.*[0.2 0.2 0.01]);  % scale should always do this
initialScale = chessR.get('asset',sbar.mergeNode,'scale');


% Render the scene with a depth map
scene = piWRS(chessR,'render type','both');

% You can see the distance to different objects in this plot.  Select the
% data tip and the index value is the distance in meters.  The actual
% distance in meters is the index minus chessR.get('from'), which is -0.5,
% I think.
scenePlot(scene,'depth map');

%% Add a lens and render.

camera = piCameraCreate('omni','lensfile','dgauss.22deg.12.5mm.json');
chessR.set('camera',camera);

%% Change the focal distance

% This series sets the focal distance and leaves the slanted bar in place
% at 2.3m from the camera
chessR.set('focal distance',2.3);   % Original distance z value of the slanted bar
oi = piWRS(chessR);  % Write, Render, Show

chessR.set('focal distance',0.7);   % Z value of the rook
oi = piWRS(chessR);  % Write, Render, Show

chessR.set('focal distance', 0.3);   % Z value of the king
oi = piWRS(chessR);  % Write, Render, Show

%% Fix the focal distance and move the slanted bar

% I think this is a z-coordinate not from the camera, which is at -0.5;
chessR.set('focal distance', 0.45);   % Z value of a pawn, but not the nearest one

% This is the size that looks OK at a distance of 2.3m
targetScale = chessR.get('asset',sbar.mergeNode,'scale');

% The scale starts to fail at less than 1/2.3  I suspect  this has to do
% with rounding error, the scale factor gets very small.

% Beyond the focal distance
piAssetSet(chessR, sbar.mergeNode,'translate',[0 0.3 2.3]);
oi = piWRS(chessR);  % Write, Render, Show

% Make it smaller as we get closer.  There is a problem, however.
piAssetSet(chessR, sbar.mergeNode,'scale',targetScale .* [(1/2.3), (1/2.3), 1]);

% Translate the object and scale it - but the scale is not quite enough 
piAssetSet(chessR, sbar.mergeNode,'translate',[0 0.2 1]);
chessR.get('asset',sbar.mergeNode,'scale')
oi = piWRS(chessR);  % Write, Render, Show

% This is the focal distance
piAssetSet(chessR,sbar.mergeNode,'translate',[0 0.2 .45]);
chessR.get('asset',sbar.mergeNode,'scale')
oi = piWRS(chessR);  % Write, Render, Show

% Closer than the focal distance.  The position is relative to the camera,
% at -0.5.
chessR.set('focal distance', 0.25);
piAssetSet(chessR,sbar.mergeNode,'translate',[0 0.1 -0.25]);
chessR.get('asset',sbar.mergeNode,'scale')
oi = piWRS(chessR,'render type','radiance');  % Write, Render, Show


%%
%{
chessR.set('spatial resolution',[1024 1024]);
chessR.set('rays per pixel',128);
oi = piWRS(chessR);
%}

%%
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

% Test chart
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
