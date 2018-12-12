function rootPath=piRootPath()
% Return the path to the root iset directory
%
% This function must reside in the directory at the base of the pbrt2ISET
% directory structure.  It is used to determine the location of various
% sub-directories.
% 
% Example:
%   fullfile(p2iRootPath,'data')

rootPath=which('piRootPath');
% try
%     ls('-la','/opt/toolboxes')
% catch
%     error('Error on ls of /opt/toolboxes');
% end
% tbLocateToolbox('iset3d')

[rootPath,fName,ext]=fileparts(rootPath);

return
