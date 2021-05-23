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
% Zhenyi, 2020
% See also
%   piWrite, piRender, piBlockExtract_gp

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

p.addRequired('fname', @(x)(exist(fname,'file')));
p.addParameter('exporter', 'C4D', @ischar);
p.parse(fname,varargin{:});

thisR = recipe;
[~, inputname, ~] = fileparts(fname);
thisR.inputFile = fname;

exporter = p.Results.exporter;

%% Set the default output directory
outFilepath      = fullfile(piRootPath,'local',inputname);
outputFile       = fullfile(outFilepath,[inputname,'.pbrt']);
thisR.set('outputFile',outputFile);


%% Split text lines into pre-WorldBegin and WorldBegin sections
[txtLines, ~] = piReadText(thisR.inputFile);
txtLines = strrep(txtLines, '[ "', '"');
txtLines = strrep(txtLines, '" ]', '"');
[options, world] = piReadWorldText(thisR, txtLines);

%% Read options information
% think about using piParameterGet;
% Extract camera block
thisR.camera = piParseOptions(options, 'Camera');

% Extract sampler block
thisR.sampler = piParseOptions(options,'Sampler');
% Extract film block
thisR.film    = piParseOptions(options,'Film');

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

% Extract transform time block
thisR.transformTimes = piParseOptions(options, 'TransformTimes');

% Extract surface pixel filter block
thisR.filter = piParseOptions(options,'PixelFilter');

% Extract (surface) integrator block
thisR.integrator = piParseOptions(options,'Integrator');

% % Extract accelerator
% thisR.accelerator = piParseOptions(options,'Accelerator');

% Set thisR.lookAt and determine if we need to flip the image
flip = piReadLookAt(thisR,options);

% Sometimes the axis flip is "hidden" in the concatTransform matrix. In
% this case, the flip flag will be true. When the flip flag is true, we
% always output Scale -1 1 1.
if(flip)
    thisR.scale = [-1 1 1];
end

% Read the light sources and delete them in world
thisR = piLightRead(thisR);

% Read Scale, if it exists
% Because PBRT is a LHS and many object models are exported with a RHS,
% sometimes we stick in a Scale -1 1 1 to flip the x-axis. If this scaling
% is already in the PBRT file, we want to keep it around.
% fprintf('Reading scale\n');
[~, scaleBlock] = piParseOptions(options,'Scale');
if(isempty(scaleBlock))
    thisR.scale = [];
else
    values = textscan(scaleBlock, '%s %f %f %f');
    thisR.scale = [values{2} values{3} values{4}];
end

%%  Read world information for the Include files

if any(piContains(world,'Include')) && ...
        any(piContains(world,'_materials.pbrt'))
    
    % In this case we have an Include file for the materials.  The world
    % should be left alone.  We read the materials file to get the
    % materials and textures.
    
    % Find material file
    materialIdx = find(contains(world, '_materials.pbrt'), 1);
    
    % We get the name of the file we want to include.
    material_fname = erase(world{materialIdx},{'Include "','"'});
    
    inputDir = thisR.get('inputdir');
    inputFile_materials = fullfile(inputDir, material_fname);
    if ~exist(inputFile_materials,'file'), error('File not found'); end
    
    % We found the material file.  We read it.
    [materialLines, ~] = piReadText(inputFile_materials);
    
    % Change to the single line format from the standard block format with
    % indented lines
    materialLinesFormatted = piFormatConvert(materialLines);
    
    % Read material and texture
    [materialLists, textureList] = parseMaterialTexture(materialLinesFormatted);
    fprintf('Read %d materials.\n', numel(materialLists));
    fprintf('Read %d textures.\n', numel(textureList));
    
    % If exporter is Copy, don't parse the geometry.
    if isequal(exporter, 'Copy')
        disp('Scene geometry will not be parsed.');
        thisR.world = world;
    else        
        % Read the geometry file and do the same.
        geometryIdx = find(contains(world, '_geometry.pbrt'), 1);
        geometry_fname = erase(world{geometryIdx},{'Include "','"'});
        inputFile_geometry = fullfile(inputDir, geometry_fname);
        if ~exist(inputFile_geometry,'file'), error('File not found'); end
        
        % Could this be piReadText too?
        % we need to read file contents with comments
        fileID = fopen(inputFile_geometry);
        tmp = textscan(fileID,'%s','Delimiter','\n');
        geometryLines = tmp{1};
        fclose(fileID);
        
        % convert geometryLines into from the standard block indented format in
        % to the single line format.
        geometryLinesFormatted = piFormatConvert(geometryLines);
        [trees, ~] = parseGeometryText(thisR, geometryLinesFormatted,'');
    end
