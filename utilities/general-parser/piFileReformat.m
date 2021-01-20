function piFileReformat(fname,varargin)
%% format a pbrt file from arbitrary source to standard format
varargin =ieParamFormat(varargin);

p = inputParser;
p.addRequired('fname',@(x)(exist(fname,'file')));
p.addParameter('output',@ischar);

p.parse(fname,varargin{:});
outfile = p.Results.output;
[host_volume, ~, ~]=fileparts(outfile);
%% convert %s mkdir mesh && cd mesh &&
basecmd = 'docker run -t --volume="%s":"%s" %s pbrt --toply %s';
[volume, ~, ~]=fileparts(fname);
dockerimage = 'vistalab/pbrt-v3-spectral:latest';
% copy .ply files from docker to host

%%
dockercmd = sprintf(basecmd, volume, volume, dockerimage, fname);
[status_convert,result]=system(dockercmd);

if contains(result, 'Warning: No metadata written out.')
    result = erase(result, 'Warning: No metadata written out.');
end
%% get docker container id
[~, containers] = system('docker ps -a');
containers = textscan(containers,'%q');
containers =containers{1};
containerId = containers{9};
%% reformated output is saved in result, write the result in output file
fid = fopen(outfile,'w+');
fprintf(fid, result);
fclose(fid);
for ii = 1:5000
    cpcmd = sprintf('docker cp %s:/pbrt/pbrt-v3-spectral/build/mesh_%05d.ply %s',containerId, ii, host_volume);
    [status_copy,~]=system(cpcmd);
    if status_copy
        break;
    end
end
% tell user there is something wrong.
if status_convert
    disp('Reformating file failed.');
    disp(result);
else
    fprintf('File is formated as %s \n', outfile);
end
% remove container
rmCmd = sprintf('docker rm %s',containerId);
[~, results]=system(rmCmd);

end