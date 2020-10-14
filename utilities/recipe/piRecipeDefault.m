function thisR = piRecipeDefault(varargin)
% Returns a recipe to one of our standard scenes.
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
%     slantedBar
%     chessSet
%     chessSetScaled
%     teapot
%     numbers at depth
%
%   write      -  Call piWrite (default is true).  Writes into iset3d/local
%
% Outputs
%   thisR - the recipe
%
% Description:
%  Mainly this function reads in scenes that are already in the data/V3
%  repository within ISET3D.  Heavy users sometimes add additional scenes
%  into that directory.
%
%  This is an ISETBio way, based on the RDT, to retrieve scenes into
%  iset3d/local from the RDT. If you do that, you may wish to store the
%  retrieved data in your own data/V3.
%
%  scenePath = fullfile(piRootPath, 'local', 'scenes', 'snellenAtDepth', 'snellen.pbrt');
%  sceneUnits = 'm';
%  pullSceneFromRDT('snellenAtDepth', scenePath);
%
% See also
%  @recipe, recipe.list

% Examples:
%{
   thisR = piRecipeDefault; piWrite(thisR);
   piWrite(thisR);
   scene = piRender(thisR,'render type','illuminant');
   sceneWindow(scene);
%}
%{
   thisR = piRecipeDefault('scene name','SimpleScene');
   piWrite(thisR); 
   scene = piRender(thisR);
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
   % #ETTBSkip - Zheng should look at and make fix the issue with the light. 
   thisR = piRecipeDefault('scene name','slantedBar'); piWrite(thisR);
   scene = piRender(thisR,'render type','radiance');
   scene = sceneSet(scene,'mean luminance',100);
   sceneWindow(scene);
%}
%{
   thisR = piRecipeDefault('scene name','chessSet');
   piWrite(thisR); 
   scene = piRender(thisR, 'render type', 'both');
   sceneWindow(scene);
%}

