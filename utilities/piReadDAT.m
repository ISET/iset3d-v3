function [imageData, imageSize, lens] = piReadDAT(filename, varargin)
%% Read multispectral data from a .dat file (Stanford format)
%
%   [imageData, imageSize, lens] = piReadDAT(filename)
%
% Required Input
%   filename - existing .dat file
%
% Optional parameter/val
%   maxPlanes -
%
% Returns
%  
% Reads multi-spectral .dat image data from the fiven filename.  The .dat
% format is described by Andy Lin on the Stanford Vision and Imaging
% Science and Technology wiki:
%   http://white.stanford.edu/pdcwiki/index.php/PBRTFileFormat
%
% imageData = piReadDAT(filename, 'maxPlanes', maxPlanes)
% Reads image data from the given file, and limits the number of returned
% spectral planse to maxPlanes.  Any additional planes are ignored.
%
% Returns a matrix of multispectral image data, with size [height width n],
% where height and width are image size in pixels, and n is the number of
% spectral planes. Also returns the multispectral image dimensions [height
% width n].
%
% If the given .dat file contains an optional lens description, also
% returns a struct of lens data with fields focalLength, fStop, and
% fieldOfView.
%
%%% RenderToolbox4 Copyright (c) 2012-2016 The RenderToolbox Team.
%%% About Us://github.com/RenderToolbox/RenderToolbox4/wiki/About-Us
%%% RenderToolbox4 is released under the MIT License.  See LICENSE file.

%%
parser = inputParser();
parser.addRequired('filename', @ischar);
parser.addParameter('maxPlanes', [], @isnumeric);

parser.parse(filename, varargin{:});
filename = parser.Results.filename;
maxPlanes = parser.Results.maxPlanes;

% imageData = [];
% imageSize = [];
lens = [];

%% Open the file.
% fprintf('Opening file "%s".\n', filename);
[fid, message] = fopen(filename, 'r');
if fid < 0,  error(message); end

%% Read header line to get image size

sizeLine = fgetl(fid);
dataPosition = ftell(fid);
[imageSize, count, err] = lineToMat(sizeLine);
if count ~=3
    fclose(fid);
    error('Could not read image size: %s', err);
end
wSize = imageSize(1);
hSize = imageSize(2);
nPlanes = imageSize(3);
imageSize = [hSize, wSize, nPlanes];

fprintf('  Reading image h=%d x w=%d x %d spectral planes.\n', ...
    hSize, wSize, nPlanes);

%% Optional second header line might contain realistic lens info.
pbrtVer = 2; % By default, we assume this is a version 2 file
headerLine = fgetl(fid);
[lensData, count, err] = lineToMat(headerLine); %#ok<ASGLU>
if count == 3
    dataPosition = ftell(fid);
    lens.focalLength = lensData(1);
    lens.fStop = lensData(2);
    lens.fieldOfView = lensData(3);
    fprintf('  Found lens data focalLength=%d, fStop=%d, fieldOfView=%d.\n', ...
        lens.focalLength, lens.fStop, lens.fieldOfView);
elseif (~isempty(strfind(headerLine,'v3')))
        % If in the header line we get a 'v3' flag, we know its a version 3
        % output file. 
        dataPosition = ftell(fid);
        pbrtVer = 3;
end

%% Read the remainder of the .dat file into memory

fseek(fid, dataPosition, 'bof');
serializedImage = fread(fid, inf, 'double');
fclose(fid);

fprintf('  Read %d pixel elements for image.\n', numel(serializedImage));

% Check size
if numel(serializedImage) ~= prod(imageSize)
    error('Image should have %d pixel elements.\n', prod(imageSize))
end

%% Reshape the serialized data to image dimensions

% Depending on the PBRT version, we reshape differently. This is due to
% inherent difference in how v2 and v3 store the final image data. It is
% much easier to do the reshape here than to change v3 to write out in the
% same way v2 writes out. 
if(pbrtVer == 2)
    imageData = reshape(serializedImage, hSize, wSize, nPlanes);
elseif(pbrtVer == 3)
    imageData = reshape(serializedImage, wSize, hSize, nPlanes);
    imageData = permute(imageData,[2 1 3]);
end

if ~isempty(maxPlanes) && maxPlanes < nPlanes
    fprintf('  Limiting %d planes to maxPlanes = %d.\n', imageSize(3), maxPlanes);
    imageSize(3) = maxPlanes;
    imageData = imageData(:, :, 1:maxPlanes);
end

% fprintf('OK.\n');

end

%%
function [mat, count, err] = lineToMat(line)
% is it an actual line?
if isempty(line) || (isscalar(line) && line < 0)
    mat = [];
    count = -1;
    err = 'Invalid line.';
    return;
end

% scan line for numbers
[mat, count, err] = sscanf(line, '%f', inf);

end
