function recipe = piRead(fname,varargin)
% piRecipe - Read a PBRT scene file and return rendering information as a struct. 
%
%    piRecipe(fname, ...)
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
p.parse(fname,varargin{:});

%% Read PBRT file

% Open, read, close
fileID = fopen(fname);

tmp = textscan(fileID,'%s','Delimiter','\n');
txtLines = tmp{1};

fclose(fileID);

%% Extract camera  block

cameraBlock = piBlockExtract(txtLines,'blockName','Camera');
if(isempty(cameraBlock))
    warning('Cannot find "camera" in renderRecipe.');
    camera = struct([]); % Return empty.
else
    camera = piBlock2Struct(cameraBlock);
end

%% Extract sampler block

samplerBlock = piBlockExtract(txtLines,'blockName','Sampler');
if(isempty(samplerBlock))
    warning('Cannot find "sampler" in renderRecipe.');
    sampler = struct([]); % Return empty.
else
    sampler = piBlock2Struct(samplerBlock);
end

%% Extract film block

filmBlock = piBlockExtract(txtLines,'blockName','Film');
if(isempty(filmBlock))
    warning('Cannot find "film" in renderRecipe.');
    film = struct([]); % Return empty.
else
    film = piBlock2Struct(filmBlock);
end

%% Extract surface pixel filter block

pfBlock = piBlockExtract(txtLines,'blockName','PixelFilter');
if(isempty(pfBlock))
    warning('Cannot find "filter" in renderRecipe.');
    filter = struct([]); % Return empty.
else
    filter = piBlock2Struct(pfBlock);
end

%% Extract (surface) integrator block

sfBlock = piBlockExtract(txtLines,'blockName','SurfaceIntegrator');
if(isempty(sfBlock))
    warning('Cannot find "integrator" in renderRecipe.');
    integrator = struct([]); % Return empty.
else
    integrator = piBlock2Struct(sfBlock);
end

%% Extract renderer block

rendererBlock = piBlockExtract(txtLines,'blockName','Renderer');
if(isempty(rendererBlock))
    warning('Cannot find "renderer" in renderRecipe. Using default.');
    renderer = struct('type','Renderer','subtype','sampler');
else
    renderer = piBlock2Struct(rendererBlock);
end

%% Read LookAt and ConcatTransform, if they exist
  
lookAtBlock = piBlockExtract(txtLines,'blockName','LookAt');
if(isempty(lookAtBlock))
    warning('Cannot find "LookAt" for renderRecipe. Returning default.');
    % TODO: What is the default camera position? 
    lookAt = struct('from',[0 0 0],'to',[0 1 0],'up',[0 0 1]);
else
    values = textscan(lookAtBlock{1}, '%s %f %f %f %f %f %f %f %f %f');
    from = [values{2} values{3} values{4}];
    to = [values{5} values{6} values{7}];
    up = [values{8} values{9} values{10}];
    lookAt = struct('from',from,'to',to,'up',up);
end

concatTBlock = piBlockExtract(txtLines,'blockName','ConcatTransform');
if(~isempty(concatTBlock))
    % TODO:
    % extract the transform matrix and multiply it to the lookAt
end


%% Extract world begin/world end

% Extract world as a cell of text lines
fid = fopen(fname, 'r');
world = cell(1,1);
tline = fgetl(fid);
worldStart = 0;
while ischar(tline)
    if contains(tline, 'WorldBegin')
        worldStart = 1;
        world{1}  = tline;  
    end
    tline = fgetl(fid);
    if worldStart
        world{end + 1}  = tline;      
    end
end
fclose(fid);
world = {world(1:end-1)}; % Get rid of the last line
if(~worldStart)   
    warning('Cannot find "WorldBegin" for renderRecipe.');
end

%% Combine into renderRecipe structure

recipe = struct('camera',camera,'sampler',sampler, ...
    'film',film,'filter',filter,'integrator',integrator,...
    'renderer',renderer,'lookAt',lookAt,'world',world,'filename',fname); 


end
