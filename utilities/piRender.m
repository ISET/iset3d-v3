function [ieObject, result] = piRender(thisR,varargin)
% Read a PBRT V2 scene file, run the docker cmd locally, return the ieObject.
%
% Syntax:
%  [oi or scene or depth map] = piRender(thisR,varargin)
%
% REQUIRED input
%  thisR - A recipe, whose outputFile specifies the file, OR a string that
%          is a full path to a scene pbrt file.
%
% OPTIONAL input parameter/val
%  renderType - render radiance, depth or both (default).  If the input is
%               a fullpath to a file, then we only render the radiance
%               data. Ask if you want this changed to permit a depth map.
%  vesion - which version of PBRT to render with 
%
% RETURN
%   ieObject - an ISET scene. oi, or a depth map image
%
% Examples:
%
%  Scene files are in pbrt-v2-spectral on wandell's home account.  We
%  will start putting them up on the RdtClient server before too long.
%  We want to figure out the format and neatening, first.
%
%   sceneFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/bunny.pbrt';
%   sceneFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/bump-sphere.pbrt';
%   sceneFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/rtbSanmiguel.pbrt';
%   sceneFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/rtbTeapot-metal.pbrt';
%   sceneFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/rtbVilla-daylight.pbrt';
%
%
% TL SCIEN Stanford, 2017

