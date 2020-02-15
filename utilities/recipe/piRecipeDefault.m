function thisR = piRecipeDefault(sceneName)
% Helper  function to return a simple recipe for testing
%
% Syntax
%   thisR = piRecipeDefault(sceneName)
%
% Inputs
%   sceneName - The PBRT scene
%     Currently only MacBethChecker (default) and SimpleScene
%
% Optional key/val pairs
%   N/A
%
% Outputs
%   thisR - the recipe
%
% See also
%  recipe

% Examples:
%{
   thisR = piRecipeDefault;
   scene = piRender(thisR,'render type','illuminant');
   sceneWindow(scene);
%}
%{
   thisR = piRecipeDefault('SimpleScene');
   scene = piRender(thisR);
   sceneWindow(scene); sceneSet(scene,'gamma',0.5);
%}
%{
   % Still does not work.
   thisR = piRecipeDefault;
   scene = piRender(thisR,'render type','all');
   sceneWindow(scene);
%}
%{
   thisR = piRecipeDefault('SimpleScene');
   scene = piRender(thisR);
   scene = piRender(thisR,'render type','illuminant only');
%}

%%
if ieNotDefined('sceneName'), sceneName = 'MacBethChecker'; end

%%
switch sceneName
    
    case 'MacBethChecker'
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end

    case 'SimpleScene'
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
    otherwise
        error('Can not identify the scene, %s\n',sceneName);
end

%% Got the file, create the recipe

thisR = piRead(fname);
outFile = fullfile(piRootPath,'local',sceneName,[sceneName,'.pbrt']);
thisR.set('outputfile',outFile);

% Set for very low resolution, for testing
thisR.integrator.subtype = 'path';
thisR.set('pixelsamples', 16);
thisR.set('filmresolution', [320, 180]);

%% Save the recipe for the user
piWrite(thisR);
fprintf('Recipe is written in iset3d/local.\n');

end


