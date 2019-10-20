function outputFile = piSpdFileWrite(matFile,varargin)
% Syntax:
%    outputFile = piSpdFileWrite(matFile)
%
% Description:
%    Take a .mat file (e.g. from isetcam/data/lights)
%    and write it out into a SPD text file to be used in PBRT. 
%
% Inputs:
%    matFile             - Matlab .mat file containing variables wavelength
%                          and data as vectors.
%
% Outputs:
%    outputFile          - Full path to written output file.
%
% Optional key/value pairs
%    'outputFilename'    - Path of output file. Default is matched to input
%                          file with .spd instead of .mat at end. If a
%                          matrix is passed, you need to provide something
%                          here.
%
% Examples
%   spdFile = piSpdFileWrite(fullfile(isetRootPath,'data','lights','equalEnergy.mat'));
% 
% TL 2017

%% Parse input, following iset conventions
p = inputParser;
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin =ieParamFormat(varargin);
end
p.addRequired('matFile',@(x) (ischar(x) || isnumeric(x)));

% Default output filename is where the input file lived, if
% an input filename is passed.  Otherwise just the empty string.
if (ischar(matFile))
    [path,name,~] = fileparts(matFile);
    p.addParameter('outputFilename',fullfile(path,[name '.spd']),@ischar);
else
    p.addParameter('outputFilename','',@ischar);
end
p.parse(matFile,varargin{:});

% Output filename
outputFilename = p.Results.outputFilename;
if (isempty(outputFilename))
    error('Need to pass an output filename as key/value pair to write a matrix');
end

%% Get the data
if (ischar(matFile))
    if(~exist(matFile,'file'))
        error('.mat file does not exist.');
    end
    load(matFile);
else
    wavelength = matFile(:,1);
    data = matFile(:,2);
end

%% Create a new text file
%
% Start with text file extention - we will rename to .spd at the end.
[path,name,~] = fileparts(outputFilename);
tmpFilename = fullfile(path,[name '.txt']);

fileID = fopen(tmpFilename,'w');
for ii = 1:length(data)
    if(mod(wavelength(ii),0))
        %  Neater
        fprintf(fileID,'%d %f\n',wavelength(ii),data(ii));
    else
        fprintf(fileID,'%f %f\n',wavelength(ii),data(ii));
    end       
end
fclose(fileID);

%% Rename to .spd extention
movefile(tmpFilename,outputFilename);
outputFile = outputFilename;

end
