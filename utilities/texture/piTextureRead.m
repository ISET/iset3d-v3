function [textureList, textureLines] = piTextureRead(thisR, fname, varargin)
%
%% Parse inputs
p = inputParser;
p.addRequired('thiR', @(x)(isa(x, 'recipe')));
p.addRequired('fname', @(x)(exist(fname, 'file')));
p.addParameter('version', 3, @isnumeric);

p.parse(thisR, fname, varargin{:});

fname = p.Results.fname;
ver = p.Results.version;

%% Check version number
if (ver ~= 3)
    error('Only PBRT version 3 Cinema 4D exporter is supported.');
end

%% Read the text from the fname

% Open, read, close
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n','CommentStyle',{'#'});
txtLines = tmp{1};
fclose(fileID);

%% Gather texture lines

textureLines = piTexturesFromMaterialFileText(txtLines);
if isempty(textureLines), textureList = [];
else, textureList  = piBlockExtractTexture(thisR, textureLines);end
end


