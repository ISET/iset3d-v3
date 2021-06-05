function thisR = piRecipeDefault(varargin)
% Returns a recipe to an ISET3d standard scene
%
% Syntax
%   thisR = piRecipeDefault(varargin)
%
% Description:
%  piRecipeDefault reads in PBRT scene text files in the data/V3
%  repository.  It is also capable of using ieWebGet to retrieve pbrt
%  scenes, from the web and install them locally.
%
% Inputs
%   N/A  - Default returns the MCC scene
%
% Optional key/val pairs
%   scene name - Specify a PBRT scene name from the data/V3 directory.
%     Here are some names: 
%       MacBethChecker (default)
%       SimpleScene
%       checkerboard
%       slantedBar
%       chessSet
%       chessSetScaled
%       teapot
%       numbers at depth
%
%   write      -  Call piWrite (default is false). Immediately writes into
%                 iset3d/local, without any editing.
%
% Outputs
%   thisR - the ISET3d recipe with information from the PBRT scene file.
%
%
% See also
%  @recipe, recipe.list

% Examples:
%{
 thisR = recipe; thisR.list;
%}
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
   thisR = piRecipeDefault('scene name','checkerboard'); 
   piWrite(thisR);
   scene = piRender(thisR);
   scene = piRender(thisR,'render type','illuminant');
   sceneWindow(scene);
%}
%{
   % #ETTBSkip - Zheng should look at and make fix the issue with the light. 
   thisR = piRecipeDefault('scene name','slantedBar'); 
   piWrite(thisR);
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
   [scene, results] = piRender(thisR);
   sceneWindow(scene);
%}

%%  Figure out the scene and whether you want to write it out

varargin = ieParamFormat(varargin);

p = inputParser;
p.addParameter('scenename','MacBethChecker',@ischar);
p.addParameter('write',false,@islogical);
% p.addParameter('verbose', 2, @isnumeric);

p.parse(varargin{:});

sceneDir = p.Results.scenename;
write     = p.Results.write;
% verbosity = p.Results.verbose;

%%  To read the file,the upper/lower case must be right

