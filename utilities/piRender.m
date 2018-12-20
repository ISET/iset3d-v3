function [ieObject, result, scaleFactor] = piRender(thisR,varargin)
% Read a PBRT scene file, run the docker cmd locally, return the ieObject.
%
% Syntax:
%  [oi or scene or depth map] = piRender(thisR,varargin)
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
%   result - PBRT output from the terminal, vital for debugging!
%   scaleFactor - the scaling factor for the photons (see scaleFactor in
%                 OPTIONAL inputs)
%
% See also s_piReadRender*.m
%
% TL SCIEN Stanford, 2017

% Examples
%{
   % Render an existing pbrt file
   pbrtFile = '/Users/wandell/Documents/MATLAB/pbrt2ISET/local/teapot-area-light.pbrt';
   scene = piRender(pbrtFile);
   ieAddObject(scene); sceneWindow; sceneSet(scene,'gamma',0.5);
%}

%%  Name of the pbrt scene file and whether we use a pinhole or lens model

p = inputParser;
p.KeepUnmatched = true;

% p.addRequired('pbrtFile',@(x)(exist(x,'file')));
p.addRequired('recipe',@(x)(isequal(class(x),'recipe') || ischar(x)));

% Squeeze out spaces and force lower case
for ii=1:2:length(varargin)
    varargin{ii} = ieParamFormat(varargin{ii});
end

rTypes = {'radiance','depth','both','coordinates','material','mesh'};
p.addParameter('rendertype','both',@(x)(ismember(x,rTypes)));
p.addParameter('scaleFactor',[],@(x)isnumeric(x));
p.addParameter('version',2,@(x)isnumeric(x));

p.parse(thisR,varargin{:});
renderType = p.Results.rendertype;
version    = p.Results.version;
scaleFactor = p.Results.scaleFactor;

if ischar(thisR)
    % In this case, we are just rendering a pbrt file.  No depthFile.
    % We could do more/better in the future.  The directory containing the
    % pbrtFile will be mounted.
    pbrtFile = thisR;
    
    % Figure out this optics type of the file
    thisR = piRead(pbrtFile,'version',version);
    
    if ~strcmp(renderType,'radiance')
        warning('For a file as input only radiance is rendered.');
        renderType = 'radiance';
    end
    
    workingFolder = fileparts(pbrtFile);
    if(isempty(workingFolder))
        error('Absolute path required for the working folder.');
    end
    
elseif isa(thisR,'recipe')
    %% Set up the working folder that will be mounted by the Docker image
    
    
    % Set up the radiance file
    workingFolder = fileparts(thisR.outputFile);
    if(~exist(workingFolder,'dir'))
        error('We need an absolute path for the working folder.');
    end
    pbrtFile = thisR.outputFile;
    
    % Set up any metadata render. By default, we do "both" which includes
    % both the radiance and the depth map.
    if (~strcmp(renderType,'radiance'))
        
        % Do some checks for the renderType.
        if((thisR.version ~= 3) && strcmp(renderType,'coordinates'))
            error('Coordinates metadata render only available right now for pbrt-v3-spectral.');
        end
        
        if(strcmp(renderType,'both'))
            metadataType = 'depth';
        else
            metadataType = renderType;
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
    
else
    error('A full path to a scene pbrt file or a recipe class is required\n');
end

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

for ii = 1:length(filesToRender)
    
    currFile = filesToRender{ii};
    
    %% Build the docker command
    dockerCommand   = 'docker run -ti --rm';
    
    if(thisR.version == 3 || version == 3)
        dockerImageName = 'vistalab/pbrt-v3-spectral:test';
    else
        dockerImageName = 'vistalab/pbrt-v2-spectral';
    end
    
    [~,currName,~] = fileparts(currFile);
    
    % Make sure renderings folder exists
    if(~exist(fullfile(workingFolder,'renderings'),'dir'))
        mkdir(fullfile(workingFolder,'renderings'));
    end
    
    outFile = fullfile(workingFolder,'renderings',[currName,'.dat']);
    renderCommand = sprintf('pbrt --outfile %s %s', ...
        outFile, currFile);
    
    if ~isempty(workingFolder)
        if ~exist(workingFolder,'dir'), error('Need full path to %s\n',workingFolder); end
        dockerCommand = sprintf('%s --workdir="%s"', dockerCommand, workingFolder);
    end
    
    dockerCommand = sprintf('%s --volume="%s":"%s"', dockerCommand, workingFolder, workingFolder);
    
    cmd = sprintf('%s %s %s', dockerCommand, dockerImageName, renderCommand);
    
    %% Invoke the Docker command with or without capturing results.
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
    % Used to have an else condition here
    % fprintf('Docker run status %d, seems OK.\n',status);
    % fprintf('Outfile file: %s.\n',outFile);
    
    fprintf('*** Rendering time for %s:  %.1f sec ***\n\n',currName,elapsedTime);
    
    %% Convert the radiance.dat to an ieObject
    switch label{ii}
        case 'radiance'
            [ieObject,scaleFactor] = piDat2ISET(outFile,...
                'label','radiance','recipe',thisR,'scale factor',scaleFactor);
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







