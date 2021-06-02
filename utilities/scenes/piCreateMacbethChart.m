function [macbethRecipe] = piCreateMacbethChart(varargin)
% Would be best to integrate other existing MCC routines
%
% TODO: Create some examples to show how to call this function.
%
% [macbethRecipe] = piCreateMacbethChart(varargin)
%
% Create an iset3d scene with a 6x4 Macbeth chart target.
% The target is flat, centered at the origin and aligned with 
% the xy plane, the camera is placed 10m away from the chart.
%
% Input params (all optional)
%    width - the dimension of one Macbeth chart element along the x axis
%    (in meters, default 1)
%    height - the dimension of one Macbeth chart element along the y axis
%    (in meters, default 1)
%    depth - the dimension of one Macbeth chart element along the z axis
%    (in meters, default 1)
%
% Output
%    macbethRecipe - an iset3d scene recipe
%
% Henryk Blasinski, 2020
%

% Examples:
%{
thisR = piCreateMacbethChart;
piWrite(thisR, 'creatematerial', true);
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
%}
p = inputParser;
p.addOptional('width',1);
p.addOptional('height',1);
p.addOptional('depth',1);
p.addOptional('defaultLight',true);
p.parse(varargin{:});
inputs = p.Results;


macbethRecipe = recipe();

camera = piCameraCreate('pinhole');
macbethRecipe.recipeSet('camera',camera);
macbethRecipe.set('fov',45);

macbethRecipe.film.type = 'Film';
macbethRecipe.film.subtype = 'image';
macbethRecipe.set('film resolution',[640 480]);

macbethRecipe.set('from',[0 0 10]);
macbethRecipe.set('to',[0 0 0]);
macbethRecipe.set('up',[0 1 0]);

macbethRecipe.sampler.type = 'Sampler';
macbethRecipe.sampler.subtype = 'halton';
macbethRecipe.set('pixel samples',128);

macbethRecipe.integrator.type = 'Integrator';
macbethRecipe.integrator.subtype = 'directlighting';

macbethRecipe.set('chromatic aberration',true);

macbethRecipe.exporter = 'C4D';

%% Create a cube
dx = inputs.width/2;
dy = inputs.height/2;
dz = inputs.depth/2;

% Vertices of a cube
P = [ dx -dy  dz;
      dx -dy -dz;
      dx  dy -dz;
      dx  dy  dz;
     -dx -dy  dz;
     -dx -dy -dz;
     -dx  dy -dz;
     -dx  dy  dz;];

% Faces of a cube
indices = [4 0 3 
           4 3 7 
           0 1 2 
           0 2 3 
           1 5 6 
           1 6 2 
           5 4 7 
           5 7 6 
           7 3 2 
           7 2 6 
           0 5 1 
           0 4 5]'; 
   
cubeShape.meshshape = 'trianglemesh';
cubeShape.integerindices = ['[', sprintf('%i ',indices), ']'];
cubeShape.pointp = ['[' sprintf('%.3f ',P') ']'];

macbethRecipe.assets = tree();
macbethRecipe.assets.set(1,'root');

macbethChart = piAssetCreate('type','branch');
macbethChart.name = 'MacbethChart';
macbethChart.size.l = 6 * inputs.width;
macbethChart.size.h = 4 * inputs.height;
macbethChart.size.w = inputs.depth;
macbethChart.size.pmin = [-dx; -dy; -dz];
macbethChart.size.pmax = [dx; dy; dz];

[macbethRecipe.assets, macbethChartID] = macbethRecipe.assets.addnode(1,macbethChart);


wave = 400:10:700;
macbethSpectra = ieReadSpectra(which('macbethChart.mat'),wave);


macbethRecipe.materials.list = {};
for x=1:6
    for y=1:4
        
        cubeID = (x-1)*4 + y;
        
        xOffset = -(x - 3 - 1)*inputs.width - inputs.width/2;
        yOffset = -(y - 2 - 1)*inputs.height - inputs.height/2;

        
        macbethCubeBranch = piAssetCreate('type','branch');
        macbethCubeBranch.name = sprintf('Cube_%02i_B',cubeID);
        macbethCubeBranch.size.l = inputs.width;
        macbethCubeBranch.size.h = inputs.height;
        macbethCubeBranch.size.w = inputs.depth;
        macbethCubeBranch.size.pmin = [-dx; -dy; -dz];
        macbethCubeBranch.size.pmax = [dx; dy; dz];
        macbethCubeBranch.translation = [xOffset; yOffset; 0];
        [macbethRecipe.assets, cubeBranchID] = macbethRecipe.assets.addnode(macbethChartID,macbethCubeBranch);
        
        macbethCube = piAssetCreate('type','object');
        macbethCube.name = sprintf('Cube_%02i',cubeID);
        macbethCube.type = 'object';
        macbethCube.material.namedmaterial = sprintf('Cube_%02i_material',cubeID);
        macbethCube.shape = cubeShape;
        macbethCube.mediumInterface = [];        
        macbethRecipe.assets = macbethRecipe.assets.addnode(cubeBranchID,macbethCube);

        
        data = [wave(:), macbethSpectra(:,cubeID)]';
        
        currentMaterial = piMaterialCreate(sprintf('Cube_%02i_material',cubeID),...
            'type','matte','kd',data(:)');
        
        macbethRecipe.materials.list = cat(1, macbethRecipe.materials.list, currentMaterial);
         
    end
end

if inputs.defaultLight

    infiniteLight = piLightCreate('infiniteLight',...
        'type','infinite');
    mabethRecipe.set('light','add',infiniteLight);
    macbethRecipe.set('from',[0 100 1]);
    macbethRecipe.set('to',[0 0 0]);    
end

macbethRecipe.materials.txtLines = {};

outputName = 'MacbethChart';

macbethRecipe.set('outputfile',fullfile(piRootPath,'local','MacbethChart',sprintf('%s.pbrt',outputName)));

world{1} = 'WorldBegin';
world{2} = sprintf('Include "%s_materials.pbrt"',outputName);
world{3} = sprintf('Include "%s_geometry.pbrt"',outputName);
world{4} = sprintf('Include "%s_lights.pbrt"',outputName);
world{5} = 'WorldEnd';

macbethRecipe.world = world;


end

