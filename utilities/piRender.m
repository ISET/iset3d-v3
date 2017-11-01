function [ieObject, outFile, result] = piRender(sceneFile,varargin)
% Read a PBRT V2 scene file, run the docker cmd locally, return the oi.
%
%    [oi or scene or depth map] = piRender(sceneFile,varargin)
%
% Input
%  sceneFile - required PBRT file.  The file should specify the
%              location of the auxiliary (include) data
%
% Optional input parameter/val
%  opticsType - lens or pinhole (default)
%  renderType - what type of image to render (both, depth, or radiance)
%
% Return
%   ieObject - an ISET scene or oi struct, possibly just a depth map image
%   outFile  - full path to the output file (maybe)
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
% Example code
%{
   % Example 1 - run the docker container
   sceneFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/rtbVilla-daylight.pbrt';
   [scene, outFile] = piRender(sceneFile,'opticsType','pinhole');
   ieAddObject(scene); sceneWindow;

   % Example 2 - read the radiance file into an ieObject
   % We are pretending in this case that it was created with a lens
   radianceFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/bunny.dat';
   photons = piReadDAT(radianceFile, 'maxPlanes', 31);
   oi = piOIcreate(photons);
   ieAddObject(oi); oiWindow;
%}
% TL/BW/AJ Scienstanford 2017

%% PROGRAMMING TODO
%
%  We should write a routine to append the required text for a Realistic Camera
%  and then run with a lens file
%
%  Should have an option to create the depth map
%

%%  Name of the pbrt scene file and whether we use a pinhole or lens model

p = inputParser;
p.addRequired('sceneFile',@(x)(exist(x,'file')));
p.addParameter('opticsType','pinhole',@ischar);
p.addParameter('renderType','both',@ischar);

p.parse(sceneFile,varargin{:});
opticsType = p.Results.opticsType;
renderType = p.Results.renderType;

%% Set up the working folder.  We need the absolute path.

[workingFolder, name, ~] = fileparts(sceneFile);
if(isempty(workingFolder))
    error('We need an absolute path for the working folder.');
end

%% Set up files to render, depending on 'renderType'
% We assume that piWrite already gave us a depth file with name
% xxx_depth.pbrt

depthFile = fullfile(workingFolder,strcat(name,'_depth.pbrt'));
filesToRender = {};
label = {};
switch renderType
    case {'both','all'}
        filesToRender{1} = sceneFile;
        label{1} = 'radiance';
        filesToRender{2} = depthFile;
        label{2} = 'depth';
    case {'depth','depthmap'}
        filesToRender = {depthFile};
        label{1} = 'depth';
    case {'radiance'}
        filesToRender = {sceneFile};
        label{1} = 'radiance';
    otherwise
        error('Cannot recognize render type.');
end

for ii = 1:length(filesToRender)
    
    currFile = filesToRender{ii};
    
    %% Build the docker command
    dockerCommand   = 'docker run -ti --rm';
    dockerImageName = 'vistalab/pbrt-v2-spectral';
    
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
    toc
    
    %% Check the return
    
    if status
        warning('Docker did not run correctly');
        disp(result)
        pause;
    else
        fprintf('Docker run status %d, seems OK.\n',status);
        fprintf('Outfile file was set to %s.\n',outFile);
    end
    
    %% Convert the radiance dat to an ieObject
    %
    % params.opticsType = 'pinhole;
    % ieObject = rtbDAT2ISET(outFile,params)
    if ~exist(outFile,'file')
        warning('Cannot find output file %s. Searching through pbrt file for output name... \n',outFile);
        
        recipe = piRead(sceneFile);
        
        if(isfield(recipe.film,'filename'))
            name = recipe.film.filename.value;
            [~,name,~] = fileparts(name); % Strip the extension (often EXR)
            warning('Output file name was %s. \n',name);
            
            [path,~,~] = fileparts(sceneFile);
            outFile = fullfile(path,strcat(name,'.dat'));
            
        else
            error('Cannot find output file. \n');
        end
        
    end
    
    outputData = piReadDAT(outFile, 'maxPlanes', 31);
    
    % Depending on what we rendered, we assign the output data to
    % photons or depth map.
    if(strcmp(label{ii},'radiance'))
        photons = outputData;
    elseif(strcmp(label{ii},'depth'))
        depthMap = outputData(:,:,1); 
    end
    
end

%% Read the data and set some of the ieObject parameters

photons = piReadDAT(outFile, 'maxPlanes', 31);
outName = [outName,datestr(datetime('now'))];
% Only return the depth map if that's all the user wanted.
if(strcmp(renderType,'depth'))
    ieObject = depthMap; % not technically an ieObject...
    return;
end

% Otherwise return a scene or optical image
switch opticsType
    case 'lens'
        % If we used a lens, then the ieObject should be the optical image
        % (irradiance data).
        %
        % We should set fov or filmDiag here.  We should also set other ray
        % trace optics parameters here. We are using defaults for now, but we
        % will find those numbers in the future from inside the radiance.dat
        % file and put them in here.
        ieObject = piOICreate(photons);
        ieObject = oiSet(ieObject,'name',outName);
        
        % I think this should work (BW)
        if(~isempty(depthMap))
            ieObject = oiSet(ieObject,'depth map',depthMap);
        end
        % ieObject = oiSet(ieObject,'optics model','ray trace');
    case 'pinhole'
        % In this case, we the radiance really describe the scene, not an oi
        ieObject = piSceneCreate(photons,'mean luminance',100);
        ieObject = sceneSet(ieObject,'name',outname);
        if(~isempty(depthMap))
            ieObject = sceneSet(ieObject,'depth map',depthMap);
        end
        % ieAddObject(ieObject); sceneWindow;  
end

%% Ask the system for the current user id.
% function uid = getUserId()
% [~, uid] = system('id -u `whoami`');
% uid = strtrim(uid);
% rtbRunDocker(cmd)
