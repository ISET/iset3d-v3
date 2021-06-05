function [ieObject, result] = piRender_Blender(thisR,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: below added
% Adapted from piRender.m to handle the exporter being set to 'Blender'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
%
%  renderType - Determine which types to render.  PBRT can render
%               radiance, metadata (e.g., depth, mesh, material), the
%               the illuminant, or some combinations.  The options
%               are:
%
%    Spectral data
%      'all'      - radiance, depth, illuminant
%      'both'     - radiance and depth
%      'radiance' - spectral radiance (or irradiance of an oi)
%      'illuminant'  - radiance and illuminant data
%      'illuminantonly' - The materials are set to matte white and
%                         rendered.  The spatial-spectral energy is
%                         returned in a form that can be used as a
%                         scene illuminant.
%    Metadata
%      'depth'    - depth map in meters
%      'coordinates' - A [row,col,3] tensor of the (x,y,z) coordinate of
%                      each pixel
%      'material'    - label for the material at each pixel
%      'mesh'        - label for the mesh identity at each pixel
%
%       N.B. If thisR is a fullpath to a file, then we only renderType
%       is forced to be 'radiance'.  
%
%  version    - PBRT version, 2 or 3.   Default is 3.  2 will be
%               deprecated.
%  mean luminance -  If a scene, this mean luminance
%                 (default 100 cd/m2) 
%  mean illuminance per mm2 - default is 5 lux
%  scaleIlluminance
%             - if true, scale the mean illuminance by the pupil
%               diameter in piDat2ISET (default is true)
%  reuse      - Boolean. Indicate whether to use an existing file if one of
%               the correct size exists (default is false)
%
% RETURN
%   ieObject - an ISET scene, oi, or a metadata image
%   result   - PBRT output from the terminal.  This can be vital for
%              debugging! The result contains useful parameters about
%              the optics, too, including the distance from the back
%              of the lens to film and the in-focus distance given the
%              lens-film distance.
%
% TL SCIEN Stanford, 2017
% JNM 03/19 Add reuse feature for renderings
%
% See also 
%   s_piReadRender*.m, piRenderResult

% Examples
%{
   % Renders both radiance and depth
   pbrtFile = fullfile(piRootPath,'data','V3','teapot','teapot-area-light.pbrt');
   scene = piRender(pbrtFile);
   sceneWindow(scene); sceneSet(scene,'gamma',0.5);
%}
%{
   % Render radiance and depth separately
   pbrtFile = fullfile(piRootPath,'data','V3','teapot','teapot-area-light.pbrt');
   scene = piRender(pbrtFile,'render type','radiance');
   ieAddObject(scene); sceneWindow; sceneSet(scene,'gamma',0.5);
   dmap = piRender(pbrtFile,'render type','depth');
   scene = sceneSet(scene,'depth map',dmap);
   sceneWindow(scene); sceneSet(scene,'gamma',0.5);
%}
%{
  % Separately calculate the illuminant and the radiance
  thisR = piRecipeDefault; piWrite(thisR);
  [scene, result]      = piRender(thisR, 'render type','radiance');
  [illPhotons, result] = piRender(thisR, 'render type','illuminant only');
  scene = sceneSet(scene,'illuminant photons',illPhotons);
  sceneWindow(scene);
%}
%{
  % Calculate the (x,y,z) coordinates of every surface point in the
  % scene.  If there is no surface a zero is returned.  This should
  % probably either a Inf or a NaN when there is no surface.  We might
  % replace those with a black color or something.   
  thisR = piRecipeDefault; piWrite(thisR);
  [coords, result] = piRender(thisR, 'render type','coordinates');
  ieNewGraphWin; imagesc(coords(:,:,1));
  ieNewGraphWin; imagesc(coords(:,:,2));
  ieNewGraphWin; imagesc(coords(:,:,3));
%}

%%  Name of the pbrt scene file and whether we use a pinhole or lens model

p = inputParser;
p.KeepUnmatched = true;

% p.addRequired('pbrtFile',@(x)(exist(x,'file')));
p.addRequired('recipe',@(x)(isequal(class(x),'recipe') || ischar(x)));

varargin = ieParamFormat(varargin);

rTypes = {'radiance','depth','both','all','coordinates','material','mesh', 'illuminant','illuminantonly'};
p.addParameter('rendertype','both',@(x)(ismember(ieParamFormat(x),rTypes)));
p.addParameter('version',3,@(x)isnumeric(x));
p.addParameter('meanluminance',[],@isnumeric);
p.addParameter('meanilluminancepermm2',[],@isnumeric);
p.addParameter('scaleIlluminance',true,@islogical);
p.addParameter('reuse',false,@islogical);
p.addParameter('reflectancerender', false, @islogical);
p.addParameter('dockerimagename','vistalab/pbrt-v3-spectral:latest',@ischar);
p.addParameter('wave', 400:10:700, @isnumeric); % This is the past to piDat2ISET, which is where we do the construction.

p.parse(thisR,varargin{:});
renderType       = ieParamFormat(p.Results.rendertype);
version          = p.Results.version;
dockerImageName  = p.Results.dockerimagename;
scaleIlluminance = p.Results.scaleIlluminance;
wave             = p.Results.wave;
fprintf('Docker container %s\n',dockerImageName);

% Different containers expect different wavelength ranges.
dockerWave = 400:10:700;
dockerSplit = split(dockerImageName, ':');
if numel(dockerSplit) == 2
    switch dockerSplit{2}
        case 'latest'
            dockerWave = 400:10:700;
        case 'basisfunction'
            dockerWave = 365:5:705;
    end
end


if ischar(thisR)
    % In this case, we only have a string to the pbrt file.  We build
    % the PBRT recipe and default the metadata type to a depth map.
    
    % Read the pbrt file and produce the recipe.  A full path is
    % required.
    pbrtFile = which(thisR);
    
    % TL: If thisR is already a full path, "which" will sometimes returns
    % empty. To avoid the error, let's try this:
    if(isempty(pbrtFile))
        pbrtFile = thisR;
    end
    
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
% If radiance, no metadata
if ((~strcmp(renderType,'radiance')))  
    
    % Do some checks for the renderType.
    if((thisR.version ~= 3) && strcmp(renderType,'coordinates'))
        error('Coordinates metadata render only available right now for pbrt-v3-spectral.');
    end
    
    switch renderType
        case 'both'
            metadataType{1} = 'depth';
        case 'all'
            metadataType{1} = 'depth';
            metadataType{2} = 'illuminant';
        otherwise
             metadataType{1} = renderType;
    end
    
    for ii=1:numel(metadataType)
        
        metadataRecipe = piRecipeConvertToMetadata(thisR,'metadata',metadataType{ii});
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % NOTE: below changed
        % to include Blender exporter
        
        % Depending on whether we used C4D or Blender to export, we create a new
        % material files that we link with the main pbrt file.
        if(strcmp(metadataRecipe.exporter,'C4D')) || (strcmp(metadataRecipe.exporter,'Blender'))
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            creatematerials = true;
            overwritegeometry = true;
        else
            creatematerials = false;
            overwritegeometry = false;
        end
        piWrite(metadataRecipe,...
            'overwritepbrtfile', true,...
            'overwritelensfile', false, ...
            'overwriteresources', false,...
            'creatematerials',creatematerials,...
            'overwritegeometry',overwritegeometry);
        
        metadataFile{ii} = metadataRecipe.outputFile; %#ok<AGROW>
    end

end

%% Set up files we will render

filesToRender = {};
label = {};
switch renderType
    case {'all'}
        filesToRender{1} = pbrtFile;        label{1} = 'radiance';
        filesToRender{2} = metadataFile{1}; label{2} = 'depth';
        filesToRender{3} = metadataFile{2}; label{3} = 'illuminant';
    case {'both'}
        % Radiance and the metadata.  But not the illuminant.
        filesToRender{1} = pbrtFile;        label{1} = 'radiance';
        filesToRender{2} = metadataFile{1}; label{2} = 'depth';
    case {'radiance'}
        % Spectral radiance
        filesToRender{1} = pbrtFile;        label{1} = 'radiance';
    case {'coordinates'}
        % We need coordinates to be separate since its return type is
        % different than the other metadata types.
        filesToRender{1} = metadataFile{1};    label{1} = 'coordinates';
    case{'material','mesh','depth'}
        % Returns one of the metadata types as an image
        % This could be depth, material, or the mesh (object) type
        filesToRender{1} = metadataFile{1};
        label{1} = 'metadata';
    case{'illuminant'}
        % Illuminant and radiance
        filesToRender{1} = pbrtFile;         label{1} = 'radiance';
        filesToRender{2} = metadataFile{1};     label{2} = 'illuminant';
    case {'illuminantonly'}
        % Turn all the surfaces matte white and render
        % The returned spectral radiance is a measure of the
        % space-varying illumination.
        filesToRender{1} = metadataFile{1};     label{1} = 'illuminantonly';
    otherwise
        error('Cannot recognize render type.');
end

%% Call the Docker for rendering
for ii = 1:length(filesToRender)
    skipDocker = false;
    currFile = filesToRender{ii};

    %% Build the docker command
    dockerCommand   = 'docker run -ti --rm';

    [~,currName,~] = fileparts(currFile);

    % Make sure renderings folder exists
    if(~exist(fullfile(outputFolder,'renderings'),'dir'))
        mkdir(fullfile(outputFolder,'renderings'));
    end

    outFile = fullfile(outputFolder,'renderings',[currName,'.dat']);

    if ispc  % Windows
        outF = strcat('renderings/',currName,'.dat');
        renderCommand = sprintf('pbrt --outfile %s %s', outF, strcat(currName, '.pbrt'));

        folderBreak = split(outputFolder, '\');
        shortOut = strcat('/', char(folderBreak(end)));

        if ~isempty(outputFolder)
            if ~exist(outputFolder,'dir'), error('Need full path to %s\n',outputFolder); end
            dockerCommand = sprintf('%s -w %s', dockerCommand, shortOut);
        end

        linuxOut = strcat('/c', strrep(erase(outputFolder, 'C:'), '\', '/'));

        dockerCommand = sprintf('%s -v %s:%s', dockerCommand, linuxOut, shortOut);

        cmd = sprintf('%s %s %s', dockerCommand, dockerImageName, renderCommand);
    else  % Linux & Mac
        renderCommand = sprintf('pbrt --outfile %s %s', outFile, currFile);

        if ~isempty(outputFolder)
            if ~exist(outputFolder,'dir'), error('Need full path to %s\n',outputFolder); end
            dockerCommand = sprintf('%s --workdir="%s"', dockerCommand, outputFolder);
        end

        dockerCommand = sprintf('%s --volume="%s":"%s"', dockerCommand, outputFolder, outputFolder);

        cmd = sprintf('%s %s %s', dockerCommand, dockerImageName, renderCommand);
    end

    %% Determine if prefer to use existing files, and if they exist.
    if p.Results.reuse
        [fid, message] = fopen(outFile, 'r');
        if fid < 0
            warning(strcat(message, ': ', currName));
        else
            sizeLine = fgetl(fid);
            [imageSize, count, err] = sscanf(sizeLine, '%f', inf);
            if count ~=3
                fclose(fid);
                warning('Could not read image size: %s', err);
            end
            serializedImage = fread(fid, inf, 'double');
            fclose(fid);
            if numel(serializedImage) == prod(imageSize)
                fprintf('\nThe file "%s" already exists in the correct size.\n\n', currName);
                skipDocker = true;
            end
        end
    end

    % When do we use this case?
    if skipDocker
        result = '';
    else
        %% Invoke the Docker command
        tic
        [status, result] = piRunCommand(cmd);
        elapsedTime = toc;
        % disp(result)
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
    end

    %% Convert the returned data to an ieObject

    % The cases that return the radiance (both, radiance, illuminant)
    % should set the mean luminance or mean illuminance.
    switch label{ii}
        case 'radiance'
            ieObject = piDat2ISET(outFile,...
                'label','radiance',...
                'recipe',thisR,...
                'scaleIlluminance',scaleIlluminance,...
                'wave',dockerWave);
        case {'metadata'}
            metadata = piDat2ISET(outFile,...
                'label','mesh',...
                'wave',dockerWave);
            ieObject   = metadata;
        case 'depth'
            depthImage = piDat2ISET(outFile,...
                'label','depth',...
                'wave',dockerWave);
            if ~isempty(ieObject) && isstruct(ieObject)
                ieObject = sceneSet(ieObject,'depth map',depthImage);
            end
        case 'coordinates'
            coordMap = piDat2ISET(outFile,...
                'label','coordinates',...
                'wave',dockerWave);
            ieObject = coordMap;
        case {'illuminant'}
            % PBRT rendered data for white matte surfaces
            illuminantPhotons = piDat2ISET(outFile,...
                'label', 'illuminant',...
                'scaleIlluminance',scaleIlluminance,...
                'wave', dockerWave);
            if ~isempty(ieObject) && isstruct(ieObject)
                ieObject = sceneSet(ieObject, 'illuminant photons', illuminantPhotons);
            end            
        case {'illuminantonly'}
            ieObject = piDat2ISET(outFile,...
                'label', 'illuminantonly', ...
                'scaleIlluminance',scaleIlluminance,...
                'wave', dockerWave);
    end

end

%% We used to name here, but apparently not needed any more

% Why are we updating the wave?  Is that ever needed?
if isstruct(ieObject)
    switch ieObject.type
        case 'scene'
            % names = strsplit(fileparts(thisR.inputFile),'/');
            % ieObject = sceneSet(ieObject,'name',names{end});
            curWave = sceneGet(ieObject,'wave');
            if ~isequal(curWave(:),wave(:))
                ieObject = sceneSet(ieObject, 'wave', wave);
            end
            
        case 'opticalimage'
            % names = strsplit(fileparts(thisR.inputFile),'/');
            % ieObject = oiSet(ieObject,'name',names{end});
            curWave = oiGet(ieObject,'wave');
            if ~isequal(curWave(:),wave(:)) 
                ieObject = oiSet(ieObject,'wave',wave);
            end
                        
        otherwise
            error('Unknown struct type %s\n',ieObject.type);
    end
end





