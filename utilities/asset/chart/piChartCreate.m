function [chartR, gName, oName]  = piChartCreate(chartName)
% Create a small calibration chart to insert in a scene
%
% Synopsis
%  [chartR, sName] = piChartCreate(chartName)
%
% Input
%   chartName - 'EIA','rings rays','slanted bar','grid lines', 'face'
%
% Output
%   chartR  - Recipe for the chart
%   gName   - Geometry node name
%   oName   - Object node name
%
% See also

% Examples:
%{
thisChart = piChartCreate('EIA');
piWRS(thisChart);
%}
%{
thisChart = piChartCreate('ringsrays');
piWRS(thisChart);
%}
%{
thisChart = piChartCreate('slanted bar');
piWRS(thisChart);
%}
%{
thisChart = piChartCreate('grid lines');
piWRS(thisChart);
%}
%{
thisChart = piChartCreate('face');
piWRS(thisChart);
%}

%% Make the flat surface recipe.

% This can get simpler once we get piWrite/piRead working with ZLY

chartR = piRecipeDefault('scene name','flatsurface');
chartR.set('asset','Camera_B','delete');
chartR.set('lights','delete','all');

% Add a light.
distantLight = piLightCreate('distant','type','distant',...
    'spd', [6000 0.001], ...
    'cameracoordinate', true);
chartR.set('light','add',distantLight);

% Aim the camera at the object and bring it closer.
chartR.set('from',[0,0,0]);
chartR.set('to',  [0,0,1]);

% Find the position of the surface
surfaceName = '001_Cube_O';

chartR.set('asset',surfaceName,'world position',[0 0 4]);
sz = chartR.get('asset',surfaceName,'size');
% flatR.set('asset',surfaceName,'rotate',[0 0 0]);
chartR.set('asset',surfaceName,'scale', (1 ./ sz));

% This simplifies the tree.
wpos    = chartR.get('asset',surfaceName,'world position');
wscale  = chartR.get('asset',surfaceName,'world scale');
wrotate = chartR.get('asset',surfaceName,'world rotation angle');

% How many geometry nodes (branches) are from the object to the root?
% All the nodes up the path are geometry nodes.  Object nodes are
% always leafs.
id = chartR.get('asset',surfaceName,'path to root');
fprintf('Geometry nodes:  %d\n',numel(id) - 1);

for ii=2:numel(id)
    chartR.set('asset',id(ii),'delete');
end

% Check again
id = chartR.get('asset',surfaceName,'path to root');
fprintf('Geometry nodes:  %d\n',numel(id) - 1);

if (numel(id)-1 == 0)
    geometryNode = piAssetCreate('type','branch');
    geometryNode.name = '001_Cube_G';
    chartR.set('asset','root','add',geometryNode);
    chartR.set('asset',surfaceName,'parent',geometryNode.name);
end

piAssetSet(chartR, geometryNode.name, 'translate',wpos);
piAssetSet(chartR, geometryNode.name, 'scale',wscale);
rotMatrix = [wrotate; fliplr(eye(3))];
piAssetSet(chartR, geometryNode.name, 'rotation', rotMatrix);

%%  Add the chart you want

switch ieParamFormat(chartName)
    case 'eia'        
        textureName = 'EIAChart';
        imgFile   = 'EIA1956-300dpi-center.png';
        
    case 'slantedbar'        
        textureName = 'slantedbar';
        imgFile   = 'slantedbar.png';
        
    case 'ringsrays'
        textureName = 'ringsrays';
        imgFile   = 'ringsrays.png';
        
    case 'gridlines'
        textureName = 'gridlines';
        imgFile = 'gridlines.png';
        
    case 'face'
        textureName = 'face';
        imgFile = 'monochromeFace.png';
        
    otherwise
        error('Unknown chart name %s\n',chartName);
end

%% Make the chart texture

chartTexture = piTextureCreate(textureName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', imgFile);

% Attach the texture to the surface
surfaceMaterial = chartR.get('asset',surfaceName,'material');
chartR.set('texture', 'add', chartTexture);
chartR.set('material', surfaceMaterial.name, 'kd val', textureName);

%% Name the object and geometry node
oName = sprintf('%s-%d',textureName,randi(1000,1));
chartR.set('asset',surfaceName,'name',oName);

parent = chartR.get('asset parent id',oName); 
gName = sprintf('%s_G',oName);
chartR.set('asset',parent,'name',gName);


%% Copy the texture file to the output dir

textureFile = fullfile(piRootPath,'data','imageTextures',imgFile);
outputdir = chartR.get('output dir');
if ~exist(textureFile,'file'), error('No texture file!'); end
if ~exist(outputdir,'dir'), fprintf('Making output dir %s',outputdir); mkdir(outputdir); end
copyfile(textureFile,outputdir);

end

