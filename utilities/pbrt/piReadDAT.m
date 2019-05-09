function [imageData, imageSize, lens] = piReadDAT(filename, varargin)
% Read multispectral data from a .dat file (Stanford format)
%
% Syntax:
%   [imageData, imageSize, lens] = piReadDAT(filename, [varargin])
%
% Description:
%    Reads multi-spectral .dat image data from the fiven filename. The .dat
%    format is described by Andy Lin on the Stanford Vision and Imaging
%    Science and Technology wiki:
%       http://white.stanford.edu/pdcwiki/index.php/PBRTFileFormat
%
%    The function reads image data from the given file, and limits the
%    number of returned spectral planse to maxPlanes. Any additional planes
%    are ignored.
%
%    Returns a matrix of multispectral image data, size [height width n],
%    where height and width are image size in pixels, and n is the number
%    of spectral planes. Also returns the multispectral image dimensions
%    [height width n].
%
%    If the given .dat file contains an optional lens description, also
%    returns a structure of lens data with the fields focalLength, fStop,
%    and fieldOfView.
%
% Inputs:
%    filename  - String. The name of an existing .dat file.
%
% Outputs:
%    imageData - Matrix. The matrix containing the image data.
%    imageSize - Matrix. A 1x3 matrix containing the heigh, width, and
%                depth (n, number of spectral planes).
%    lens      - Struct. A structure containing lens information, including
%                the fields focalLength, fStop, and fieldOfView.
%
% Optional key/value pairs:
%   maxPlanes - Numeric. The maximum number of planes
%
% Notes:
%    * RenderToolbox4 Copyright (c) 2012-2016 The RenderToolbox Team.
%    * About Us://github.com/RenderToolbox/RenderToolbox4/wiki/About-Us
%    * RenderToolbox4 is released under the MIT License. See LICENSE file.
%

% History:
%    XX/XX/12  XXX  Created by the RenderToolbox Team
%    03/26/19  JNM  Documentation pass

%%
parser = inputParser();
parser.addRequired('filename', @ischar);
parser.addParameter('maxPlanes', 31, @isnumeric);

parser.parse(filename, varargin{:});
filename = parser.Results.filename;
maxPlanes = parser.Results.maxPlanes;

% imageData = [];
% imageSize = [];
lens = [];

%% Open the file.
% fprintf('Opening file "%s".\n', filename);
[fid, message] = fopen(filename, 'r');
if fid < 0, error(message); end

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
    fprintf(strcat('  Found lens data focalLength=%d, ', ...
        'fStop=%d, fieldOfView=%d.\n'), ...
        lens.focalLength, lens.fStop, lens.fieldOfView);
% elseif (~isempty(strfind(headerLine, 'v3')))
elseif contains(headerLine, 'v3')
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
    imageData = permute(imageData, [2 1 3]);
end

if ~isempty(maxPlanes) && maxPlanes < nPlanes
    fprintf('  Limiting %d planes to maxPlanes = %d.\n', ...
        imageSize(3), maxPlanes);
    imageSize(3) = maxPlanes;
    imageData = imageData(:, :, 1:maxPlanes);
end

% fprintf('OK.\n');

end

%%
function [mat, count, err] = lineToMat(line)
% Function designed to check the image size line contents in the file.
%
% Syntax:
%   [mat, count, err] = lineToMat(line)
%
% Description:
%    Check if it is an actual line.
%
% Inputs:
%    line  - String. A line from the file.
%
% Outputs:
%    mat   - Matrix. Matrix containing the data from the line.
%    count - Numeric. The number of items in the matrix. (Expect 3).
%    err   - String. The error message, if it exists.
%
% Optional key/value pairs:
%    None.
%
if isempty(line) || (isscalar(line) && line < 0)
    mat = [];
    count = -1;
    err = 'Invalid line.';
    return;
end

% scan line for numbers
[mat, count, err] = sscanf(line, '%f', inf);

end
