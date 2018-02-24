function piTextureFileFormat(directory)
% Convert any jpg textures to png format.
%
% TODO - We need to write a routine that converts any jpg file names
% in the PBRT files into png file names
%
% ZL Scien Stanford, 2018

%%
currentfolder = pwd;
cd(directory)

%% Find any jpg file
jpgFiles = dir('*.jpg');
if isempty(jpgFiles)
    fprintf('No jpg files to be converted \n');
    return;
end

%% Convert the jpg files to png
if ~isempty(jpgFiles)
    nfiles = length(jpgFiles);
    for ii=1:nfiles
        currentfilename = jpgFiles(ii).name;
        currentimage    = imread(currentfilename);
        output = sprintf('%s.png',currentname);
        imwrite(currentimage,output);
        
        % After writing the pngs, we erase the jpg file.
        currentname = erase(jpgFiles(ii).name,".jpg");
    end
    fprintf('Converted %d jpg files.\n',numel(jpgFiles));
end

%%
cd(currentfolder)

end