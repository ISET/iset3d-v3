function combinedLens  = piCameraInsertMicrolens(microLens,imagingLens,varargin)
% Create a file that inserts a microlens behind an imaging lens.
%
% Syntax
%   combinedLens  = piCameraInsertMicrolens(microLens,imagingLens,varargin)
%
% Inputs
%    microLens:    File name
%    imagingLens:  File name
%
% Optional key/value pairs
%   output name:   File name of the output combined lens
%
% Output
%   combinedLens - Full path to the output file
%
% Description
%
% The docker command to merge an imaging lens description with a
% microlens description is:
%
%   docker run vistalab/pbrt-v3-spectral lenstool insertmicrolens ...
%       -xdim 64 -ydim 64 ...
%          dgauss.22deg.3.0mm.json microlens.2um.Example.json combined.json 
%
% There are other parameters, defined here
%
% usage: lenstool <command> [options] <filenames...>
%
% commands: convert insertmicrolens
%
%convert options:
%    --inputscale <n>    Input units per mm (which are used in the output). Default: 1.0
%    --implicitdefaults  Omit fields from the json file if they match the defaults.
%
% insertmicrolens options:
%    --xdim <n>             How many microlenses span the X direction. Default: 16
%    --ydim <n>             How many microlenses span the Y direction. Default: 16
%    --filmwidth <n>        Width of target film in mm. Default: 20.0
%    --filmheight <n>       Height of target film in mm. Default: 20.0
%    --filmtolens <n>       Distance from film to back of main lens system (in mm). Default: 50.0
%    --filmtomicrolens <n>  Distance from film to back of microlens. Default: 0.0 
%
% See also
%

% Example:
%{
chdir(fullfile(isetRootPath,'local'));
microLensName   = 'microlens.2um.Example.json';
imagingLensName = 'dgauss.22deg.3.0mm.json';
combinedLens = piCameraInsertMicrolens(microLensName,imagingLensName);
edit(combinedLens);
%}
%{
chdir(fullfile(isetRootPath));
microLensName   = 'microlens.2um.Example.json';
imagingLensName = 'dgauss.22deg.3.0mm.json';
combinedLens = fullfile(isetRootPath,'local','combinedLens.json');
combinedLens = piCameraInsertMicrolens(microLensName,imagingLensName,'output name',combinedLens);

edit(combinedLens);
%}

%% Parse inputs

varargin = ieParamFormat(varargin);

p = inputParser;

vFile = @(x)(exist(x,'file'));
p.addRequired('imagingLens',vFile);
p.addRequired('microLens',vFile);

p.addParameter('outputname','',@ischar);

p.parse(imagingLens,microLens,varargin{:});

% This should be a full path
if isempty(p.Results.outputname)
    combinedLens = fullfile(pwd,sprintf('%s+%s',imagingLens,microLens));
else
    combinedLens = p.Results.outputname;
end


%% Remember where you started 

% Basic docker command
dockerCommand   = 'docker run -ti --rm';

% Where you want stuff to run
outputFolder = fileparts(combinedLens);
dockerCommand = sprintf('%s --workdir="%s"', dockerCommand, outputFolder);
dockerCommand = sprintf('%s --volume="%s":"%s"', dockerCommand, outputFolder, outputFolder);

% What you want to run
dockerImageName = 'vistalab/pbrt-v3-spectral';

%% Copy the imaging and microlens to the output folder

iLensFullPath = which(imagingLens);
[~,n,e] = fileparts(iLensFullPath);
iLensCopy = fullfile(outputFolder,[n e]);
if ~exist(iLensCopy,'file')
    copyfile(iLensFullPath,iLensCopy)
else
    disp('Imaging lens copy exists.  Not over-writing');
end

mLensFullPath = which(microLens);
[~,n,e] = fileparts(mLensFullPath);
mLensCopy = fullfile(outputFolder,[n e]);
if ~exist(mLensCopy,'file')
    copyfile(mLensFullPath,mLensCopy)
else
    disp('Microlens copy exists.  Not over-writing');
end

%% Set up the lens tool command to run

lensToolCommand = sprintf('lenstool insertmicrolens -xdim 8 -ydim 8 %s %s %s',imagingLens,microLens,combinedLens);

cmd = sprintf('%s %s %s', dockerCommand, dockerImageName, lensToolCommand);
fprintf('Mounting folder %s\n',outputFolder);

status = system(cmd);
if status
    error('Docker command problem');
end


end