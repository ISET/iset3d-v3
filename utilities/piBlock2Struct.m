% DEPRECATED
function s = piBlock2Struct(blockLines,varargin)
% Parse a block of scene file text (e.g. from piExtractBlock) and
% return it as a structure 
%
%  s = piBlock2Struct(blockLines,varargin)
%
% Required input
%   blockLines - a block of text from the top of a scene.pbrt file
% 
% Return
%   s -  a struct containing the critical information from the block
%   of text.
%
% We take advantage of the regular structure of the PBRT file
% (assuming it is "well structured") and use regular expressions to
% extract values within.
%
% Example
%  txtLines     = piRead('/home/wandell/pbrt-v2-spectral/pbrt-scenes/sanmiguel.pbrt');
%  cameraBlock  = piBlockExtract(txtLines,'blockName','camera')
%  cameraStruct = piBlock2Struct(cameraBlock)
%
% TL Scienstanford 2017

%% Programming TODO
%
% TODO: The struct converter doesn't quite capture all the variations it
% needs to. For example, the spectrum type can be a string filename of a
% spd file, but it can also be a vector that directly describes the spd
% (e.g. [400 800 1])
%

%%
p = inputParser;
p.addRequired('blockLines',@(x)(iscell(blockLines) && ~isempty(blockLines)));
p.parse(blockLines,varargin{:});

%% Go through the text block, line by line, and try to extract the parameters

nLines = length(blockLines);

% Get the main type/subtype of the block (e.g. Camera: pinhole or
% SurfaceIntegrator: path)
% TL Note: This is a pretty hacky way to do it, you can probably do the
% whole thing in one line using regular expressions.
C = textscan(blockLines{1},'%s');
blockType = C{1}{1};
C = regexp(blockLines{1}, '(?<=")[^"]+(?=")', 'match');
blockSubtype = C{1};

% Set the main type and subtype
s = struct('type',blockType,'subtype',blockSubtype);

% Get all other parameters within the block
% Generally they are in the form: 
% "type name" [value] or "type name" "value"
for ii = 2:nLines
    
    currLine = blockLines{ii};
    
    % Find everything between quotation marks ("type name")
    C = regexp(currLine, '(?<=")[^"]+(?=")', 'match');
    C = strsplit(C{1});
    valueType = C{1};
    valueName = C{2};
    
    % Get the value corresponding to this type and name
    if(strcmp(valueType,'string') || strcmp(valueType,'bool'))
        % Find everything between quotation marks
        C = regexp(currLine, '(?<=")[^"]+(?=")', 'match');
        value = C{3};
    elseif(strcmp(valueType,'spectrum'))
       %{ 
         TODO:
         Spectrum can either be a spectrum file "xxx.spd" or it can be a
         series of four numbers [wave1 wave2 value1 value2]. There might
         be other variations, but we should check to see if brackets exist
         and to read numbers instead of a string if they do.
       %}
        % Find everything between quotation marks
        C = regexp(currLine, '(?<=")[^"]+(?=")', 'match');
        value = C{3};
    elseif(strcmp(valueType,'float') || strcmp(valueType,'integer'))
        % Find everything between brackets
        value = regexp(currLine, '(?<=\[)[^)]*(?=\])', 'match', 'once');
        value = str2double(value);
    elseif(strcmp(valueType,'rgb'))
        % TODO: Find three values between the brackets, e.g. [r g b]
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
    
    % Set this value and type as a field in the structure
    [s.(valueName)] = struct('value',value,'type',valueType);
    
end


end
