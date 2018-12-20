function [ieObject, result, scaleFactor] = piRender(thisR,varargin)
% Read a PBRT scene file, run the docker cmd locally, return the ieObject.
%
% Syntax:
%  [oi or scene or metadata] = piRender(thisR,varargin)
%
% REQUIRED input
%  thisR - A recipe, whose outputFile specifies the file, OR a string that
%          is a full path to a scene pbrt file.
%
% OPTIONAL input parameter/val
%  oi/scene   - You can use parameters from oiSet or sceneSet that
%               will be applied to the rendered ieObject prior to return.
%  renderType - render radiance, depth or both (default).  If the input is
%               a fullpath to a file, then we only render the radiance
%               data. Ask if you want this changed to permit a depth map.
%               We have multiple different metadata options. For pbrt-v2 we
%               have depth, mesh, and material. For pbrt-v3 we have depth
%               and coordinates at the moment.
%  version    - PBRT version, 2 or 3
%  scaleFactor - photons are scaled by a value in order to produce
%               reasonable illuminance. Here, you can manually input a
%               scale factor to apply to this particular render. If empty,
%               a default value is used
%
% RETURN
%   ieObject - an ISET scene, oi, or a depth map image
%   result   - PBRT output from the terminal, vital for debugging!
%   scaleFactor - the scaling factor for the photons (see scaleFactor in
%                 OPTIONAL inputs)
%
% See also s_piReadRender*.m
%
% TL SCIEN Stanford, 2017

% Examples
%{
   % Renders both radiance and depth
   pbrtFile = fullfile(piRootPath,'data','V3','teapot','teapot-area-light.pbrt');
   scene = piRender(pbrtFile);
   ieAddObject(scene); sceneWindow; sceneSet(scene,'gamma',0.5);
%}
%{
   % Render radiance and depth separately
   pbrtFile = fullfile(piRootPath,'data','V3','teapot','teapot-area-light.pbrt');
   scene = piRender(pbrtFile,'render type','radiance');
   ieAddObject(scene); sceneWindow; sceneSet(scene,'gamma',0.5);
   dmap = piRender(pbrtFile,'render type','depth');
   scene = sceneSet(scene,'depth map',dmap);
   ieAddObject(scene); sceneWindow; sceneSet(scene,'gamma',0.5);
%}

%%  Name of the pbrt scene file and whether we use a pinhole or lens model

% TODO:  Replace scaleFactor with a mean luminance or illuminance.  If
% an illuminance, then it should be specified for a 1mm2 aperture

p = inputParser;
p.KeepUnmatched = true;

% p.addRequired('pbrtFile',@(x)(exist(x,'file')));
p.addRequired('recipe',@(x)(isequal(class(x),'recipe') || ischar(x)));

% Squeeze out spaces and force lower case
varargin = ieParamFormat(varargin);

rTypes = {'radiance','depth','both','coordinates','material','mesh'};
p.addParameter('rendertype','both',@(x)(ismember(x,rTypes)));
% p.addParameter('scaleFactor',[],@(x)isnumeric(x));
p.addParameter('version',3,@(x)isnumeric(x));

% If you are insisting on using V2, then set dockerImageName to
% 'vistalab/pbrt-v2-spectral'; 
p.addParameter('dockerImageName','vistalab/pbrt-v3-spectral',@ischar);

p.parse(thisR,varargin{:});
renderType      = p.Results.rendertype;
version         = p.Results.version;
% scaleFactor     = p.Results.scaleFactor;
dockerImageName = p.Results.dockerImageName;

if ischar(thisR)
    % In this case, we only have a string to the pbrt file.  We build
    % the PBRT recipe and default the metadata type to a depth map.
    
    % Read the pbrt file and produce the recipe.  A full path is
    % required.
    pbrtFile = which(thisR);
    thisR = piRead(pbrtFile,'version',version);
    
    % Stash the file in the local output
    piWrite(thisR);
    
end

%% We have a radiance recipe and we have written the pbrt radiance file

% Set up the output folder.  This folder will be mounted by the Docker
% image
outputFolder = fileparts(thisR.outputFile);
if(~exist(outputFolder,'dir'))
    error('We need an absolute path for the working folder.');
