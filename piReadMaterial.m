function [materialR,txtLines] = piReadMaterial(fname,varargin)
% piReadMaterial parses a *_material.pbrt file

p = inputParser;
p.addRequired('fname',@(x)(exist(fname,'file')));
p.addParameter('version',2,@(x)isnumeric(x));
p.parse(fname,varargin{:});

ver = p.Results.version;

materialR = recipe;
materialR.inputFile = fname;

%% Check version number
if(ver ~= 3)
    error('PBRT version number incorrect. Only version 3 is supported now.');
else
    materialR.version = ver;
end

%% Read PBRT file

% Open, read, close
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n','CommentStyle',{'#'});
txtLines = tmp{1};

fclose(fileID);

%% Find NamedMaterial
%Material = piBlockExtract(txtLines,'blockName','MakeNamedMaterial');
%% Extract lines that correspond to specified keyword
blockName = 'MakeNamedMaterial';
materialR = materialExtract(txtLines,blockName);


