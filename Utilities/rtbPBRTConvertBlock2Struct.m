function s = rtbPBRTConvertBlock2Struct(blockLines,varargin)
% Given a block of text (e.g. from rtbPBRTExtractBlock),we do our best to
% parse it and convert into a structure. We take advantage of the regular
% structure of the PBRT file (assuming it is "well structured" to a certain
% degree) and use regular expressions to extract values within.

% Example
% txtLines = rtbPBRTRead('/home/wandell/pbrt-v2-spectral/pbrt-scenes/sanmiguel.pbrt');
% cameraBlock = rtbPBRTExtractBlock(txtLines,'blockName','camera')
% cameraStruct = rtbPBRTConvertBlock2Struct(cameraBlock)

% TL Scienstanford 2017


%%
p = inputParser;
p.addRequired('txtLines',@(x)(iscell(blockLines) && ~isempty(blockLines)));
p.parse(blockLines,varargin{:});

%% Extract lines that correspond to specified keyword

% Extract the parameters under the camera block and place in realistic eye
% structure
nLines = length(blockLines);

% Get the main type/subtype of the block (e.g. Camera: pinhole)
% TL Note: This is a pretty hacky way to do it, you can probably do the whole
% thing in one line using regular expressions.
C = textscan(blockLines{1},'%s');
type = C{1}{1};
C = regexp(blockLines{1}, '(?<=")[^"]+(?=")', 'match');
subtype = C{1};
s = struct('type',type,'subtype',subtype);

% Get all other parameters within the block
for ii = 2:nLines
    
    currLine = blockLines{ii};
    
    % Find everything between quotation marks
    C = regexp(currLine, '(?<=")[^"]+(?=")', 'match');
    C = strsplit(C{1});
    
    valueType = C{1};
    valueName = C{2};
    
    if(strcmp(valueType,'string') || strcmp(valueType,'bool') || strcmp(valueType,'spectrum'))
        % Find everything between quotation marks
        C = regexp(currLine, '(?<=")[^"]+(?=")', 'match');
        value = C{3};
    elseif(strcmp(valueType,'float') || strcmp(valueType,'integer'))
        % Find everything between brackets
        value = regexp(currLine, '(?<=\[)[^)]*(?=\])', 'match', 'once');
        value = str2double(value);
    end
    
    if(isempty(value))
        % Some types can potentially be
        % defined as a vector, string, or float. We have to be able to
        % catch all those cases. Take a look at the "Parameter Lists"
        % in this document to see a few examples:
        % http://www.pbrt.org/fileformat.html#parameter-lists
        fprintf('Value Type: %s \n',valueType);
        fprintf('Value Name: %s \n',valueName);
        fprintf('Line to parse: %s \n',currLine)
        error('Parser cannot find the value associated with this type. The parser is still incomplete, so we cannot yet recognize all type cases.');
    end
    
    [s.(valueName)]= value;
end


end
