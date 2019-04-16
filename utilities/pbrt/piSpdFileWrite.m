function outputFile = piSpdFileWrite(matFile,varargin)
% piSpdFileWrite - Take a .mat file (e.g. from isetcam/data/lights)
% and write it out into a SPD text file to be used in PBRT. 
%
%  outputFile = piSpdFileWrite(param,varargin)
%
% Examples
%   spdFile = piSpdFileWrite(isetRootPath,'data','lights','equalEnergy.mat');
% 
% TL 2017

%%
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

p.addRequired('matFile',@ischar);

[path,name,~] = fileparts(matFile);
p.addParameter('outputFilename',fullfile(path,[name '.spd']),@ischar);

p.parse(matFile,varargin{:});

outputFilename = p.Results.outputFilename;

%% Load the .mat file

if(~exist(matFile,'file'))
    error('.mat file does not exist.');
end

load(matFile)

%% Create a new text file

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
