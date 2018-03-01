function piTextureFileFormat(thisR)
% Convert any jpg textures to png format.
%
% TODO - We need to write a routine that converts any jpg file names
% in the PBRT files into png file names
%
% ZL Scien Stanford, 2018

%%
directory = fileparts(thisR.inputFile);
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
        currentname = erase(jpgFiles(ii).name,".jpg");
        output = sprintf('%s.png',currentname);
        imwrite(currentimage,output);
        % After writing the pngs, we erase the jpg file.
        original = sprintf('%s.jpg',currentname);
        delete(original);
    end
    fprintf('Converted %d jpg files.\n',numel(jpgFiles));
end

%%
cd(currentfolder)

end