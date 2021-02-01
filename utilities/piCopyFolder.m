function piCopyFolder(inputDir, outputDir)
% Selectively copies the special files from a PBRT folder
%
% Synopsis
%   piCopyFolder(inputDir, outputDir)
%
% Description
%
% Inputs:
%   inputDir
%   outputDir
%
% Returns
%   N/A
%
% See also
%

%% Find all the files in the input directory
sources = dir(inputDir);

%%
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

%% Could include a 'quiet' flag

if(~status)
    error('Failed to copy input directory to docker working directory.');
else
    fprintf('Copied resources from:\n');
    fprintf('%s \n',inputDir);
    fprintf('to \n');
    fprintf('%s \n \n',outputDir);
end

end