end
pbrtFile = thisR.outputFile;

% Set up any metadata render.
if (~strcmp(renderType,'radiance'))  % If radiance, no metadata
    
    % Do some checks for the renderType.
    if((thisR.version ~= 3) && strcmp(renderType,'coordinates'))
        error('Coordinates metadata render only available right now for pbrt-v3-spectral.');
    end
    
    if(strcmp(renderType,'both')), metadataType = 'depth';
    else,                          metadataType = renderType;
    end
    
    metadataRecipe = piRecipeConvertToMetadata(thisR,'metadata',metadataType);
    
    % Depending on whether we used C4D to export, we create a new
    % material files that we link with the main pbrt file.
    if(strcmp(metadataRecipe.exporter,'C4D'))
        creatematerials = true;
    else
        creatematerials = false;
    end
    piWrite(metadataRecipe,...
        'overwritepbrtfile', true,...
        'overwritelensfile', false, ...
        'overwriteresources', false,...
        'creatematerials',creatematerials);
    
    metadataFile = metadataRecipe.outputFile;

end

%% Set up files we will render

filesToRender = {};
label = {};
switch renderType
    case {'both','all'}
        filesToRender{1} = pbrtFile;
        label{1} = 'radiance';
        filesToRender{2} = metadataFile;
        label{2} = 'depth';
    case {'radiance'}
        filesToRender = {pbrtFile};
        label{1} = 'radiance';
    case {'coordinates'}
        % We need coordinates to be separate since it's return type is
        % different than the other metadata types.
        filesToRender = {metadataFile};
        label{1} = 'coordinates';
    case{'material','mesh','depth'}
        filesToRender = {metadataFile};
        label{1} = 'metadata';
    otherwise
        error('Cannot recognize render type.');
end

%% Call the Docker contains for rendering
for ii = 1:length(filesToRender)
    
    currFile = filesToRender{ii};
    
    %% Build the docker command
    dockerCommand   = 'docker run -ti --rm';
    
    [~,currName,~] = fileparts(currFile);
    
    % Make sure renderings folder exists
    if(~exist(fullfile(outputFolder,'renderings'),'dir'))
        mkdir(fullfile(outputFolder,'renderings'));
    end
    
    outFile = fullfile(outputFolder,'renderings',[currName,'.dat']);
    renderCommand = sprintf('pbrt --outfile %s %s', ...
        outFile, currFile);
    
    if ~isempty(outputFolder)
        if ~exist(outputFolder,'dir'), error('Need full path to %s\n',outputFolder); end
        dockerCommand = sprintf('%s --workdir="%s"', dockerCommand, outputFolder);
    end
    
    dockerCommand = sprintf('%s --volume="%s":"%s"', dockerCommand, outputFolder, outputFolder);
    
    cmd = sprintf('%s %s %s', dockerCommand, dockerImageName, renderCommand);
    
    %% Invoke the Docker command
    tic
    [status, result] = piRunCommand(cmd);
    elapsedTime = toc;
    
    %% Check the return
    
    if status
        warning('Docker did not run correctly');
        % The status may contain a useful error message that we should
        % look up.  The ones we understand should offer help here.
        fprintf('Status:\n'); disp(status)
        fprintf('Result:\n'); disp(result)
        pause;
    end
    
    fprintf('*** Rendering time for %s:  %.1f sec ***\n\n',currName,elapsedTime);
    
    %% Convert the returned data to an ieObject
    switch label{ii}
        case 'radiance'
            ieObject = piDat2ISET(outFile,...
                'label','radiance','recipe',thisR);
        case {'metadata'}
            metadata = piDat2ISET(outFile,'label','mesh');
            ieObject   = metadata;
        case 'depth'
            depthImage = piDat2ISET(outFile,'label','depth');
            if ~isempty(ieObject) && isstruct(ieObject)
                ieObject = sceneSet(ieObject,'depth map',depthImage);
            end
        case 'coordinates'
            coordMap = piDat2ISET(outFile,'label','coordinates');
            ieObject = coordMap;
    end
    
end

end







