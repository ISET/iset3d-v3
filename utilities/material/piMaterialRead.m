function [materialList, materialLines] = piMaterialRead(thisR, fname,varargin)
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

%% Parse.  Only PBRT ver3 is supported
p = inputParser;
p.addRequired('thiR', @(x)(isa(x, 'recipe')));
p.addRequired('fname',@(x)(exist(fname,'file')));

p.parse(thisR, fname,varargin{:});

%% Extract lines that correspond to specified keyword

% Open, read, close
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n','CommentStyle',{'#'});
txtLines = tmp{1};
fclose(fileID);

materialLines = piMaterialsFromText(txtLines);
if isempty(materialLines), materialList = [];
else,materialList = piBlockExtractMaterial(thisR, materialLines);
end

end


