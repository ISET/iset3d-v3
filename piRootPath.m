function rootPath = piRootPath()
% Return the path to the root iset directory
%
% Syntax:
%   rootPath = piRootPath()
%
% Description:
%    This function must reside in the directory at the base of the
%    pbrt2ISET directory structure. It is used to determine the location of
%    various sub-directories.
%
% Inputs:
%    None.
%
% Outputs:
%    rootPath - String. The full file path of the root path.
%
% Optional key/value pairs:
%    None.
%

% Examples:
%{
    fullfile(p2iRootPath, 'data')
%}

rootPath = which('piRootPath');
% try
%     ls('-la', '/opt/toolboxes')
% catch
%     error('Error on ls of /opt/toolboxes');
% end
% tbLocateToolbox('iset3d')

[rootPath, fName, ext] = fileparts(rootPath);

return
