function thisR = piRead(fname,varargin)
% Read an parse a PBRT scene file, returning a rendering recipe
%
% Syntax
%    thisR = piRead(fname, varargin)
%
% Description
%  piREAD parses a pbrt scene file and returns the full set of rendering
%  information in the slots of the "recipe" object. The recipe object
%  contains all the information used by PBRT to render the scene.
%
%  We extract blocks with these names from the text prior to WorldBegin
%
%    Camera, Sampler, Film, PixelFilter, SurfaceIntegrator (V2, or
%    Integrator in V3), Renderer, LookAt, Transform, ConcatTransform,
%    Scale
%
%  After creating the recipe from piRead, we modify the recipe
%  programmatically.  The modified recipe is then used to write out the
%  PBRT file (piWrite).  These PBRT files are rendered using piRender,
%  which executes the PBRT docker image and return an ISETCam scene or oi
%  format).  
%
%  We also have routines to execute these functions at scale in Google
%  Cloud (see isetcloud).
%
% Required inputs
%   fname - a full path to a pbrt scene file
%
% Optional parameter/values
%   'read materials' - When PBRT scene file is exported by cinema4d,
%        the exporterflag is set and we read the materials file.  If
%        you do not want to read that file, set this to false.
%
% Return
%   recipe - A recipe object with the parameters needed to write a new pbrt
%            scene file
%
% Assumptions:  piRead assumes that
%
%     * There is a block of text before WorldBegin and no more text after 
%     * Comments (indicated by '#' in the first character) and blank lines
%        are ignored.
%     * When a block is encountered, the text lines that follow beginning
%       with a '"' are included in the block. 
%    
%  piRead will not work with PBRT files that do not meet these criteria.
%
%  Text starting at WorldBegin to the end of the file (not just WorldEnd)
%  is stored in recipe.world.
%
% TL, ZLy, BW Scienstanford 2017-2020
%
% See also
%   piWrite, piRender, piBlockExtract

% Examples:
%{
 thisR = piRecipeDefault('scene name','MacBethChecker');
 % thisR = piRecipeDefault('scene name','SimpleScene');
 % thisR = piRecipeDefault('scene name','teapot');

 piWrite(thisR);
 scene =  piRender(thisR,'render type','radiance');
 sceneWindow(scene);
%}

%% Parse the inputs

varargin =ieParamFormat(varargin);
p = inputParser;

p.addRequired('fname',@(x)(exist(fname,'file')));
p.addParameter('readmaterials', true,@islogical);
p.addParameter('verbose', 2, @isnumeric);

p.parse(fname,varargin{:});

thisR = recipe;
thisR.inputFile = fname;
readmaterials   = p.Results.readmaterials;
verbosity = p.Results.verbose;

% summary = sprintf('Read summary %s\n',fname);

%% Set the default output directory
[~,scene_fname]  = fileparts(fname);
outFilepath      = fullfile(piRootPath,'local',scene_fname);
outputFile       = fullfile(outFilepath,[scene_fname,'.pbrt']);
thisR.set('outputFile',outputFile);
thisR.set('verbose', verbosity); % can only set one arameter at a time, so call again

%% Read the text and header from the PBRT file
[txtLines, header] = piReadText(fname);

%% Split text lines into pre-WorldBegin and WorldBegin sections
txtLines = piReadWorldText(thisR,txtLines);

%% Set flag indicating whether this is exported Cinema 4D file
% exporterFlag = piReadExporter(thisR,header);
piReadExporter(thisR,header);

%% Extract camera block
thisR.camera = piBlockExtract(txtLines,'blockName','Camera','exporter',thisR.exporter);

%% Extract sampler block
thisR.sampler = piBlockExtract(txtLines,'blockName','Sampler','exporter',thisR.exporter);

%% Extract film block
thisR.film = piBlockExtract(txtLines,'blockName','Film','exporter',thisR.exporter);

% Patch up the filmStruct to match the recipe requirements
if(isfield(thisR.film,'filename'))
    % Remove the filename since it inteferes with the outfile name.
    thisR.film = rmfield(thisR.film,'filename');
end

% Some PBRT files do not specify the film diagonal size.  We set it to
% 1mm here.
try
    thisR.get('film diagonal');
catch
    disp('Setting film diagonal size to 1 mm');
    thisR.set('film diagonal',1);
end

