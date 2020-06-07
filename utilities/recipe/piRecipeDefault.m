function thisR = piRecipeDefault(varargin)
% Helper  function to return a simple recipe for testing
%
% Syntax
%   thisR = piRecipeDefault(varargin)
%
% Inputs
%   N/A  - Default returns the MCC scene
%
% Optional key/val pairs
%   scene name - The PBRT scene name
%     MacBethChecker (default)
%     SimpleScene
%     checkerboard
%     teapot
%
%   write      -  Call piWrite (default is true).  Writes into iset3d/local
%
% Outputs
%   thisR - the recipe
%
% See also
%  recipe

% Examples:
%{
   thisR = piRecipeDefault; piWrite(thisR);
   piWrite(thisR);
   scene = piRender(thisR,'render type','illuminant');
   sceneWindow(scene);
%}
%{
   thisR = piRecipeDefault('scene name','SimpleScene');
   piWrite(thisR); scene = piRender(thisR);
   sceneWindow(scene);
%}
%{
   thisR = piRecipeDefault; piWrite(thisR);
   scene = piRender(thisR,'render type','all');
   sceneWindow(scene);
%}
%{
   thisR = piRecipeDefault('scene name','checkerboard'); piWrite(thisR);
   scene = piRender(thisR);
   scene = piRender(thisR,'render type','illuminant');
   sceneWindow(scene);
%}
%{
   % #ETTB - Zheng should look at and make fix the issue with the light. 
   thisR = piRecipeDefault('scene name','slantedBar'); piWrite(thisR);
   scene = piRender(thisR);
   scene = piRender(thisR,'render type','radiance');
   sceneWindow(scene);
%}
%{
   thisR = piRecipeDefault('scene name','chessSet');
   piWrite(thisR); 
   scene = piRender(thisR, 'render type', 'radiance');
   sceneWindow(scene);
%}

%%  Figure out the scene and whether you want to write it out

varargin = ieParamFormat(varargin);

p = inputParser;
p.addParameter('scenename','MacBethChecker',@ischar);
p.addParameter('write',false,@islogical);
p.parse(varargin{:});

sceneName = p.Results.scenename;
write     = p.Results.write;

%%
switch sceneName
    
    case 'MacBethChecker'
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'MacBethCheckerBox'
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'MacBethCheckerCus'
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'SimpleScene'
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'chessSet'
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'Copy';
    case 'chessSetScaled'
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'Copy';
    case 'checkerboard'
        FilePath = fullfile(piRootPath,'data','V3','checkerboard');
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'teapot'
        FilePath = fullfile(piRootPath,'data','V3','teapot');
        fname = fullfile(FilePath,'teapot-area-light.pbrt');
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'Unknown';
    case 'slantedBar'
        FilePath = fullfile(piRootPath,'data','V3','slantedBar');
        fname = fullfile(FilePath,'slantedBar.pbrt');
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'flatSurface'
        FilePath = fullfile(piRootPath,'data','V3','flatSurface');
        fname = fullfile(FilePath,'flatSurface.pbrt');
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'sphere'
        FilePath = fullfile(piRootPath,'data','V3','sphere');
        fname = fullfile(FilePath,'sphere.pbrt');
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'flatSurfaceWhiteTexture'
        FilePath = fullfile(piRootPath,'data','V3','flatSurfaceWhiteTexture');
        fname = fullfile(FilePath,'flatSurfaceWhiteTexture.pbrt');
        if ~exist(fname,'file'), error('File not found'); end
    case 'flatSurfaceRandomTexture'
        FilePath = fullfile(piRootPath,'data','V3','flatSurfaceRandomTexture');
        fname = fullfile(FilePath,'flatSurfaceRandomTexture.pbrt');
        if ~exist(fname,'file'), error('File not found'); end
    case 'flatSurfaceMCCTexture'
        FilePath = fullfile(piRootPath,'data','V3','flatSurfaceMCCTexture');
        fname = fullfile(FilePath,'flatSurfaceMCCTexture.pbrt');
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'SimpleSceneLight'
        FilePath = fullfile(piRootPath,'data','V3','SimpleSceneLight');
        fname = fullfile(FilePath,'SimpleScene.pbrt');
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'MacBethCheckerCusLight'
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['MacBethCheckerCus','.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    otherwise
        error('Can not identify the scene, %s\n',sceneName);
end

%% Got the file, create the recipe

thisR = piRead(fname);
thisR.set('exporter',exporter);

outFile = fullfile(piRootPath,'local',sceneName,[sceneName,'.pbrt']);
thisR.set('outputfile',outFile);

% Set defaults for very low resolution, for testing
thisR.integrator.subtype = 'path';
thisR.set('pixelsamples', 16);
thisR.set('filmresolution', [320, 180]);

%% Save the recipe for the user
if write
    piWrite(thisR);
    fprintf('Recipe is written in iset3d/local.\n');
end

end


