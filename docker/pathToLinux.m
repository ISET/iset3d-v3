function output = pathToLinux(inputPath)

if ispc
    % Windows PC
    if isequal(fullfile(inputPath), inputPath)
        % assume we have a drive letter
        output = inputPath(3:end);
        output = strrep(output, '\','/');
    else
        output = strrep(inputPath, '\','/');
    end
else
    output = inputPath;    
end

return;

