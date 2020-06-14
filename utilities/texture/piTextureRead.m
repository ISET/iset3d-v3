function [textureList, textureLines] = piTextureRead(thisR, fname, varargin)
% Read a texture file
%
% Synopsis
%   [textureList, textureLines] = piTextureRead(thisR, fname, varargin)
%
% Description
%   Read the textures.  When they are written out they are placed in the
%   materials file, so there is no piTextureWrite
%
% Inputs
%
% Optional key/val pairs
%   None
%
% Returns
%   textureList  - a cell array with the textures
%   textureLines - The text lines describing the texture
%
% See also
%  piGeometryRead
%

%% Parse inputs
p = inputParser;
p.addRequired('thisR', @(x)(isa(x, 'recipe')));
p.addRequired('fname', @(x)(exist(fname, 'file')));

p.parse(thisR, fname, varargin{:});

fname = p.Results.fname;

%% Gather texture lines

% Open, read, close
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n','CommentStyle',{'#'});
txtLines = tmp{1};
fclose(fileID);

textureLines = piTexturesFromText(txtLines);

if isempty(textureLines), textureList = [];
else, textureList  = piBlockExtractTexture(thisR, textureLines);
end

end






