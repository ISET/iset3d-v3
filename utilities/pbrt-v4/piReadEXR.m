function output = piReadEXR(filename, varargin)
%% Read multispectral data from a .exr file (Openexr format)
%
%   [imageData, imageSize, lens] = piReadEXR(filename)
%
% Required Input
%   filename - existing .exr file
%
% Optional parameter/val
%   dataType - specify the type of data for the output
%   NSpectrumSamples - number of spectrum samples
%
% Returns
%  
% Read .exr image data from the fiven filename.
%
%
% Zhenyi, 2020
% 
% Make sure openexr functions are compiled: 
%               (run make.m in ~/iset3d/ext/openexr)
% 
% Get exr channel information
%{
      data = exrinfo(filename);
      fprintf( '%s \n', data.channels{:} ); fprintf('\n')
%}   

%% 
parser = inputParser();
varargin = ieParamFormat(varargin);

parser.addRequired('filename', @ischar);
parser.addParameter('datatype', 'radiance', @ischar);

parser.parse(filename, varargin{:});
filename = parser.Results.filename;
dataType = parser.Results.datatype;

%%
data = exrinfo(filename);
size = double(data.size);

switch dataType
    case "radiance"
        RadianceIndex = find(strcmp(data.channels, 'Radiance.C01'));
        radianceContainerMap = exrreadchannels(filename, data.channels{RadianceIndex:RadianceIndex+30});
        image = cell2mat(values(radianceContainerMap));
        output = reshape(image, [size, 31]);
    case "zdepth"
        ZDepthIndex = find(strcmp(data.channels, 'Pz'));
        ZDepthMap = exrreadchannels(filename, data.channels{ZDepthIndex});
        output=ZDepthMap;
    case "3dcoordinates"
        CoordIndex = find(strcmp(data.channels, 'Px'));
        CoordMap = exrreadchannels(filename, data.channels{CoordIndex:CoordIndex+2});
        image = cell2mat(values(CoordMap));
        output = reshape(image, [size, 3]);
    case "material"
        matIndex = find(strcmp(data.channels, 'MaterialId'));
        matMap = exrreadchannels(filename, data.channels{matIndex});
        image = cell2mat(values(matMap));
        output=image;
    case "normal"
        NormIndex = find(strcmp(data.channels, 'Px'));
        NormMap = exrreadchannels(filename, data.channels{NormIndex:NormIndex+2});
        image = cell2mat(values(NormMap));
        output = reshape(image, [size, 3]);
    case "albedo"
        % to add; only support rgb for now, spectral albdeo needs to add;
    case "instance"
        % to add
    otherwise
        error('Datatype not supported. \n%s', 'Supported datatypes are: "radiance", "zdepth", "3dcoordinates", "material", "normal";')
end


end