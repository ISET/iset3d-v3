function thisR = piRecipeLoad(fname)
% Load a scene recipe that has been saved in ISET3d directory
%
% Synopsis
%    thisR = piRecipeLoad(fname);
%
% Inputs
%    fname - mat-file that contains 'thisR', this stored recipe
%
% Outputs
%    thisR - the recipe, adjusted to run properly in the user's local
%    environment.
%
%   N.B.  When the recipe files are written out, the inputFile slot can be
%   misleading, because it may have the full path of the user that saved
%   the recipe for the asset.  This is managed by piRecipeLoad, which tries
%   to correct the inputFile and outputFile information to the current
%   user. This means that if you just load the file directly, without going
%   through piRecipeLoad, you will probably have a problem.

% See also
%   piAssetLoad, piRecipeMerge
%

%% Read the recipe file, which should be a mat-file

[p,n,e] = fileparts(fname);
if isempty(e), e = '.mat'; end
fname = fullfile(p,[n,e]);

if ~exist(fname,'file'), error('%s not found',fname); end

% Load the recipe
load(fname,'thisR');

%% Adjust the input slot in the recipe for the local user.  

% The problem is that the file is written out for a specific user.  But
% another user on another system is loading it.  Still, the file should be
% in the ISET3D directory tree.
[~,n,e] = fileparts(thisR.get('input file'));

% Find a file in the user's path that matches the name and extension
inFile = which([n,e]);

if isempty(inFile), error('Cannot find the PBRT input file %s\n',thisR.inputFile); end

thisR.set('input file',inFile);

%% Adjust the input slot in the recipe for the local user

[thePath,n,e] = fileparts(thisR.get('output file'));

% Find the last element of the path
temp = split(thePath,'/');

% The file name for this user should be
outFile=fullfile(piRootPath,'local',temp{end},[n,e]);

thisR.set('output file',outFile);

end
