function thisR = piRead(fname,varargin)
% piRecipe - Read a PBRT scene file and return rendering information as a struct. 
%
%    recipe = piRecipe(fname, ...)
%
% This function parses the scene pbrt file and returns critical
% rendering information in the "recipe". This struct contains all the
% essential information on how to render the given scene. We can
% modify the recipe programmatically to generate multiple renderings. 
%
% The function piWrite uses the recipe to write out a PBRT file that
% can be used to implement the specifics of the recipe.  The function
% piRender uses the PBRT scene file and the recipe to execute the PBRT
% docker image and produce the rendered output (in an ISET scene or oi
% format).
%
% Required inputs
%   fname - a pbrt scene file name
%
% Optional parameter/values
%    
% Return
%   recipe - The parameters needed to render the pbrt scene file
%
% We assume that the PBRT file has a specific structure; this means
% that this function may not work in all PBRT files, especially those
% we have not inspected and modified.
%
% Text beyond the WorldBegin/WorldEnd block is ignored. 
%
% Right now, the blocks we can read are: 
%   Camera, SurfaceIntegrator, Sampler, PixelFilter, and Film, and Renderer
%
% Example
%   pbrtFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/sanmiguel.pbrt';
%   recipe = piRecipe(pbrtFile);
%
% TL Scienstanford 2017

%% Programming TODO:
%
% 1. What happens if one of these blocks is empty? We should automatically
% put in the default value.
% 2. What else do we need to read in here? Volume Integrator? 
%
%     piRead
%      piReadFile
%      rtbPBRTBlockAnalyze
%      rtbPBRTWrite
%
% Note BW:  Suggest creating a recipe structure in the opening part
% of the script and adding the blocks to the pre-defined struct.  It
% might be that we make the recipe a class with methods.
%
% Note BW:  Let's make the 'WorldBegin' extraction a function, pulling
% it out of here, so we can augment it and parse it over time.
%
% Note BW:  Shall we call piRead -> piReadFile()?
%
% I think it is funny (in a good way) that we have piRecipe.  Tee hee.
%

%%
p = inputParser;
p.addRequired('fname',@(x)(exist(fname,'file')));
p.addParameter('version',2,@(x)isnumeric(x));
p.parse(fname,varargin{:});

ver = p.Results.version;

thisR = recipe;
thisR.inputFile = fname;

%% Check version number
if(ver ~= 2 && ver ~=3)
    error('PBRT version number incorrect. Possible versions are 2 or 3.');
else
    thisR.version = ver;
end


%% Read PBRT file

% Open, read, close
fileID = fopen(fname);

tmp = textscan(fileID,'%s','Delimiter','\n');
txtLines = tmp{1};

fclose(fileID);

%% Split text file into pre-world section

worldBeginIndex = 0;

for ii = 1:length(txtLines)
    currLine = txtLines{ii};
    if(contains(currLine,'WorldBegin'))
        worldBeginIndex = ii;
        break;
    end
end
if(worldBeginIndex == 0)
    warning('Cannot find WorldBegin.');
    worldBeginIndex = ii;
end

thisR.world = txtLines(worldBeginIndex:end);
txtLines = txtLines(1:(worldBeginIndex-1));

%% Extract camera  block

cameraBlock = piBlockExtract(txtLines,'blockName','Camera');
if(isempty(cameraBlock))
    warning('Cannot find "camera" in PBRT file.');
    thisR.camera = struct([]); % Return empty.
else
    thisR.camera = piBlock2Struct(cameraBlock);
end

%% Extract sampler block

samplerBlock = piBlockExtract(txtLines,'blockName','Sampler');
if(isempty(samplerBlock))
    warning('Cannot find "sampler" in PBRT file.');
    thisR.sampler = struct([]); % Return empty.
else
    thisR.sampler = piBlock2Struct(samplerBlock);
end

%% Extract film block

filmBlock = piBlockExtract(txtLines,'blockName','Film');
if(isempty(filmBlock))
    warning('Cannot find "film" in PBRT file.');
    thisR.film = struct([]); % Return empty.
else
    thisR.film = piBlock2Struct(filmBlock);
    
    if(isfield(thisR.film,'filename'))
        % Remove the filename since it inteferes with the outfile name.
        thisR.film = rmfield(thisR.film,'filename');
    end