% Examples 
%{
   % Example 1 - run the docker container
   sceneFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/rtbVilla-daylight.pbrt';
   [scene, outFile] = piRender(sceneFile);
   ieAddObject(scene); sceneWindow; sceneSet(scene,'gamma',0.5);
%}
%{
   % Example 2 - read the radiance file into an ieObject
   % We are pretending in this case that it was created with a lens
   radianceFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/bunny.dat';
   photons = piReadDAT(radianceFile, 'maxPlanes', 31);
   oi = piOIcreate(photons);
   ieAddObject(oi); oiWindow;
%}
%{
   % Example 3 - render an existing pbrt file
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

rTypes = {'radiance','depth','both'};
p.addParameter('rendertype','both'); 

p.addParameter('version',2,@(x)isnumeric(x));

p.parse(thisR,varargin{:});
renderType = p.Results.rendertype;
version = p.Results.version;

if ischar(thisR)
    % In this case, we are just rendering a pbrt file.  No depthFile.
    % We could do more/better in the future.  The directory containing the
    % pbrtFile will be mounted.
    pbrtFile = thisR;
    
    % Figure out this optics type of the file
    thisR = piRead(pbrtFile);
    opticsType = thisR.get('optics type');

    if ~strcmp(renderType,'radiance')
        warning('For a file name input, we only render radiance');
        renderType = 'radiance';
    end
    
    [workingFolder, name, ~] = fileparts(pbrtFile);
    if(isempty(workingFolder))
        error('We need an absolute path for the working folder.');
    end
    
elseif isa(thisR,'recipe')
    %% Set up the working folder that will be mounted by the Docker image
    
    opticsType = thisR.get('optics type');
    
    % Set up the radiance file
    [workingFolder, name, ~] = fileparts(thisR.outputFile);
    if(~exist(workingFolder,'dir'))
        error('We need an absolute path for the working folder.');
    end
    pbrtFile = thisR.outputFile;

    % Set up the depth file
    if strcmp(renderType,'both') || strcmp(renderType,'depth')
        
        % Write out a pbrt file with depth
        % depthFile   = fullfile(workingFolder,strcat(name,'_depth.pbrt'));
        depthRecipe = piRecipeConvertToDepth(thisR);
        
        % Always overwrite the depth file, but don't copy over the whole directory
        piWrite(depthRecipe,'overwritefile',true,'overwritedir',false);
        
        depthFile = depthRecipe.outputFile;
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
        filesToRender{2} = depthFile;
        label{2} = 'depth';
    case {'depth','depthmap'}
        filesToRender = {depthFile};
        label{1} = 'depth';
    case {'radiance'}
        filesToRender = {pbrtFile};
        label{1} = 'radiance';
    otherwise
        error('Cannot recognize render type.');
end

% We need these to avoid errors further down.
depthMap = [];
photons = []; 

for ii = 1:length(filesToRender)
    
    currFile = filesToRender{ii};
    
    %% Build the docker command
    dockerCommand   = 'docker run -ti --rm';
    
    if(thisR.version == 3 || version == 3)
        dockerImageName = 'vistalab/pbrt-v3-spectral';
    else
        dockerImageName = 'vistalab/pbrt-v2-spectral';
    end
    
    [~,currName,~] = fileparts(currFile);
    
    outFile = fullfile(workingFolder,[currName,'.dat']);
    renderCommand = sprintf('pbrt --outfile %s %s', ...
        outFile, currFile);
    
    % Not sure why this is not needed here, or it is needed in RtbPBRTRenderer.
    % if ~isempty(user)
    %     dockerCommand = sprintf('%s --user="%s":"%s"', dockerCommand, user, user);
    % end
    
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
        disp(result)
        pause;
    end
    % Used to have an else condition here
    % fprintf('Docker run status %d, seems OK.\n',status);
    % fprintf('Outfile file: %s.\n',outFile);
    
    
    %% Convert the radiance.dat to an ieObject

    if ~exist(outFile,'file')
        warning('Cannot find output file %s. Searching pbrt file for output name... \n',outFile);
        
        thisR = piRead(pbrtFile);
        
        if(isfield(thisR.film,'filename'))
            name = thisR.film.filename.value;
            [~,name,~] = fileparts(name); % Strip the extension (often EXR)
            warning('Output file name was %s. \n',name);
            
            [path,~,~] = fileparts(pbrtFile);
            outFile = fullfile(path,strcat(name,'.dat'));
            
        else
            error('Cannot find output file. \n');
        end
        
    end
        
    % Depending on what we rendered, we assign the output data to
    % photons or depth map.
    if(strcmp(label{ii},'radiance'))
        photons = piReadDAT(outFile, 'maxPlanes', 31);
    elseif(strcmp(label{ii},'depth'))
        tmp = piReadDAT(outFile, 'maxPlanes', 31);
        depthMap = tmp(:,:,1); clear tmp;
    end
    
    fprintf('*** Rendering time for %s:  %.1f sec ***\n\n',currName,elapsedTime);

end

%% Read the data and set some of the ieObject parameters

ieObjName = sprintf('%s-%s',name,datestr(now,'mmm-dd,HH:MM'));

% Only return the depth map
if(strcmp(renderType,'depth'))
    % Could create a dummy object (empty) and put the depth map in that.
    ieObject = depthMap; % not technically an ieObject...
    return;
end

% If radiance, return a scene or optical image
switch opticsType 
    case 'lens'
        % If we used a lens, the ieObject is an optical image (irradiance).
        
        % We should set fov or filmDiag here.  We should also set other ray
        % trace optics parameters here. We are using defaults for now, but we
        % will find those numbers in the future from inside the radiance.dat
        % file and put them in here.
        ieObject = piOICreate(photons,varargin{:});  % Settable parameters passed
        ieObject = oiSet(ieObject,'name',ieObjName);
        % I think this should work (BW)
        if(~isempty(depthMap))
            ieObject = oiSet(ieObject,'depth map',depthMap);
        end
        
        % This always worked in ISET, but not in ISETBIO.  So I stuck in a
        % hack to ISETBIO to make it work there temporarily and created an
        % issue. (BW).
        ieObject = oiSet(ieObject,'optics model','ray trace');
    
    case 'pinhole'
        % In this case, we the radiance describes the scene, not an oi
        ieObject = piSceneCreate(photons,'meanLuminance',100);
        ieObject = sceneSet(ieObject,'name',ieObjName);
        if(~isempty(depthMap))
            ieObject = sceneSet(ieObject,'depth map',depthMap);
        end
        
        % There may be other parameters here in this future
        if strcmp(thisR.get('optics type'),'pinhole')
            ieObject = sceneSet(ieObject,'fov',thisR.get('fov'));
        end
end

end