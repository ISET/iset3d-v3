function outputFull = piPBRTReformat(fname,varargin)
%% format a pbrt file from arbitrary source to standard format
%
% Syntax:
%    outputFull = piPBRTReformat(fname,varargin)
%
% Brief
%    PBRT V3 files can appear in many formats.  This function uses the PBRT
%    docker container to read those files and write out the equivalent PBRT
%    file in the standard format.  It does this by calling PBRT with the
%    'toply' switch.  So PBRT reads the existing data, converts any meshes
%    to ply format, and writes out the results.
%
% Input
%   fname: The full path to the filename of the PBRT scene file.
%
% Key/val options
%   outputFull:  The full path to the PBRT scene file that we output
%                By default, this will be
%                   outputFull = fullfile(piRootPath,'local','formatted',sceneName,sceneName.pbrt)
%
% Example:
%    piPBRTReformat(fname);
%    piPBRTReformat(fname,'output full',fullfile(piRootPath,'local','formatted','test','test.pbrt')
% See also
%

% Examples:
%{
fname = fullfile(piRootPath,'data','V3','SimpleScene','SimpleScene.pbrt');
formattedFname = piPBRTReformat(fname);
%}

%% Parse

% Force to no spaces and lower case
varargin = ieParamFormat(varargin);

% fname can be the full file name.  But it is only required that it be
% found.
p = inputParser;
p.addRequired('fname',@(x)(exist(fname,'file')));
[inputdir,thisName,ext] = fileparts(fname);
p.addParameter('outputfull',fullfile(piRootPath,'local','formatted',thisName,[thisName,ext]),@ischar);

p.parse(fname,varargin{:});
outputFull = p.Results.outputfull;


[outputDir, ~, ~] = fileparts(outputFull);
if ~exist(outputDir,'dir')
    mkdir(outputDir);
end

% copy files from input folder to output folder
piCopyFolder(inputdir, outputDir);

%% convert %s mkdir mesh && cd mesh &&

% The Docker base command includes 'toply'.  In that case, it does not
% render the data, it just converts it.
% basecmd = 'docker run -t --name %s --volume="%s":"%s" %s pbrt --toply %s > %s && ls';
basecmd = 'docker run -ti --name %s --volume="%s":"%s" %s /bin/bash -c "pbrt --toply %s > %s; ls mesh_*.ply"';

% The directory of the input file
[volume, ~, ~] = fileparts(fname);

% Which docker image we run
dockerimage = 'vistalab/pbrt-v3-spectral:latest';
% Give a name to docker container
dockercontainerName = ['ISET3d-',thisName,'-',num2str(randi(200))];
%% Build the command
dockercmd = sprintf(basecmd, dockercontainerName, volume, volume, dockerimage, fname, [thisName, ext]);

% dockercmd = sprintf(basecmd, dockercontainerName, volume, volume, dockerimage, fname, outputFull);
% disp(dockercmd)

%% Run the command

% The variable 'result' has the formatted data.
[~, result] = system(dockercmd);

% Copy formatted pbrt files to local directory.
cpcmd = sprintf('docker cp %s:/pbrt/pbrt-v3-spectral/build/%s %s',dockercontainerName, [thisName, ext], outputDir);
[status_copy, ~ ] = system(cpcmd);
if status_copy
    disp('No converted file found.');
end

%% remove "Warning: No metadata written out."
% Do this only for the main pbrt file
if ~contains(outputFull,'_materials.pbrt') ||...
        ~contains(outputFull,'_geometry.pbrt')
    
    fileIDin = fopen(outputFull);
    outputFullTmp = fullfile(outputDir, [thisName, '_tmp',ext]);
    fileIDout = fopen(outputFullTmp, 'w');
    
    while ~feof(fileIDin)
        thisline=fgets(fileIDin);
        if ~contains(thisline,'Warning: No metadata written out.')
            fprintf(fileIDout, '%s', thisline);
        end
    end
    fclose(fileIDin);
    fclose(fileIDout);
    
    movefile(outputFullTmp, outputFull);
end
%%

% Status is good.  So do stuff
% find out how many ply mesh files are generated.
PLYmeshFiles = textscan(result, '%s');
PLYmeshFiles = PLYmeshFiles{1};
% PLYFolder    = fullfile(outputDir,'scene/PBRT/pbrt-geometry');
% 
% if ~exist(PLYFolder,'dir')
%     mkdir(PLYFolder);
% end

for ii = 1:numel(PLYmeshFiles)
    cpcmd = sprintf('docker cp %s:/pbrt/pbrt-v3-spectral/build/%s %s',dockercontainerName, PLYmeshFiles{ii}, outputDir);
    [status_copy, ~ ] = system(cpcmd);
    if status_copy
        % If it fails we assume that is because there is no corresponding
        % mesh file.  So, we stop.
        break;
    end
end
% fprintf('Formatted file is in %s \n', outputDir);



%% Either way, stop the container if it is still running.

% Try to get rid of the return from this system command.
rmCmd = sprintf('docker rm %s',dockercontainerName);
system(rmCmd);
%%
% In case there are extra materials and geometry files
% format scene_materials.pbrt and scene_geometry.pbrt, then save them at the
% same place with scene.pbrt
inputMaterialfname  = fullfile(inputdir,  [thisName, '_materials', ext]);
outputMaterialfname = fullfile(outputDir, [thisName, '_materials', ext]);
inputGeometryfname  = fullfile(inputdir,  [thisName, '_geometry',  ext]);
outputGeometryfname = fullfile(outputDir, [thisName, '_geometry',  ext]);

if exist(inputMaterialfname, 'file')
    piPBRTReformat(inputMaterialfname, 'outputfull', outputMaterialfname);
end

if exist(inputGeometryfname, 'file')
    piPBRTReformat(inputGeometryfname, 'outputfull', outputGeometryfname);
end

end

%% piCopyFolder
%{
% Changed to a utility function piCopyFolder
% Should be deleted after a while.
%
function copyFolder(inputDir, outputDir)
    sources = dir(inputDir);
    status  = true;
    for i=1:length(sources)
        if startsWith(sources(i).name(1),'.')
            % Skip dot-files
            continue;
        elseif sources(i).isdir && (strcmpi(sources(i).name,'spds') || strcmpi(sources(i).name,'textures'))
            % Copy the spds and textures directory files.
            status = status && copyfile(fullfile(sources(i).folder, sources(i).name), fullfile(outputDir,sources(i).name));
        else
            % Selectively copy the files in the scene root folder
            [~, ~, extension] = fileparts(sources(i).name);
            if ~(piContains(extension,'pbrt') || piContains(extension,'zip') || piContains(extension,'json'))
                thisFile = fullfile(sources(i).folder, sources(i).name);
                fprintf('Copying %s\n',thisFile)
                status = status && copyfile(thisFile, fullfile(outputDir,sources(i).name));
            end
        end
    end
    
    if(~status)
        error('Failed to copy input directory to docker working directory.');
    else
        fprintf('Copied resources from:\n');
        fprintf('%s \n',inputDir);
        fprintf('to \n');
        fprintf('%s \n \n',outputDir);
    end
end
%}