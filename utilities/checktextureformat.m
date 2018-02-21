function checktextureformat(directory)
% convert all jpg texture to png format.
currentfolder = pwd;
cd(directory)
imagefiles = dir('*.jpg');
if ~isempty(imagefiles)
nfiles = length(imagefiles);
for ii=1:nfiles
   currentfilename = imagefiles(ii).name;
   currentimage = imread(currentfilename);
   currentname = erase(imagefiles(ii).name,".jpg");
   output = sprintf('%s.png',currentname);
   imwrite(currentimage,output);
   fprintf('All jpg files are converted \n')
end
else
    fprintf('No jpg files to be converted \n')
end
cd(currentfolder)
end