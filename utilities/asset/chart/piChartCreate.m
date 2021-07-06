function [chartR, gName, oName]  = piChartCreate(chartName)
% Create a small calibration chart to insert in a scene
%
% Synopsis
%  [chartR, sName] = piChartCreate(chartName)
%
% Input
%   chartName - 'EIA','rings rays','slanted bar','grid lines',
%               'face','macbeth'
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
%{
thisChart = piChartCreate('macbeth');
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

uniqueKey = randi(1e4,1);

switch ieParamFormat(chartName)
    case 'eia'        
        textureName = sprintf('EIAChart-%d',uniqueKey);
        imgFile   = 'EIA1956-300dpi-center.png';
        
    case 'slantedbar'        
        textureName = sprintf('slantedbar-%d',uniqueKey);
        imgFile   = 'slantedbar.png';
        
    case 'ringsrays'
        textureName = sprintf('ringsrays-%d',uniqueKey);
        imgFile   = 'ringsrays.png';
        
    case 'gridlines'
        textureName = sprintf('gridlines-%d',uniqueKey);
        imgFile = 'gridlines.png';
        
    case 'macbeth'
        textureName = sprintf('macbeth-%d',uniqueKey);
        imgFile = 'macbeth.png';
        
        % Make the surface shape match the MCC shape
        piAssetSet(chartR, geometryNode.name, 'scale',wscale.*[1 4/6 1]);

    case 'face'
        textureName = sprintf('face-%d',uniqueKey);
        imgFile = 'monochromeFace.png';
        
    otherwise
        error('Unknown chart name %s\n',chartName);
end

%% Make a chart material and texture

% Create a new material and add it to the recipe
surfaceMaterial = piMaterialCreate(textureName,'type','Matte');
chartR.set('material','add',surfaceMaterial);

% Create a new texture and add it to the recipe
chartTexture = piTextureCreate(textureName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', imgFile);
chartR.set('texture', 'add', chartTexture);

% Specify the texture as part of the material
chartR.set('material', surfaceMaterial.name, 'kd val', textureName);

% chartR.get('material print');
% chartR.show('objects');

%% Name the object and geometry node
oName = textureName;
chartR.set('asset',surfaceName,'name',oName);

% Specify the chart as having this material
chartR.set('asset',oName,'material name',surfaceMaterial.name);

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

