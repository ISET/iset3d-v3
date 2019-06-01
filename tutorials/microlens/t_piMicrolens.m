%% Read and show a microlens
%
% Requires the isetlens toolbox
%
% See also

microLens = lensC('filename','microlens.2um.Example.json');
microLens.draw

imagingLens = lensC('filename','dgauss.22deg.3.0mm.json');
imagingLens.draw

%% 
%
%   This is the basic command to insert a microlens behind an imaging
%   lens.
%
%   docker run vistalab/pbrt-v3-spectral lenstool insertmicrolens -xdim 64 -ydim 64 dgauss.22deg.3.0mm.json microlens.2um.Example.json combined.json 
%

dockerCommand   = 'docker run -ti --rm';

outputFolder = pwd;
dockerCommand = sprintf('%s --workdir="%s"', dockerCommand, outputFolder);
dockerCommand = sprintf('%s --volume="%s":"%s"', dockerCommand, outputFolder, outputFolder);

dockerImageName = 'vistalab/pbrt-v3-spectral';
imagingLens = 'dgauss.22deg.3.0mm.json';
microLens = 'microlens.2um.Example.json';
combinedLens = 'combinedLens.json';

lensToolCommand = sprintf('lenstool insertmicrolens -xdim 8 -ydim 8 %s %s %s',imagingLens,microLens,combinedLens);

cmd = sprintf('%s %s %s', dockerCommand, dockerImageName, lensToolCommand);
system(cmd)

docker run -ti --rm vistalab/pbrt-v3-spectral lenstool insertmicrolens -xdim 64 -ydim 64 dgauss.22deg.3.0mm.json microlens.2um.Example.json combined.json



