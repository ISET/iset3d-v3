function outputFile = piSpdFileWrite(matFile, varargin)
% Write a .mat file into an SPD file to be used for PBRT.
%
% Syntax:
%   outputFile = piSpdFileWrite(matFile, [varargin])
%
% Description:
%    Take a .mat file (e.g. from isetcam/data/lights) and write it out into
%    a SPD text file to be used in PBRT.
%
% Inputs:
%    matFile    - String. The filename.
%
% Outputs:
%    outputFile - String. The output file's name.
%
% Optional key/value pairs:
%   None.
%

% History:
%    XX/XX/17  TL   Created 2017
%    03/25/19  JNM  Documentation pass

% Examples:
%{
    % Skipping uninitialized example
    % ETTBSkip
    spdFile = piSpdFileWrite(isetRootPath, 'data', ...
        'lights', 'equalEnergy.mat');
%}

%% Parse the input variables
p = inputParser;
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}) | ...
                isobject(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin = ieParamFormat(varargin);
end

p.addRequired('matFile', @ischar);

[path, name, ~] = fileparts(matFile);
p.addParameter('outputFilename', fullfile(path, [name '.spd']), @ischar);
p.parse(matFile, varargin{:});

outputFilename = p.Results.outputFilename;

%% Load the .mat file
if ~exist(matFile, 'file'), error('.mat file does not exist.'); end
load(matFile)

%% Create a new text file
% Start with text file extention - we will rename to .spd at the end.
[path, name, ~] = fileparts(outputFilename);
tmpFilename = fullfile(path, [name '.txt']);

fileID = fopen(tmpFilename, 'w');

for ii = 1:length(data)
    if mod(wavelength(ii), 0) %  Neater
        fprintf(fileID, '%d %f\n', wavelength(ii), data(ii));
    else
        fprintf(fileID, '%f %f\n', wavelength(ii), data(ii));
    end
end

fclose(fileID);

%% Rename to .spd extention
movefile(tmpFilename, outputFilename);
outputFile = outputFilename;

end
