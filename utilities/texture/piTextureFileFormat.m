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
jpgFiles =  dir('*.jpg');
bmpFiles  = dir('*.bmp');
%% Convert the jpg files to png
if ~isempty(jpgFiles)
    nfiles = length(jpgFiles);
    for ii=1:nfiles
        % some hidden files might appear in dir as '._xxxxx.jpg', which we 
        % will delete.
        if isequal(jpgFiles(ii).name(1),'.')
            delete(jpgFiles(ii).name);
        else
            currentfilename = jpgFiles(ii).name;
            currentimage = imread(currentfilename);
            if piContains(jpgFiles(ii).name,'.JPG')
                currentname  = erase(jpgFiles(ii).name,'.JPG');
            elseif piContains(jpgFiles(ii).name,'.jpg')
                currentname  = erase(jpgFiles(ii).name,'.jpg');
            end
            output = sprintf('%s.png',currentname);
            imwrite(currentimage,output);
            % After writing the pngs, we erase the jpg file.
            original = sprintf('%s.jpg',currentname);
            delete(original);
        end
    end
    fprintf('Converted %d jpg files.\n',numel(jpgFiles));
% else
%     fprintf('No jpg files to be converted \n');
end
%% Convert the bump files to png
if ~isempty(bmpFiles)
    nfiles = length(bmpFiles);
    for ii=1:nfiles
        % some hidden files might appear in dir as '._xxxxx.jpg', which we 
        % will delete.
        if isequal(bmpFiles(ii).name(1),'.')
            delete(bmpFiles(ii).name);
        else
            currentfilename = bmpFiles(ii).name;
            currentimage = imread(currentfilename);
        if piContains(bmpFiles(ii).name,'.bmp')
            currentname  = erase(bmpFiles(ii).name,'.bmp');
        end
            output = sprintf('%s.png',currentname);
            imwrite(currentimage,output);
            % After writing the pngs, we erase the jpg file.
            original = sprintf('%s.bmp',currentname);
            delete(original);
        end
    end
    fprintf('Converted %d bmp files.\n',numel(bmpFiles));
end
%% Put all texture files in a seperate folder.

outputDir  = fileparts(thisR.outputFile);
textureDir = fullfile(outputDir,'textures');
textureFiles = dir('*.png'); 
if ~exist(textureDir,'dir')
    mkdir(textureDir);
end
for i=1:length(textureFiles)
    textureFileName=textureFiles(i).name;
    textureFilePath=textureFileName;
    copyfile(textureFilePath,fullfile(textureDir,textureFileName));
end
%%
cd(currentfolder)

end