%{
   thisR = piRecipeDefault('scene name','teapot');
   piWrite(thisR); 
   scene = piRender(thisR);
   sceneWindow(scene);
%}
%{
   thisR = piRecipeDefault('scene name','MacBeth Checker CusLight');
   piWrite(thisR); 
   scene = piRender(thisR);
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

%%  To read the file,the upper/lower case must be right

% We check based on all lower case, but get the capitalization right by
% assignment in the case
switch ieParamFormat(sceneName)
    
    case 'macbethchecker'
        sceneName = 'MacBethChecker';
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'macbethcheckerbox'
        sceneName = 'MacBethCheckerBox';
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'macbethcheckercus'
        sceneName = 'MacBethCheckerCus';
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'simplescene'
        sceneName = 'SimpleScene';
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'chessset'
        sceneName = 'chessSet';
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    case 'chesssetscaled'
        sceneName = 'chessSetScaled';
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    case 'checkerboard'
        sceneName = 'checkerboard';
        FilePath = fullfile(piRootPath,'data','V3','checkerboard');
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'coloredcube'
        sceneName = 'coloredCube';
        FilePath = fullfile(piRootPath,'data','V3','coloredCube');
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'teapot'
        sceneName = 'teapot';
        FilePath = fullfile(piRootPath,'data','V3','teapot');
        fname = fullfile(FilePath,'teapot-area-light.pbrt');
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'Unknown';
    case 'slantedbar'
        % In sceneEye cases we were using piCreateSlantedBarScene.  But
        % going forward we will use the Cinema 4D model so we can use the
        % other tools for controlling position, texture, and so forth.
        sceneName = 'slantedBar';
        FilePath = fullfile(piRootPath,'data','V3','slantedBar');
        fname = fullfile(FilePath,'slantedBar.pbrt');
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'flatsurface'
        sceneName = 'flatSurface';
        FilePath = fullfile(piRootPath,'data','V3','flatSurface');
        fname = fullfile(FilePath,'flatSurface.pbrt');
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'sphere'
        sceneName = 'sphere';
        FilePath = fullfile(piRootPath,'data','V3','sphere');
        fname = fullfile(FilePath,'sphere.pbrt');
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'C4D';
    case 'flatsurfacewhitetexture'
        sceneName = 'flatSurfaceWhiteTexture';
        FilePath = fullfile(piRootPath,'data','V3','flatSurfaceWhiteTexture');
        fname = fullfile(FilePath,'flatSurfaceWhiteTexture.pbrt');
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'flatsurfacerandomtexture'
        sceneName = 'flatSurfaceRandomTexture';
        FilePath = fullfile(piRootPath,'data','V3','flatSurfaceRandomTexture');
        fname = fullfile(FilePath,'flatSurfaceRandomTexture.pbrt');
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'flatsurfacemcctexture'
        sceneName = 'flatSurfaceMCCTexture';
        FilePath = fullfile(piRootPath,'data','V3','flatSurfaceMCCTexture');
        fname = fullfile(FilePath,'flatSurfaceMCCTexture.pbrt');
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'simplescenelight'
        sceneName = 'SimpleSceneLight';
        FilePath = fullfile(piRootPath,'data','V3','SimpleSceneLight');
        fname = fullfile(FilePath,'SimpleScene.pbrt');
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'macbethcheckercuslight'
        sceneName = 'MacBethCheckerCusLight';
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['MacBethCheckerCus','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'cornellbox'
        sceneName = 'cornell_box';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['cornell_box','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'snellenatdepth'
        sceneName = 'snellenAtDepth';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['snellen','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    case 'numbersatdepth'
        sceneName = 'NumbersAtDepth';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['numbersAtDepth','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'lettersatdepth'
        sceneName = 'lettersAtDepth';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['lettersAtDepth','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'C4D';
    case 'bathroom'
        sceneName = 'bathroom';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['bathroom','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    case 'classroom'
        sceneName = 'classroom';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['scene','.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'Copy';
    case 'kitchen'
        sceneName = 'kitchen';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['scene','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    case 'plantsdusk'
        sceneName = 'plantsDusk';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['plantsDusk','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    case 'livingroom'
        sceneName = 'living-room';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['scene','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    case 'yeahright'
        sceneName = 'yeahright';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['yeahright','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    case 'sanmiguel'
        warning('sanmiguel:  Not rendering correctly yet.')
        sceneName = 'sanmiguel';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['sanmiguel','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    case 'teapotfull'
        sceneName = 'teapot-full';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['scene','.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
        exporter = 'Copy';
    case 'whiteroom'
        sceneName = 'white-room';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['scene','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    case 'bedroom'
        sceneName = 'bedroom';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['scene','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    case 'livingroom3'
        % Not running
        sceneName = 'living-room-3';
        % Local
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,['scene','.pbrt']);
        if ~exist(fname,'file')
            ieWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
            if ~exist(fname, 'file'), error('File not found'); end
        end
        exporter = 'Copy';
    otherwise
        error('Can not identify the scene, %s\n',sceneName);
end

%% Got the file, create the recipe

% Parse the file contents into the ISET3d recipe and identify the type of
% parser.  C4D has special status.  In other cases, such as the scenes from
% the PBRT and Benedikt sites, we just copy the files into ISET3d/local.
thisR = piRead(fname);
thisR.set('exporter',exporter);

% By default, do the rendering and mounting from ISET3d/local.  That
% directory is not part of the git upload area.
% outFile = fullfile(piRootPath,'local',sceneName,[sceneName,'.pbrt']);
[~,n,e] = fileparts(fname);
outFile = fullfile(piRootPath,'local',sceneName,[n,e]);
thisR.set('outputfile',outFile);

% Set defaults for very low resolution (for testing)
thisR.integrator.subtype = 'path';
thisR.set('pixelsamples', 32);
thisR.set('filmresolution', [320, 320]);

% If no camera was included, add a pinhole by default.
if isempty(thisR.get('camera'))
    thisR.set('camera',piCameraCreate('pinhole'));
end

%% If requested, write the files now

% Usually, however, we edit the recipe before writing and rendering.
if write
    piWrite(thisR);
    fprintf('%s: Using piWrite to save %s in iset3d/local.\n',mfilename, sceneName);
end

end


