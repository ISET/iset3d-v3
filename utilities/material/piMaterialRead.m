function [materiallist, txtLines] = piMaterialRead(fname,varargin)
% Parses a *_material.pbrt file written by the PBRT Cinema 4D exporter
%
% Syntax:
%   [materialR, txtLines] = piReadMaterial(fname,varargin)
%
% Description
%  PBRT version 3 has a nice FBX exporter (Cinema 4D format).  We read
%  that file here so we can adjust the material properties within
%  Matlab.
%
% Inputs
%  fname:  Text file 
%
% Outputs:
%  materials: Array of material structs
%  txtLines:  All the text in the file
%
% ZL SCIEN Stanford, 2018
%
% See also:
%   piBlockExtract, piWriteMaterial
   
%{
materials = piReadMaterial('carandbuilding_materials.pbrt','version',3);
%}

%%
p = inputParser;
p.addRequired('fname',@(x)(exist(fname,'file')));
p.addParameter('version',2,@(x)isnumeric(x));

p.parse(fname,varargin{:});

ver = p.Results.version;

%% Check version number
if(ver ~= 3)
    error('Only PBRT version 3 Cinema 4D exporter is supported.');
end

%% Read the text from the fname

% Open, read, close
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n','CommentStyle',{'#'});
txtLines = tmp{1};
fclose(fileID);

%% Extract lines that correspond to specified keyword
materiallist = piBlockExtractMaterial(txtLines);


%% pass materials to recipe.materials
% thisR = recipe;
% thisR.materials = materials;
% thisR.txtLines = txtLines;
end


