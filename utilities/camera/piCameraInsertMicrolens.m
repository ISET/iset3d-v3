function [combinedLens, cmd]  = piCameraInsertMicrolens(microLens,imagingLens,varargin)
% Combine a microlens with an imaging lens into a lens file
%
% Syntax
%   combinedLens  = piCameraInsertMicrolens(microLens,imagingLens,varargin)
%
% Brief description:
%   When the microlens is included in the lens file, PBRT-V3-SPECTRAL
%   includes the microlens into the ray tracing calculation.
%   
% Inputs
%    microLens:    File name
%    imagingLens:  File name
%
% Optional key/value pairs
%   output name:   File name of the output combined lens
%
% Default parameters - not always useful.  Should create a routine to
% generate default parameters
%   xdim    - N microlens in xdim  (64)
%   ydim    - N microlens in ydim  (64)
%   filmwidth   -   4 microns for each of the 3 superpixels behind the
%                   microlens; 84 superpixels, 84 * 12 (um) ~ 1 mm
%   filmheight  -  
%   microlenstofilm - 0 micron, but just guessing here.  Not sure
%                     about units either, but 0 works for all of them.
%                     Maybe we should make this the focal length of the
%                     microlens?
%
% Output
%   combinedLens - Full path to the output file
%   cmd  - Full docker command that was built
%
% Description
%
% The docker command that merges an imaging lens description into a
% microlens description is 'lenstool'.  It is embedded in the docker
% container and can be invoked this way
%
%   docker run vistalab/pbrt-v3-spectral lenstool insertmicrolens ...
%       -xdim 64 -ydim 64 ...
%        dgauss.22deg.3.0mm.json microlens.2um.Example.json combined.json 
%
% There are other 'lenstool' options defined here
%
%   usage: lenstool <command> [options] <filenames...>
%
%      commands: convert insertmicrolens
%
%convert options:
%    --inputscale <n>    Input units per mm (which are used in the output). Default: 1.0
%    --implicitdefaults  Omit fields from the json file if they match the defaults.
%
% insertmicrolens options:
%    --xdim <n>             How many microlenses span the X direction. Default: 16
%    --ydim <n>             How many microlenses span the Y direction. Default: 16
%    --filmwidth <n>        Width of target film  (mm). Default: 20.0
%    --filmheight <n>       Height of target film (mm). Default: 20.0
%    --filmtolens <n>       Distance (mm) from film to back of main lens system . Default: 50.0
%    --filmtomicrolens <n>  Distance (mm) from film to back of microlens. Default: 0.0 
%
% See also
%

% Examples:
%{
 chdir(fullfile(piRootPath,'local','microlens'));
 microLensName   = 'microlens.json';
 imagingLensName = 'dgauss.22deg.3.0mm.json';
 combinedLens = piCameraInsertMicrolens(microLensName,imagingLensName);
 thisLens = jsonread(combinedLens);
%}
%{
 chdir(fullfile(piRootPath,'local','microlens'));
 microLens   = lensC('filename','microlens.json');
 imagingLens = lensC('filename','dgauss.22deg.3.0mm.json');
 combinedLens = piCameraInsertMicrolens(microLens,imagingLens);

 thisLens = jsonread(combinedLens);
%}

%% Programming TODO
%
%   The filmheight and filmwidth seem to have an error when less than 1.
%   Checking with Mike Mara.
%

%% Parse inputs

varargin = ieParamFormat(varargin);

p = inputParser;

% Input can be the filename of the lens or the lens object
vFile = @(x)(isa(x,'lensC') || (ischar(x) && exist(x,'file')));
p.addRequired('imagingLens',vFile);
p.addRequired('microLens',vFile);

p.addParameter('outputname','',@ischar);

p.addParameter('xdim',[],@isscalar);
p.addParameter('ydim',[],@isscalar);
p.addParameter('filmheight',1,@isscalar);
p.addParameter('filmwidth',1,@isscalar);
p.addParameter('microlenstofilm',[],@isscalar);

p.parse(imagingLens,microLens,varargin{:});

% If a lensC was input, the lensC might have been modified from the
% original fullFileName. So we write out a local copy of the json file.
if isa(imagingLens,'lensC')
    thisName = [imagingLens.name,'.json']; 
    imagingLens.fileWrite(thisName);
    imagingLens = fullfile(pwd,thisName);
end

if isa(microLens,'lensC')
    mlObj = microLens;
    thisName = [microLens.name,'.json'];
    microLens.fileWrite(thisName);
    microLens = fullfile(pwd,thisName);
end

if isempty(p.Results.outputname)
    [~,imagingName,~]   = fileparts(imagingLens);
    [~,microLensName,e] = fileparts(microLens); 
    combinedLens = fullfile(pwd,sprintf('%s+%s',imagingName,[microLensName,e]));
else
    combinedLens = p.Results.outputname;
end

%%
filmheight = ceil(p.Results.filmheight);
filmwidth  = ceil(p.Results.filmwidth);

% If the user did not specify  xdim and ydim, set up the number of
% microlenses so that the film is tiled based on the lens height.
xdim = p.Results.xdim;
ydim = p.Results.ydim;
if isempty(xdim), xdim =  floor((filmheight/mlObj.get('lens height'))); end
if isempty(ydim), ydim =  floor((filmwidth/mlObj.get('lens height'))); end

microlenstofilm = p.Results.microlenstofilm;
if isempty(microlenstofilm)
    microlenstofilm = lensFocus(microLens,1e6);
end

%% Print out parameter summary
fprintf('\n------\nMicrolens insertion summary\n');
fprintf('Microlens dimensions %d %d \n',xdim,ydim);
fprintf('Microlens to film distance %f\n',microlenstofilm);
fprintf('Film height and width %f %f\n',filmheight,filmwidth);
fprintf('------\n');

%% Remember where you started 

% Basic docker command
dockerCommand   = 'docker run -ti --rm';

% Where you want the output file
outputFolder  = pwd;
dockerCommand = sprintf('%s --workdir="%s"', dockerCommand, pathToLinux(outputFolder));
dockerCommand = sprintf('%s --volume="%s":"%s"', dockerCommand, outputFolder, pathToLinux(outputFolder));

% What you want to run
dockerImageName = 'vistalab/pbrt-v3-spectral:latest';

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

% Need to add the other parameters
lensToolCommand = sprintf('lenstool insertmicrolens -xdim %d -ydim %d -filmheight %f -filmwidth %f %s %s %s',...
    xdim,ydim,filmheight,filmwidth,imagingLens,microLens,combinedLens);

cmd = sprintf('%s %s %s', dockerCommand, dockerImageName, lensToolCommand);
fprintf('Mounting folder %s\n',outputFolder);

status = system(cmd);
if status
    error('Docker command problem: %s\n',cmd);
end

%%  Check the JSON file
% edit(combinedLens)

% To set the distance between the microlens and the film, you must adjust a
% parameter in the OMNI camera.  Talk to TL about that!

end