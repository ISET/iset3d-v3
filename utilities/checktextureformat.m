function checktextureformat(dir)
% convert all jpg texture to png format.
currentfolder = pwd;
cd(dir)
imagefiles = dir('*.jpg');
nfiles = length(imagefiles);
for ii=1:nfiles
   currentfilename = imagefiles(ii).name;
   currentimage = imread(currentfilename);
   currentname = erase(imagefiles(ii).name,".jpg");
   output = sprintf('%s.png',currentname);
   imwrite(currentimage,output);
end
cd(currentfolder)
end