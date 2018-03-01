function thisR = piReadv3(fname,varargin)
% 

%%
p = inputParser;
p.addRequired('fname',@(x)(exist(fname,'file')));
p.addParameter('version',2,@(x)isnumeric(x));
p.parse(fname,varargin{:});
ver = p.Results.version;
thisR = recipe;
thisR.inputFile = fname;

%% Check version number
if(ver ~= 3)
    error('Only PBRT version 3 Cinema 4D exporter is supported.');
end

%% Read the text from the fname

% Open, read, close
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n','CommentStyle',{'#'});
txtLines = tmp{1};
fclose(fileID);

fileID = fopen(fname);
tmp_1 = textscan(fileID,'%s','Delimiter','\n');
txtLines_1 = tmp_1{1};
fclose(fileID);
%% Extract lines that correspond to specified keyword if it's exported from PBRT exporter for Cinema 4D
if(isempty(piBlockExtractV3(txtLines,'blockName','Camera')))
    warning('Cannot find "camera" in PBRT file.');
    thisR.camera = struct([]); % Return empty.
else
    thisR.camera = piBlockExtractV3(txtLines,'blockName','Camera');
end

if(isempty(piBlockExtractV3(txtLines,'blockName','Sampler')))
    warning('Cannot find "Sampler" in PBRT file.');
    thisR.sampler = struct([]); % Return empty.
else
    thisR.sampler = piBlockExtractV3(txtLines,'blockName','Sampler');
end

if(isempty(piBlockExtractV3(txtLines,'blockName','Film')))
    warning('Cannot find "Film" in PBRT file.');
    thisR.film = struct([]); % Return empty.
else
    thisR.film = piBlockExtractV3(txtLines,'blockName','Film');
end

if(isempty(piBlockExtractV3(txtLines,'blockName','Integrator')))
    warning('Cannot find "Integrator" in PBRT file.');
    thisR.integrator = struct([]); % Return empty.
else
    thisR.integrator = piBlockExtractV3(txtLines,'blockName','Integrator');
end

end


