function [recipeName, targetName, acq] = piFWSceneGetJSON(st,luString)
% Download the two JSON files from a scene acquisition on Flywheel
%
% Synopsis
%    [recipeName, targetName, acq] = piFWSceneGetJSON(st,luString)
%
% Inputs:
%   st  - scitran object
%   luString  - Lookup string to find the acquisition.  The format is
%                  group/project/subject/session/acquisition
%
% Optional key/value pairs
%  N/A
%
% Returns
%  recipeName - Full path to local recipe json file
%  targetName - Full path to local target json file
%  acquisition - Flywheel container of the acquisition
%
% See also
%

%% Do some checking here

% p = inputParser;


%%
acq = st.lookup(luString);
if isempty(acq), error('Could not find %s\n',luString); end

%% Now we find the files we need to render the scene

% We find all the files in the acquisition this way
files = acq.files;
% stPrint(files,'name');

jsonFiles = stSelect(files,'name','json');
if numel(jsonFiles) ~= 2
    error('Problem identifying scene JSON files');
end

if piContains(jsonFiles{1}.name,'target')
    targetFile = jsonFiles{1};
    recipeFile = jsonFiles{2};
else
    targetFile = jsonFiles{2};
    recipeFile = jsonFiles{1};
end

% Create a folder in ISET3d where we download the target and recipe
% files.
destDir = fullfile(piRootPath,'local',date,acq.label);
if ~exist(destDir,'dir'), mkdir(destDir); end

targetName = fullfile(destDir,targetFile.name);
targetFile.download(targetName);
if ~exist(targetName,'file'), error('Target file not downloaded'); end

%% Load the rendering recipe

% The scene recipe with all the graphics information is stored here
% as a recipe

% This looks wrong
recipeName = fullfile(destDir,recipeFile.name);
recipeFile.download(recipeName);
if ~exist(recipeName,'file'), error('Recipe file not downloaded'); end

end