end

%% Extract surface pixel filter block

pfBlock = piBlockExtract(txtLines,'blockName','PixelFilter');
if(isempty(pfBlock))
    warning('Cannot find "filter" in PBRT file.');
    thisR.filter = struct([]); % Return empty.
else
    thisR.filter = piBlock2Struct(pfBlock);
end

%% Extract (surface) integrator block

if(ver == 2)
    sfBlock = piBlockExtract(txtLines,'blockName','SurfaceIntegrator');
elseif(ver == 3)
    sfBlock = piBlockExtract(txtLines,'blockName','Integrator');
end

if(isempty(sfBlock))
    warning('Cannot find "integrator" in PBRT file.');
    thisR.integrator = struct([]); % Return empty.
else
    thisR.integrator = piBlock2Struct(sfBlock);
end

%% Extract renderer block

if(ver == 2)
    rendererBlock = piBlockExtract(txtLines,'blockName','Renderer');
    if(isempty(rendererBlock))
        % warning('Cannot find "renderer" in PBRT file. Using default.');
        thisR.renderer = struct('type','Renderer','subtype','sampler');
    else
        thisR.renderer = piBlock2Struct(rendererBlock);
    end
else
    warning('Renderers do not exist in PBRTv3. Leaving blank...')
end

%% Read LookAt and ConcatTransform, if they exist
%
% Since we've split txtLines appropriately previously, we don't have to
% worry about finding transforms within the World block.
%
% We should also read in 'Transform' which is present in some pbrt
% scene files.  If that exists, don't bother with lookAt or
% ConcatTransform.


lookAtBlock = piBlockExtract(txtLines,'blockName','LookAt');
if(isempty(lookAtBlock))
    warning('Cannot find "LookAt" for PBRT file. Returning default.');
    thisR.lookAt = struct('from',[0 0 0],'to',[0 1 0],'up',[0 0 1]);
else
    values = textscan(lookAtBlock{1}, '%s %f %f %f %f %f %f %f %f %f');
    initFrom = [values{2} values{3} values{4}];
    initTo = [values{5} values{6} values{7}];
    initUp = [values{8} values{9} values{10}];
end

concatTBlock = piBlockExtract(txtLines,'blockName','ConcatTransform');
if(~isempty(concatTBlock))
    values = textscan(concatTBlock{1}, '%s [%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
    values = cell2mat(values(2:end));
    concatTransform = reshape(values,[4 4]);
else
    concatTransform = eye(4,4);
end

% Apply all transforms together and return a final LookAt.
lookAtTransform = piLookat2Transform(initFrom,initTo,initUp);
[from,to,up,flip] = piTransform2LookAt(lookAtTransform*concatTransform);
thisR.lookAt = struct('from',from','to',to','up',up');

%% Read Scale, if it exists
% Because PBRT is a LHS and many object models are exported with a RHS,
% sometimes we stick in a Scale -1 1 1 to flip the x-axis. If this scaling
% is already in the PBRT file, we want to keep it around.
scaleBlock = piBlockExtract(txtLines,'blockName','Scale');
if(isempty(scaleBlock))
    thisR.scale = [];
else
    values = textscan(scaleBlock{1}, '%s %f %f %f');
    thisR.scale = [values{2} values{3} values{4}];
end

% Sometimes the axis flip is "hidden" in the concatTransform matrix. In
% this case, the flip flag will be true. When the flip flag is true, we
% always output Scale -1 1 1.
if(flip)
    thisR.scale = [-1 1 1];
end

%% Extract world begin/world end

% % Extract world as a cell of text lines
% fid = fopen(fname, 'r');
% world = cell(1,1);
% tline = fgetl(fid);
% worldStart = 0;
% while ischar(tline)
%     if contains(tline, 'WorldBegin')
%         worldStart = 1;
%         world{1}  = tline;  
%     end
%     tline = fgetl(fid);
%     if worldStart
%         world{end + 1}  = tline;      
%     end
% end
% fclose(fid);
% world = {world(1:end-1)}; % Get rid of the last line
% if(~worldStart)   
%     warning('Cannot find "WorldBegin" for PBRT file.');
% end
% thisR.world = world{1};


end
