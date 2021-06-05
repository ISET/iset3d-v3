function materialList = piMaterialRead(thisR, fname,varargin)
%% Read and return a list of materials
%
% Synopsis:
%   materialList = piReadMaterial(fname,varargin)
%
% Brief description:
%   Parses a *_material.pbrt file written by the PBRT Cinema 4D exporter
%
% Inputs
%   thisR   - recipe .
%   fname   - material pbrt file path. 
%
% Returns:
%   materials: Array of material structs
%
% Description
%   PBRT version 3 has a nice FBX exporter (Cinema 4D format).  We read
%   that file here so we can adjust the material properties within
%   Matlab.
%   The material text lines will be parsed as a cell array with properties
%   parsed in struct.
%
% ZL SCIEN Stanford, 2018
% ZLY SCIEN Stanford, 2020
%
% See also:
%   piBlockExtract, piWriteMaterial
   
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
if ~isempty(materialLines)
    materialList = piBlockExtractMaterial(thisR, materialLines);
else
    materialList = {};
end

end


