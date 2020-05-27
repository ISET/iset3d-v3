function thisR = piCreateCheckerboard(varargin)
% TODO: This is broken, we should fix it.
%
% thisR = piCreateCheckerboard(outputfile, varargin)
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
%   thisR - a PBRT scene thisR
%
% HB 2019

%%
p = inputParser;
p.KeepUnmatched = true;
p.addParameter('numX',8,@isnumeric);
p.addParameter('numY',5,@isnumeric);
p.addParameter('dimX',0.1,@isnumeric);
p.addParameter('dimY',0.1,@isnumeric);
p.parse(varargin{:});

inputs = p.Results;

%% Read in the base checkerboard file and set metadata

thisR = piRecipeDefault('scene name','checkerboard');

thisR.metadata.numX = p.Results.numX;
thisR.metadata.numY = p.Results.numY;
thisR.metadata.dimX = p.Results.dimX;
thisR.metadata.dimY = p.Results.dimY;

totalWidth  = p.Results.numX * p.Results.dimX;
totalHeight = p.Results.numY * p.Results.dimY;

cornerX = totalWidth * 0.5;
cornerY = totalHeight * 0.5;

% Point coordinates starting from lower left, going counter-clockwise
P = [-cornerX, -cornerY, 0;
    cornerX, -cornerY, 0;
    cornerX, cornerY, 0;
    -cornerX, cornerY, 0]';

%%
piWrite(thisR,'creatematerials',true);

%% Update geometry

% geometryFile = fullfile(thisR.get('working directory'),thisR.assets.groupobjs(1).children.output);
geometryFile = fullfile(thisR.get('working directory'),'checkerboard_geometry.pbrt');

if ~exist(geometryFile,'file'), error('No geometry file'); end

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
newTexture = strrep(thisR.materials.txtLines{1},'"float uscale" [8]',sprintf('"float uscale" [%i]',inputs.numX));
newTexture = strrep(newTexture,'"float vscale" [8]',sprintf('"float vscale" [%i]',inputs.numY));
thisR.materials.txtLines{1} = newTexture;

materialFile = fullfile(thisR.get('working directory'),'checkerboard_materials.pbrt');
if ~exist(materialFile,'file'), error('No material file'); end

fid = fopen(thisR.materials.outputFile_materials,'w');
for i=1:length(thisR.materials.txtLines)
    fprintf(fid,'%s\n',thisR.materials.txtLines{i});
end
fclose(fid);

end

