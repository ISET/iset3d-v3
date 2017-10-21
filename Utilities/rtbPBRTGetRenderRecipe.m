function renderRecipe = rtbPBRTGetRenderRecipe(fname,varargin)
%% rtbPBRTGetRenderRecipe - reads a pbrt file, 
%
% Parse a PBRT file and return the information as a struct. We ignore
% anything past the WorldBegin/WorldEnd block. We also assume that the PBRT
% file has a specific structure; this means that this function may not work
% in all PBRT files, especially those we have not inspected and modified.
%
% We call this a "renderRecipe" because it contains instructions to PBRT on
% how to render the given scene. We can make modifications to this
% renderRecipe and eventually call "rtbPBRTWrite" to write it back out into
% a new, modified PBRT file.
%
% Right now, the blocks we read in are: Camera, SurfaceIntegrator, Sampler,
% PixelFilter, and Film, and Renderer
%
% Example
%   pbrtFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/sanmiguel.pbrt';
%   renderRecipe = rtbPBRTGetRenderRecipe(pbrtFile);
%
% TL Scienstanford 2017

%% Programming TODO:

% 1. What happens if one of these blocks is empty? We should automatically
% put in the default value.
% 2. What else do we need to read in here? Volume Integrator? 
%
%     rtbPBRTRead
%      rtbPBRTReadFile
%      rtbPBRTBlockAnalyze
%      rtbPBRTWrite
%

%%
p = inputParser;
p.addRequired('fname',@(x)(exist(fname,'file')));
p.parse(fname,varargin{:});

%% Read PBRT file

% Use pbrt2ISET to pull out the lines of text
txtLines = rtbPBRTRead(fname);

%% Extract camera  block

cameraBlock = rtbPBRTExtractBlock(txtLines,'blockName','Camera');
if(isempty(cameraBlock))
    warning('Cannot find "camera" in renderRecipe.');
    camera = struct([]); % Return empty.
else
    camera = rtbPBRTConvertBlock2Struct(cameraBlock);
end

%% Extract sampler block

samplerBlock = rtbPBRTExtractBlock(txtLines,'blockName','Sampler');
if(isempty(samplerBlock))
    warning('Cannot find "sampler" in renderRecipe.');
    sampler = struct([]); % Return empty.
else
    sampler = rtbPBRTConvertBlock2Struct(samplerBlock);
end

%% Extract film block

filmBlock = rtbPBRTExtractBlock(txtLines,'blockName','Film');
if(isempty(filmBlock))
    warning('Cannot find "film" in renderRecipe.');
    film = struct([]); % Return empty.
else
    film = rtbPBRTConvertBlock2Struct(filmBlock);
end

%% Extract surface pixel filter block

pfBlock = rtbPBRTExtractBlock(txtLines,'blockName','PixelFilter');
if(isempty(pfBlock))
    warning('Cannot find "filter" in renderRecipe.');
    filter = struct([]); % Return empty.
else
    filter = rtbPBRTConvertBlock2Struct(pfBlock);
end

%% Extract (surface) integrator block

sfBlock = rtbPBRTExtractBlock(txtLines,'blockName','SurfaceIntegrator');
if(isempty(sfBlock))
    warning('Cannot find "integrator" in renderRecipe.');
    integrator = struct([]); % Return empty.
else
    integrator = rtbPBRTConvertBlock2Struct(sfBlock);
end

%% Extract renderer block

rendererBlock = rtbPBRTExtractBlock(txtLines,'blockName','Renderer');
if(isempty(rendererBlock))
    warning('Cannot find "renderer" in renderRecipe.');
    renderer = struct([]); % Return empty.
else
    renderer = rtbPBRTConvertBlock2Struct(rendererBlock);
end

%% Combine into renderRecipe structure

renderRecipe = struct('camera',camera,'sampler',sampler, ...
    'film',film,'filter',filter,'integrator',integrator,...
    'renderer',renderer,'filename',fname); 


end