else
    
    % In this case there is no Include file for the materials.  They are
    % probably defined in the world block. We read the materials and
    % textures from the world block.  We delete them from the block because
    % piWrite will create the scene_materials.pbrt file and insert an
    % Include scene_materials.pbrt line into the world block.
    
    inputFile_materials = [];
    
    % Read material & texture
    [materialLists, textureList, newWorld] = parseMaterialTexture(thisR.world);
    thisR.world = newWorld;
    fprintf('Read %d materials.\n', materialLists.Count);
    fprintf('Read %d textures.\n', textureList.Count);
    
    % If exporter is Copy, don't parse.
    if isequal(exporter, 'Copy')
        disp('Scene geometry will not be parsed.');        
    else
        % Read geometry
        [trees, parsedUntil] = parseGeometryText(thisR, thisR.world,'');
        if ~isempty(trees)
            parsedUntil(parsedUntil>numel(thisR.world))=numel(thisR.world);
            % remove parsed line from world
            thisR.world(2:parsedUntil-1)=[];
        end
    end
    
end

thisR.materials.list = materialLists;
thisR.materials.inputFile_materials = inputFile_materials;

% Call material lib
thisR.materials.lib = piMateriallib;

thisR.textures.list = textureList;
thisR.textures.inputFile_textures = inputFile_materials;

if exist('trees','var') && ~isempty(trees)
    thisR.assets = trees.uniqueNames;
else
    % needs to add function to read structure like this:
    % transform [...] / Translate/ rotate/ scale/
    % material ... / NamedMaterial
    % shape ...
    disp('*** No AttributeBegin/End pair found. Set recipe.assets to empty');
end

disp('***Scene parsed.')

% remove this line after we become more sure that we can deal with scenes
% which are not exported by C4D.
thisR.exporter = 'C4D';
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
function [options, world] = piReadWorldText(thisR,txtLines)
%
% Finds all the text lines from WorldBegin
% It puts the world section into the thisR.world.
% Then it removes the world section from the txtLines
%
% Question: Why doesn't this go to WorldEnd?  We are hoping that nothing is
% important after WorldEnd.  In our experience, we see some files that
% never even have a WorldEnd, just a World Begin.

% The general parser (toply) writes out the PBRT file in a block format with
% indentations.  Zheng's Matlab parser (started with Cinema4D), expects the
% blocks to be in a single line.
%
% This function converts the blocks to a single line.  This function is
% used a few places in piRead().
txtLines = piFormatConvert(txtLines);

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
world = txtLines(worldBeginIndex:end);
thisR.world = world;

% Store the text lines from before WorldBegin here
options = txtLines(1:(worldBeginIndex-1));

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
% [~, lookAtBlock] = piBlockExtract_gp(txtLines,'blockName','LookAt');
[~, lookAtBlock] = piParseOptions(txtLines,'LookAt');
if(isempty(lookAtBlock))
    % If it is empty, use the default
    thisR.lookAt = struct('from',[0 0 0],'to',[0 1 0],'up',[0 0 1]);
else
    % We have values
    %     values = textscan(lookAtBlock{1}, '%s %f %f %f %f %f %f %f %f %f');
    values = textscan(lookAtBlock, '%s %f %f %f %f %f %f %f %f %f');
    from = [values{2} values{3} values{4}];
    to = [values{5} values{6} values{7}];
    up = [values{8} values{9} values{10}];
end

