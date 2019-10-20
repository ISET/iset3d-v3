function matrixData = piSpdFileRead(inputFile,varargin)
% Synopsis:
%   matrixData = piSpdFileRead(inputFile)
%
% Description:
%   Read in an SPD text file understood by PBRT and return a matrix.%
%
% Inputs:
%   inputFile        -  String. SPD filename.
%
% Outputs:
%   matrixData       -  Two columns. First is wavelength in nm, second is
%                       spectral value.
%
% Optional key/value pairs:
%   None.
%
% See also: piSpdFileWrite.

% History:
%   10/20/19  dhb  Wrote it.

%% Parse input, follow iset conventions about case and spaces.
p = inputParser;
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin = ieParamFormat(varargin);
end
p.addRequired('inputFile',@ischar);
p.parse(inputFile,varargin{:});

%% Read the file
%
% There must be a simpler way to load a matrix from a text file,
% but whatever.
fileID = fopen(inputFile,'r');
matrixDataCell = textscan(fileID,'%f %f');
fclose(fileID);
matrixData(:,1) = matrixDataCell{1};
matrixData(:,2) = matrixDataCell{2};

end
