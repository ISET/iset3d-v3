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
p.parse(varargin{:});
inputs = p.Results;


macbethRecipe = recipe();

macbethRecipe.camera.type = 'Camera';
macbethRecipe.set('Camera type','perspective');
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
     
shape = 'Shape "trianglemesh" "integer indices"';
indStr = sprintf('%i ',indices);
pointStr = sprintf('%.3f ',P');
cubeShape = sprintf('%s [%s] "point P" [%s]\n', shape, indStr, pointStr); 
      
macbethRecipe.assets.name = 'root';
macbethRecipe.assets.scale = [1; 1; 1];
macbethRecipe.assets.rotate = [ 0 0 0; 0 0 1; 0 1 0; 1 0 0];
macbethRecipe.assets.position = [0, 0, 0];
macbethRecipe.assets.groupobjs = [];
macbethRecipe.assets.children = [];
macbethRecipe.assets.size.l = 6 * inputs.width;
macbethRecipe.assets.size.h = 4 * inputs.height;
macbethRecipe.assets.size.w = inputs.depth;
macbethRecipe.assets.size.pmin = [-dx; -dy; -dz];
macbethRecipe.assets.size.pmax = [dx; dy; dz];

wave = 400:10:700;
macbethSpectra = ieReadSpectra(which('macbethChart.mat'),wave);

for x=1:6
    for y=1:4
        
        cubeID = (x-1)*4 + y;
        
        xOffset = -(x - 3 - 1)*inputs.width - inputs.width/2;
        yOffset = -(y - 2 - 1)*inputs.height - inputs.height/2;

        newAsset.groupobjs = [];
        newAsset.size.l = inputs.width;
        newAsset.size.h = inputs.height;
        newAsset.size.w = inputs.depth;
        newAsset.size.pmin = [-dx; -dy; -dz];
        newAsset.size.pmax = [dx; dy; dz];
        newAsset.scale = [1; 1; 1];
        newAsset.name = sprintf('Cube_%02i',cubeID);
        newAsset.rotate = [ 0 0 0; 0 0 1; 0 1 0; 1 0 0];
        newAsset.position = [xOffset; yOffset; 0];
        newAsset.children.name = sprintf('Cube_%02i',cubeID);
        newAsset.children.index  = [];
        newAsset.children.mediumInterface = [];
        newAsset.children.material = sprintf('NamedMaterial "Cube_%02i_material"',cubeID);
        newAsset.children.areaLight = [];
        newAsset.children.output = [];
        newAsset.children.light = [];
        newAsset.children.shape = cubeShape;

        macbethRecipe.assets.groupobjs = cat(1,macbethRecipe.assets.groupobjs,newAsset);
        
        
        currentMaterial = piMaterialCreate();
        currentMaterial.name = sprintf('Cube_%02i_material',cubeID);
        currentMaterial.string = 'matte';
        
        data = [wave(:), macbethSpectra(:,cubeID)]';
        currentMaterial.spectrumkd = data(:);
        
        macbethRecipe.materials.list.(currentMaterial.name) = currentMaterial;
    end
end
macbethRecipe.materials.txtLines = {};

outputName = 'MacbethChart';

macbethRecipe.set('outputfile',fullfile(piRootPath,'local','MacbethChart',sprintf('%s.pbrt',outputName)));

world{1} = 'WorldBegin';
world{2} = 'LightSource "distant" "point from" [1 1 1] "point to" [0 0 0]';
world{3} = sprintf('Include "%s_materials.pbrt"',outputName);
world{4} = sprintf('Include "%s_geometry.pbrt"',outputName);
world{5} = 'WorldEnd';

macbethRecipe.world = world;


end