% If there's a transform, we transform the LookAt. % to change
[~, transformBlock] = piBlockExtract_gp(txtLines,'blockName','Transform');
if(~isempty(transformBlock))
    values = textscan(transformBlock{1}, '%s [%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
    values = cell2mat(values(2:end));
    transform = reshape(values,[4 4]);
    [from,to,up,flip] = piTransform2LookAt(transform);
end

% If there's a concat transform, we use it to update the current camera
% position. % to change
[~, concatTBlock] = piBlockExtract_gp(txtLines,'blockName','ConcatTransform');
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

% function [newlines] = piFormatConvert(txtLines)
% % Format txtlines into a standard format.
% nn=1;
% nLines = numel(txtLines);
% 
% ii=1;
% tokenlist = {'A', 'C' , 'F', 'I', 'L', 'M', 'N', 'O', 'P', 'R', 'S', 'T'};
% txtLines = regexprep(txtLines, '\t', ' ');
% while ii <= nLines
%     thisLine = txtLines{ii};
%     if ~isempty(thisLine)
%         if length(thisLine) >= length('Shape')
%             if any(strncmp(thisLine, tokenlist, 1)) && ...
%                     ~strncmp(thisLine,'Include', length('Include')) && ...
%                     ~strncmp(thisLine,'Attribute', length('Attribute'))
%                 % It does, so this is the start
%                 blockBegin = ii;
%                 % Keep adding lines whose first symbol is a double quote (")
%                 if ii == nLines
%                     newlines{nn,1}=thisLine;
%                     break;
%                 end
%                 for jj=(ii+1):nLines+1
%                     if jj==nLines+1 || isempty(txtLines{jj}) || ~isequal(txtLines{jj}(1),'"')
%                         if jj==nLines+1 || isempty(txtLines{jj}) || isempty(str2num(txtLines{jj}(1:2))) ||...
%                                 any(strncmp(txtLines{jj}, tokenlist, 1))
%                             blockEnd = jj;
%                             blockLines = txtLines(blockBegin:(blockEnd-1));
%                             texLines=blockLines{1};
%                             for texI = 2:numel(blockLines)
%                                 if ~strcmp(texLines(end),' ')&&~strcmp(blockLines{texI}(1),' ')
%                                     texLines = [texLines,' ',blockLines{texI}];
%                                 else
%                                     texLines = [texLines,blockLines{texI}];
%                                 end
%                             end
%                             newlines{nn,1}=texLines;nn=nn+1;
%                             ii = jj-1;
%                             break;
%                         end
%                     end
%                     
%                 end
%             else
%                 newlines{nn,1}=thisLine; nn=nn+1;
%             end
%         end
%     end
%     ii=ii+1;
% end
% newlines(piContains(newlines,'Warning'))=[];
% end


%% Parse several critical recipe options
function [s, blockLine] = piParseOptions(txtLines, blockName)
% Parse the options for a specific block
%

% How many lines of text?
nline = numel(txtLines);
s = [];ii=1;

while ii<=nline
    blockLine = txtLines{ii};
    % There is enough stuff to make it worth checking
    if length(blockLine) >= 5 % length('Shape')
        % If the blockLine matches the BlockName, do something
        if strncmp(blockLine, blockName, length(blockName))
            s=[];
            
            % If it is Transform, do this and then return
            if (strcmp(blockName,'Transform') || ...
                    strcmp(blockName,'LookAt')|| ...
                    strcmp(blockName,'ConcatTransform')|| ...
                    strcmp(blockName,'Scale'))
                return;
            end
            
            % It was not Transform.  So figure it out.
            thisLine = strrep(blockLine,'[','');  % Get rid of [
            thisLine = strrep(thisLine,']','');   % Get rid of ]
            thisLine = textscan(thisLine,'%q');   % Find individual words into a cell array
            
            % thisLine is a cell of 1.
            % It contains a cell array with the individual words.
            thisLine = thisLine{1};
            nStrings = length(thisLine);
            blockType = thisLine{1};
            blockSubtype = thisLine{2};
            s = struct('type',blockType,'subtype',blockSubtype);
            dd = 3;
            
            % Build a struct that will be used for representing this type
            % of Option (Camera, Sampler, Integrator, Film, ...)
            % This builds the struct and assigns the values of the
            % parameters
            while dd <= nStrings
                if piContains(thisLine{dd},' ')
                    C = strsplit(thisLine{dd},' ');
                    valueType = C{1};
                    valueName = C{2};
                end
                value = thisLine{dd+1};
                
                % Convert value depending on type
                if(isempty(valueType))
                    continue;
                elseif(strcmp(valueType,'string')) || strcmp(valueType,'bool') || strcmp(valueType,'spectrum')
                    % Do nothing.
                elseif(strcmp(valueType,'float') || strcmp(valueType,'integer'))
                    value = str2double(value);
                else
                    error('Did not recognize value type, %s, when parsing PBRT file!',valueType);
                end
                
                tempStruct = struct('type',valueType,'value',value);
                s.(valueName) = tempStruct;
                dd = dd+2;
            end
            break;
        end
    end
    ii = ii+1;
end

end

%% END