%% Extract transform time block
thisR.transformTimes = piBlockExtract(txtLines, 'blockName', 'TransformTimes', 'exporter', thisR.exporter);

%% Extract surface pixel filter block
thisR.filter = piBlockExtract(txtLines,'blockName','PixelFilter','exporter',thisR.exporter);

%% Extract (surface) integrator block
thisR.integrator = piBlockExtract(txtLines,'blockName','Integrator','exporter',thisR.exporter);

%% Set thisR.lookAt and determine if we need to flip the image
flip = piReadLookAt(thisR,txtLines);

% Sometimes the axis flip is "hidden" in the concatTransform matrix. In
% this case, the flip flag will be true. When the flip flag is true, we
% always output Scale -1 1 1.
if(flip)
    thisR.scale = [-1 1 1];
end

%% Read the light sources and delete them in world
switch thisR.get('exporter')
    case 'C4D'
        thisR = piLightRead(thisR);
    otherwise
end

%% Read Scale, if it exists

% Because PBRT is a LHS and many object models are exported with a RHS,
% sometimes we stick in a Scale -1 1 1 to flip the x-axis. If this scaling
% is already in the PBRT file, we want to keep it around.
% fprintf('Reading scale\n');
[~, scaleBlock] = piBlockExtract(txtLines,'blockName','Scale','exporter',thisR.exporter);
if(isempty(scaleBlock))
    thisR.scale = [];
else
    values = textscan(scaleBlock{1}, '%s %f %f %f');
    thisR.scale = [values{2} values{3} values{4}];
end

%% Read Material.pbrt file
if readmaterials
    piReadMaterials(thisR); 
elseif isequal(thisR.exporter,'Copy')
    if verbosity > 1
        fprintf('Copying materials.\n');
    end
else 
    if verbosity > 1
        fprintf('Skipping materials and texture read.\n');
    end
end

%% Read geometry.pbrt file if pbrt file is exported by C4D
piReadGeometry(thisR);

% I was thinking about summarizing what was read. 
% disp(summary)

end

%% Helper functions

%% Generic text reading, omitting comments and including comments
function [txtLines, header] = piReadText(fname)
% Open, read, close excluding comment lines
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n','CommentStyle',{'#'});
txtLines = tmp{1};
fclose(fileID);

% Include comments so we can read only the first line, really
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n');
header = tmp{1};
fclose(fileID);
end

%% Find the text in WorldBegin/End section
function txtLines = piReadWorldText(thisR,txtLines)
% 
% Finds the text lines from WorldBegin
% It puts the world section into the thisR.world.
% Then it removes the world section from the txtLines
%
% Why doesn't this go to WorldEnd?  We are hoping that nothing is important
% after WorldEnd.  But ...
%

worldBeginIndex = 0;
for ii = 1:length(txtLines)
    currLine = txtLines{ii};
    if(piContains(currLine,'WorldBegin'))
        worldBeginIndex = ii;
        break;
    end
end

% fprintf('Through the loop\n');
if(worldBeginIndex == 0)
    warning('Cannot find WorldBegin.');
    worldBeginIndex = ii;
end

% Store the text from WorldBegin to the end here
thisR.world = txtLines(worldBeginIndex:end);

% Store the text lines from before WorldBegin here
txtLines = txtLines(1:(worldBeginIndex-1));

end

%% Determine whether this is a Cinema4D export or not
function exporterFlag = piReadExporter(thisR,header)
%
% Read the first line of the scene file to see if it is a Cinema 4D file
% Also, check the materials file for consistency.
% Set the recipe accordingly and return a true/false flag
%

if piContains(header{1}, 'Exported by PBRT exporter for Cinema 4D')
    % Interprets the information and writes the _geometry.pbrt and
    % _materials.pbrt files to the rendering folder.
    exporterFlag   = true;
    thisR.exporter = 'C4D';
else
    % Copies the original _geometry.pbrt and _materials.pbrt to the
    % rendering folder.
    exporterFlag   = false;
    thisR.exporter = 'Copy';
end

% Check that the materials file export information matches the scene file
% export 

% Read the materials file if it exists.
inputFile_materials = thisR.get('materials file');