% We check based on all lower case, but get the capitalization right by
% assignment in the case
switch ieParamFormat(sceneDir)
    
    case 'macbethchecker'
        sceneDir = 'MacBethChecker';
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'C4D';
    case 'macbethcheckerbox'
        sceneDir = 'MacBethCheckerBox'; 
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'C4D';
    case 'macbethcheckercus'
        sceneDir = 'MacBethCheckerCus';
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'C4D';
    case 'macbethcheckercb'
        sceneDir = 'mccCB';
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'C4D';
        
    case 'whiteboard'
        sceneDir = 'WhiteBoard';        
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'C4D';
    case 'simplescene'
        sceneDir = 'SimpleScene';
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'C4D';
    case 'chessset'
        sceneDir = 'ChessSet';
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'Copy';
    case 'chesssetpieces'
        sceneDir = 'ChessSetPieces';    
        sceneFile = ['ChessSet','.pbrt'];
        exporter = 'C4D';
    case 'chessset_2'
        sceneDir = 'ChessSet_2';
        sceneFile = ['chessSet2','.pbrt'];
        exporter = 'Copy';
    case 'chesssetscaled'
        sceneDir = 'ChessSetScaled';
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'Copy';
        
    case 'checkerboard'
        sceneDir = 'checkerboard';
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'C4D';
    case 'coloredcube'
        sceneDir = 'coloredCube';
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'C4D';
    case 'teapot'
        sceneDir = 'teapot';
        sceneFile = 'teapot-area-light.pbrt';
        exporter = 'Copy';
    case 'slantedbar'
        % In sceneEye cases we were using piCreateSlantedBarScene.  But
        % going forward we will use the Cinema 4D model so we can use the
        % other tools for controlling position, texture, and so forth.
        sceneDir = 'slantedBar';
        sceneFile = 'slantedBar.pbrt';
        exporter = 'C4D';
    case 'slantedbarc4d'
        sceneDir = 'slantedBarC4D';
        sceneFile = 'slantedBarC4D.pbrt';
        exporter = 'C4D';    
    case 'slantedbarasset'
        sceneDir = 'slantedbarAsset';
        sceneFile = 'slantedbarAsset.pbrt';
        exporter = 'C4D';          
    case 'flatsurface'
        sceneDir = 'flatSurface';
        sceneFile = 'flatSurface.pbrt';
        exporter = 'C4D';
    case 'sphere'
        sceneDir = 'sphere';
        sceneFile = 'sphere.pbrt';
        exporter = 'C4D';
    case 'flatsurfacewhitetexture'
        sceneDir = 'flatSurfaceWhiteTexture';
        sceneFile = 'flatSurfaceWhiteTexture.pbrt';
        exporter = 'C4D';
    case 'flatsurfacerandomtexture'
        sceneDir = 'flatSurfaceRandomTexture';
        sceneFile = 'flatSurfaceRandomTexture.pbrt';
        exporter = 'C4D';
    case 'flatsurfacemcctexture'
        sceneDir = 'flatSurfaceMCCTexture';
        sceneFile = 'flatSurfaceMCCTexture.pbrt';
        exporter = 'C4D';
    case 'simplescenelight'
        sceneDir = 'SimpleSceneLight';
        sceneFile = 'SimpleScene.pbrt';
        exporter = 'C4D';
    case 'macbethcheckercuslight'
        sceneDir = 'MacBethCheckerCusLight';
        sceneFile = ['MacBethCheckerCus','.pbrt'];        
        exporter = 'C4D';
    case 'bunny'
        sceneDir = 'bunny';
        sceneFile = ['bunny','.pbrt'];
        exporter = 'C4D';      
    case 'coordinate'
        sceneDir = 'coordinate';
        sceneFile = ['coordinate','.pbrt'];
        exporter = 'C4D';        
    case {'cornellbox', 'cornell_box'}
        sceneDir = 'cornell_box';
        sceneFile = ['cornell_box','.pbrt'];
        exporter = 'C4D';
    case {'cornellboxbunnychart'}
        sceneDir = 'Cornell_BoxBunnyChart';
        sceneFile = ['Cornell_Box_Multiple_Cameras_Bunny_charts','.pbrt'];
        exporter = 'C4D';
    case {'cornellboxreference'}
        sceneDir = 'CornellBoxReference';
        sceneFile = ['CornellBoxReference','.pbrt'];
        exporter = 'C4D';  
    case {'cornellboxlamp'}
        sceneDir = 'CornellBoxLamp';
        sceneFile = ['CornellBoxLamp','.pbrt'];
        exporter = 'C4D';         
    case 'snellenatdepth'
        sceneDir = 'snellenAtDepth';
        sceneFile = ['snellen','.pbrt'];
        exporter = 'Copy';
    case 'numbersatdepth'
        sceneDir = 'NumbersAtDepth';
        sceneFile = ['numbersAtDepth','.pbrt'];
        % mmUnits = true;
        exporter = 'Copy';
    case 'lettersatdepth'
        sceneDir = 'lettersAtDepth';
        sceneFile = [sceneDir,'.pbrt'];        
        exporter = 'C4D';
    case 'bathroom'
        sceneDir = 'bathroom';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case 'classroom'
        sceneDir = 'classroom';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case 'kitchen'
        sceneDir = 'kitchen';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case 'veach-ajar'
        sceneDir = 'veach-ajar';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';    
    case 'villalights'
        sceneDir = 'villaLights';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case 'plantsdusk'
        sceneDir = 'plantsDusk';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case 'livingroom'
        sceneDir = 'living-room';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case 'yeahright'
        sceneDir = 'yeahright';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case 'sanmiguel'
        warning('sanmiguel:  Not rendering correctly yet.')
        sceneDir = 'sanmiguel';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case 'teapotfull'
        sceneDir = 'teapot-full';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case {'whiteroom', 'white-room'}
        sceneDir = 'white-room';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case 'bedroom'
        sceneDir  = 'bedroom';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case 'colorfulscene'
        % djc -- This scene loads but on my machine pbrt gets an error:
        %        "Unexpected token: "string mapname""
        sceneDir = 'ColorfulScene';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case 'livingroom3'
        % Not running
        sceneDir = 'living-room-3';
        sceneFile = 'scene.pbrt';
        exporter = 'Copy';
    case {'livingroom3mini', 'living-room-3-mini'}
        % Not running
        sceneDir = 'living-room-3-mini';
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'Copy';
    case {'blenderscene'}
        sceneDir = 'BlenderScene';
        sceneFile = [sceneDir,'.pbrt'];
        exporter = 'Blender';   % Blender
    otherwise
        error('Can not identify the scene, %s\n',sceneDir);
end

%% See if we can find the file
% Local
if isequal(sceneDir,'BlenderScene')
    FilePath = fullfile(piRootPath,'data','blender','BlenderScene');
else
    FilePath = fullfile(piRootPath,'data','V3',sceneDir);
end

fname = fullfile(FilePath,sceneFile);
if ~exist(fname,'file')
    fname = piSceneWebTest(sceneDir,sceneFile);
end

%% If we are here, we found the file.  So create the recipe.

% Parse the file contents into the ISET3d recipe and identify the type of
% parser.  C4D has special status.  In other cases, such as the scenes from
% the PBRT and Benedikt sites, we just copy the files into ISET3d/local.
switch exporter
    case {'C4D','Copy'}
        thisR = piRead(fname, 'exporter', exporter);
    case 'Blender'
        thisR = piRead_Blender(fname,'exporter',exporter);
    otherwise
        error('Unknown export type %s\n',exporter);
end
thisR.set('exporter',exporter);

% By default, do the rendering and mounting from ISET3d/local.  That
% directory is not part of the git upload area.
% outFile = fullfile(piRootPath,'local',sceneName,[sceneName,'.pbrt'];
[~,n,e] = fileparts(fname);
outFile = fullfile(piRootPath,'local',sceneDir,[n,e]);
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
    fprintf('%s: Using piWrite to save %s in iset3d/local.\n',mfilename, sceneDir);
end

end

function fname = piSceneWebTest(sceneName,sceneFile)
% Check for a web scene

% See if the scene is already in data/V3/web
FilePath = fullfile(piRootPath,'data','V3','web',sceneName);
fname = fullfile(FilePath,sceneFile);

% Download the file to data/V3/web
if ~exist(fname,'file')
    % Download and confirm.
    piWebGet('resourcename', sceneName, 'resourcetype', 'pbrt', 'op', 'fetch', 'unzip', true);
    if ~exist(fname, 'file'), error('File not found'); end
else
    fprintf('File found %s in data/V3/web.\n',sceneName)
end

end

