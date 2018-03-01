function thisR = piRead(fname,varargin)
% piRecipe - Read a PBRT scene file and return rendering information as a struct. 
%
%    recipe = piRecipe(fname, ...)
%
% piRead parses a scene pbrt file and returns critical rendering information in
% the various slots of the "recipe". The recipe object contains all the
% essential information on how to render the given scene. We can modify the
% recipe programmatically to generate multiple renderings.
%
% piWrite uses the recipe to write out a PBRT file; piRender executes the PBRT
% docker image to produce the rendered output (in an ISET scene or oi format).
%
% Required inputs
%   fname - a pbrt scene file name
%
% Optional parameter/values
%   'version' - Which version of PBRT.  Only ver 2 is implemented now. Ver 3 is
%               being worked on.
%
% Return
%   recipe - A recipe object with the parameters needed to write a new pbrt
%            scene file
%
% Caution:  The reading algorithm assumes that
%
%     * There is a block of text before WorldBegin and nothing after 
%     * Comments (indicated by '#' in the first character) and blank lines are
%     ignored.
%     * Block names we recognize are listed below.  When a block name is
%     detected, the lines that follow beginning with a '"' are included in the
%     block.
%    
% This function will not work in PBRT files, that do not meet these criteria.
%
% Text beyond the WorldBegin/WorldEnd block is stored in recipe.world. 
%
% Blocks we can read are
%   
%   Camera, SurfaceIntegrator, Sampler, PixelFilter, and Film, and Renderer
%
% Example
%   pbrtFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/sanmiguel.pbrt';
%   recipe = piRecipe(pbrtFile);
%
% TL Scienstanford 2017

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

% I don't understand why the spaces or tabs at the beginning of the line are not
% returned here. (BW).
tmp = textscan(fileID,'%s','Delimiter','\n','CommentStyle',{'#'});
txtLines = tmp{1};

fclose(fileID);

%% Split text lines into pre-WorldBegin and WorldBegin sections

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

% Store the text in WorldBegin
thisR.world = txtLines(worldBeginIndex:end);

% Here are the text lines from before WorldBegin
txtLines = txtLines(1:(worldBeginIndex-1));

%% Check if header indicates exporter

% Unfortunately we have to re-read the text file in order to check the
% header. 
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n');
headerCheck = tmp{1};
fclose(fileID);
if contains(headerCheck{1}, 'Exported by PBRT exporter for Cinema 4D')
    exporterFlag = true;
else
    exporterFlag = false;
end
    
%% It would be nice to identify every block

%% Extract camera  block

cameraStruct = piBlockExtract(txtLines,'blockName','Camera','exporterFlag',exporterFlag);
if(isempty(cameraStruct))
    warning('Cannot find "camera" in PBRT file.');
    thisR.camera = struct([]); % Return empty.
else
    thisR.camera = cameraStruct;
end

%% Extract sampler block

samplerStruct = piBlockExtract(txtLines,'blockName','Sampler','exporterFlag',exporterFlag);
if(isempty(samplerStruct))
    warning('Cannot find "sampler" in PBRT file.');
    thisR.sampler = struct([]); % Return empty.
else
    thisR.sampler = samplerStruct;
end

%% Extract film block

filmStruct = piBlockExtract(txtLines,'blockName','Film','exporterFlag',exporterFlag);
if(isempty(filmStruct))
    warning('Cannot find "film" in PBRT file.');
    thisR.film = struct([]); % Return empty.
else
    thisR.film = filmStruct;
    
    if(isfield(thisR.film,'filename'))
        % Remove the filename since it inteferes with the outfile name.
        thisR.film = rmfield(thisR.film,'filename');
    end
end

%% Extract surface pixel filter block

pfStruct = piBlockExtract(txtLines,'blockName','PixelFilter','exporterFlag',exporterFlag);
if(isempty(pfStruct))
    warning('Cannot find "filter" in PBRT file.');
    thisR.filter = struct([]); % Return empty.
else
    thisR.filter = pfStruct;
end

%% Extract (surface) integrator block

if(ver == 2)
    sfStruct = piBlockExtract(txtLines,'blockName','SurfaceIntegrator','exporterFlag',exporterFlag);
elseif(ver == 3)
    sfStruct = piBlockExtract(txtLines,'blockName','Integrator','exporterFlag',exporterFlag);
end

if(isempty(sfStruct))
    warning('Cannot find "integrator" in PBRT file. Did you forget to turn on the v3 flag?');
    thisR.integrator = struct([]); % Return empty.
else
    thisR.integrator = sfStruct;
end

%% Extract renderer block

if(ver == 2)
    rendererStruct = piBlockExtract(txtLines,'blockName','Renderer','exporterFlag',exporterFlag);
    if(isempty(rendererStruct))
        % warning('Cannot find "renderer" in PBRT file. Using default.');
        thisR.renderer = struct('type','Renderer','subtype','sampler');
    else
        thisR.renderer = rendererStruct;
    end
else
    warning('"Renderer" does not exist in the new PBRTv3 format. We will leave the field blank in the recipe.')
end

%% Read LookAt, Transforms, and ConcatTransform, if they exist
% TODO: In the future we should move all these Transforms into
% piBlockExtract so that all the parsing is done there. That would make
% much more sense, organizationally. However, it's more complicated than,
% since some of the transforms act on each other, so we'll have to be very
% clever when doing the transforms.

% Parse the camera position.

% A flag for flipping from a RHS to a LHS. 
flip = 0;

[~, lookAtBlock] = piBlockExtract(txtLines,'blockName','LookAt','exporterFlag',exporterFlag);
if(isempty(lookAtBlock))
    % Default camera position.
    thisR.lookAt = struct('from',[0 0 0],'to',[0 1 0],'up',[0 0 1]);
else
    values = textscan(lookAtBlock{1}, '%s %f %f %f %f %f %f %f %f %f');
    from = [values{2} values{3} values{4}];
    to = [values{5} values{6} values{7}];
    up = [values{8} values{9} values{10}];
end

% If there's a transform it will overwrite the LookAt.
[~, transformBlock] = piBlockExtract(txtLines,'blockName','Transform','exporterFlag',exporterFlag);
if(~isempty(transformBlock))
    values = textscan(transformBlock{1}, '%s [%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
    values = cell2mat(values(2:end));
    transform = reshape(values,[4 4]);
    [from,to,up,flip] = piTransform2LookAt(transform);
end

% Error checking
if(isempty(transformBlock) && isempty(lookAtBlock))
    warning('Cannot find "LookAt" or "Transform" in PBRT file. Returning default.');
end

% If there's a concat transform, we use it to update the current camera
% position. 
[~, concatTBlock] = piBlockExtract(txtLines,'blockName','ConcatTransform','exporterFlag',exporterFlag);
if(~isempty(concatTBlock))
    values = textscan(concatTBlock{1}, '%s [%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
    values = cell2mat(values(2:end));
    concatTransform = reshape(values,[4 4]);
    
    % Apply transform and update lookAt
    lookAtTransform = piLookat2Transform(from,to,up);
    [from,to,up,flip] = piTransform2LookAt(lookAtTransform*concatTransform);

end

thisR.lookAt = struct('from',from,'to',to,'up',up);

%% Read Scale, if it exists
% Because PBRT is a LHS and many object models are exported with a RHS,
% sometimes we stick in a Scale -1 1 1 to flip the x-axis. If this scaling
% is already in the PBRT file, we want to keep it around.
[~, scaleBlock] = piBlockExtract(txtLines,'blockName','Scale','exporterFlag',exporterFlag);
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

end
