function recipe = piCreateCheckerboard(outputfile, varargin)

% recipe = piCreateCheckerboard(outputfile, varargin)
%
% This function creates a simple scene with a black and white checkerboard
% pattern that can be used for a variety of camera calibration tasks.
%
% Inputs:
%   outputfile - path to the output PBRT file.
%   numX - number of checkerboard blocks along the X dimension (default 8)
%   numY - number of checkerboard blocks along the y dimension (default 6)
%   dimX - physical dimension of a block along the x dimension, in meters
%   (default 0.1)
%   dimY - physical dimension of a block along the y dimension, in meters
%   (default 0.1)
%
% Returns:
%   recipe - a PBRT scene recipe
%
% HB 2019

p = inputParser;
p.KeepUnmatched = true;
p.addRequired('outputfile',@ischar);
p.addParameter('numX',8,@isnumeric);
p.addParameter('numY',5,@isnumeric);
p.addParameter('dimX',0.1,@isnumeric);
p.addParameter('dimY',0.1,@isnumeric);
p.parse(outputfile, varargin{:});

inputs = p.Results;

recipe = piRead(fullfile(piRootPath,'data','V3','checkerboard','checkerboard.pbrt'));
recipe.set('output file',inputs.outputfile);
piWrite(recipe,'creatematerials',true);
recipe = piRead(inputs.outputfile);

recipe.metadata.numX = inputs.numX;
recipe.metadata.numY = inputs.numY;
recipe.metadata.dimX = inputs.dimX;
recipe.metadata.dimY = inputs.dimY;

totalWidth = inputs.numX * inputs.dimX;
totalHeight = inputs.numY * inputs.dimY;

cornerX = totalWidth * 0.5;
cornerY = totalHeight * 0.5;

% Point coordinates starting from lower left, going counter-clockwise
P = [-cornerX, -cornerY, 0;
    cornerX, -cornerY, 0;
    cornerX, cornerY, 0;
    -cornerX, cornerY, 0]';

%% Update geometry

geometryFile = fullfile(recipe.get('working directory'),recipe.assets.children.output);
fid = fopen(geometryFile,'r');
geometry = textscan(fid,'%s','delimiter','\n');
geometry = geometry{1};
fclose(fid);

fid = fopen(geometryFile,'w');
for i=1:length(geometry)
    if contains(geometry{i},'point P')
        data = sprintf('%f ',P);
        line = sprintf('"point P" [%s]',data);
        geometry{i} = line;
    end
    fprintf(fid,'%s\n',geometry{i});
end
fclose(fid);



%% Update texture dimensions
newTexture = strrep(recipe.materials.txtLines{1},'"float uscale" [8]',sprintf('"float uscale" [%i]',inputs.numX));
newTexture = strrep(newTexture,'"float vscale" [8]',sprintf('"float vscale" [%i]',inputs.numY));
recipe.materials.txtLines{1} = newTexture;

fid = fopen(recipe.materials.outputFile_materials,'w');
for i=1:length(recipe.materials.txtLines)
    fprintf(fid,'%s\n',recipe.materials.txtLines{i});
end
fclose(fid);



end