if exist(inputFile_materials,'file')
    
    % Confirm that the material file matches the exporter of the main scene
    % file.
    fileID = fopen(inputFile_materials);
    tmp = textscan(fileID,'%s','Delimiter','\n');
    headerCheck_material = tmp{1};
    fclose(fileID);
    
    if ~piContains(headerCheck_material{1}, 'Exported by piMaterialWrite')
        if isequal(exporterFlag,true) && isequal(thisR.exporter,'C4D')
            % Everything is fine
        elseif isequal(thisR.exporter,'Copy')
            % Everything is still fine
        else
            warning('Puzzled about the materials file.');
        end
    else
        if isequal(exporterFlag,false)
            % Everything is fine
        else
            warning('Non-standard materials file. Export match not C4D like main file');
        end
    end
else
    % No material field.  If exporter is Cinema4D, that's not good. Check
    % that condition here
    if isequal(thisR.exporter,'C4D')
        warning('No materials file for a C4D export');
    end 
end

end 

%% Read the materials file
function thisR = piReadMaterials(thisR)

if isequal(thisR.exporter,'C4D')
    % This reads both the materials and the textures
    inputFile_materials = thisR.get('materials file');
    
    % Check if the materials.pbrt exist
    if ~exist(inputFile_materials,'file'), error('File not found'); end
    thisR.materials.list = piMaterialRead(thisR, inputFile_materials);
    thisR.materials.inputFile_materials = inputFile_materials;
    
    % Call material lib
    thisR.materials.lib = piMateriallib;
    
    %{
            % Convert all jpg textures to png format
            % Only *.png & *.exr are supported in pbrt.
            piTextureFileFormat(thisR);
    %}
    
    % Now read the textures from the materials file
    [thisR.textures.list, thisR.textures.txtLines] = piTextureRead(thisR, inputFile_materials);
    thisR.textures.inputFile_textures = inputFile_materials;
end
end

%% Build the lookAt information
function [flip,thisR] = piReadLookAt(thisR,txtLines)
% Reads multiple blocks to create the lookAt field and flip variable
%
% The lookAt is built up by reading from, to, up field and transform and
% concatTransform.
%
% Interpreting these variables from the text can be more complicated w.r.t.
% formatting.

% A flag for flipping from a RHS to a LHS. 
flip = 0;

% Get the block
[~, lookAtBlock] = piBlockExtract(txtLines,'blockName','LookAt','exporter',thisR.exporter);

if(isempty(lookAtBlock))
    % If it is empty, use the default
    thisR.lookAt = struct('from',[0 0 0],'to',[0 1 0],'up',[0 0 1]);
else
    % We have values
    values = textscan(lookAtBlock{1}, '%s %f %f %f %f %f %f %f %f %f');
    from = [values{2} values{3} values{4}];
    to = [values{5} values{6} values{7}];
    up = [values{8} values{9} values{10}];
end

% If there's a transform, we transform the LookAt.
[~, transformBlock] = piBlockExtract(txtLines,'blockName','Transform','exporter',thisR.exporter);
if(~isempty(transformBlock))
    values = textscan(transformBlock{1}, '%s [%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
    values = cell2mat(values(2:end));
    transform = reshape(values,[4 4]);
    [from,to,up,flip] = piTransform2LookAt(transform);
end

% If there's a concat transform, we use it to update the current camera
% position. 
[~, concatTBlock] = piBlockExtract(txtLines,'blockName','ConcatTransform','exporter',thisR.exporter);
if(~isempty(concatTBlock))
    values = textscan(concatTBlock{1}, '%s [%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
    values = cell2mat(values(2:end));
    concatTransform = reshape(values,[4 4]);
    
    % Apply transform and update lookAt
    lookAtTransform = piLookat2Transform(from,to,up);
    [from,to,up,flip] = piTransform2LookAt(lookAtTransform*concatTransform);
end

% Warn the user if nothing was found
if(isempty(transformBlock) && isempty(lookAtBlock))
    warning('Cannot find "LookAt" or "Transform" in PBRT file. Returning default.');
end

thisR.lookAt = struct('from',from,'to',to,'up',up);

end

%% Read the geometry file
function thisR = piReadGeometry(thisR)

% Call the geometry reading and parsing function

if isequal(thisR.exporter,'C4D')
    fprintf('Reading C4D geometry information.\n');
    thisR = piGeometryRead(thisR);
elseif isequal(thisR.exporter,'Copy')
    fprintf('Geometry file will be copied by piWriteCopy.\n');
else
    fprintf('Skipping geometry.\n');
end

end
