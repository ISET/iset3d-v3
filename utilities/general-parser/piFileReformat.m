function outputFull = piFileReformat(fname,varargin)
%% format a pbrt file from arbitrary source to standard format
%
% Syntax:
%    outputFull = piFileReformat(fname,varargin)
%
% Brief
%    PBRT V3 files can appear in many formats.  This function uses the PBRT
%    docker container to read those files and write out the equivalent PBRT
%    file in the standard format.  It does this by calling PBRT with the
%    'toply' switch.  So PBRT reads the existing data, converts any meshes
%    to ply format, and writes out the results.
%
% Input
%   fname: The file name of the PBRT scene file.
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
pi
%}

%% Parse

% Force to no spaces and lower case
varargin = ieParamFormat(varargin);

% fname can be the full file name.  But it is only required that it be
% found.
p = inputParser;
p.addRequired('fname',@(x)(exist(fname,'file')));
[~,thisName,ext] = fileparts(fname);
p.addParameter('outputfull',fullfile(piRootPath,'local','formatted',thisName,[thisName,ext]),@ischar);

p.parse(fname,varargin{:});
outputFull = p.Results.outputfull;

%% convert %s mkdir mesh && cd mesh &&

% The Docker base command includes 'toply'.  In that case, it does not
% render the data, it just converts it.
basecmd = 'docker run -t --volume="%s":"%s" %s pbrt --toply %s';

% basecmd = 'docker run -t --volume="%s":"%s" %s pbrt --toply %s > outputFile';

% The directory of the input file
[volume, ~, ~] = fileparts(fname);

% Which docker image we run
dockerimage = 'vistalab/pbrt-v3-spectral:latest';

%% Build the command

dockercmd = sprintf(basecmd, volume, volume, dockerimage, fname);
disp(dockercmd)

%% Run the command

% The variable 'result' has the formatted data.  For some reason, PBRT does
% not output the data directly to files.
[status_convert, result] = system(dockercmd);

if ~status_convert
    % Status is good.  So do stuff
    
    % We put this warning in.  We do not want it stored as part of the
    % conversion, so we erase it.
    if contains(result, 'Warning: No metadata written out.')
        result = erase(result, 'Warning: No metadata written out.');
    end
    
    %% Get docker container id
    
    % All the running docker containers are listed in containers
    [~, containers] = system('docker ps -a');
    
    % We need the container ID later.  If we only have one container running,
    % this will work.  If we happen to be running multiple containers, that
    % could be a problem.  We can check at some point.
    containers  = textscan(containers,'%q');
    containers  = containers{1};
    containerId = containers{9};
    
    %% Save the reformatted data in 'result'
    
    [outputDir, ~, ~] = fileparts(outputFull);
    
    fid = fopen(outfile,'w+');
    fprintf(fid, result);
    fclose(fid);
    
    % Would something like this run ?
    %
    %   docker ls %s:/pbrt/pbrt-v3-spectral/build/mesh_*.ply
    %
    
    for ii = 1:5000
        cpcmd = sprintf('docker cp %s:/pbrt/pbrt-v3-spectral/build/mesh_%05d.ply %s',containerId, ii, outputDir);
        [status_copy, ~ ] = system(cpcmd);
        if status_copy
            % If it fails we assume that is because there is no corresponding
            % mesh file.  So, we stop.
            break;
        end
    end
    fprintf('File is formated as %s \n', outfile);
    
    % tell user there is something wrong.
else
    % Status failed.  So tell the user and go home.
    disp('Reformating file failed.');
    disp(result);    
end

%% Either way, stop the container if it is still running.

rmCmd = sprintf('docker rm %s',containerId);
[~, results] = system(rmCmd);

disp(results)

end