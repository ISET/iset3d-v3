function [blockList, blockLinesList]  = piBlockExtract(txtLines,varargin)
% Parse text in a scene file, returning the info as a structure 
%
% Syntax
%   [s, blockLines] = piBlockExtract(txtLines,varargin)
%
% Description
%  Used extensively by piRead to parse specific types of text blocks within
%  a PBRT scene file.
% 
% Input
%   txtLines - Cell array of text lines
% 
% Optional parameters
%   'block name'    - A string defining the block.  In principle this can be
%                    any string.  In practice, there are several specific
%                    types of blocks we use a lot (see below).
%
%   'exporter' - if true, we use piBlockExtractC4D instead since
%                    the syntax given by the exporter is different.   
%
% Return
%   blockList           - a struct containing information from the block of text
%   blockLinesList
%   readSummary - Any warnings about unread sections returned here.
%
% Types of blocks we have tried to extract successfully, particularly with
% PBRT V3
%
%    'PixelFilter'
%    'SurfaceIntegrator'
%    'Integrator' (ver 2 'SurfaceIntegrator')
%    'Renderer'
%    'LookAt'
%    'Transform'
%    'ConcatTransform'
%    'Scale'
%    'Camera'
%    'Film'
%    'Sampler'
%
% TL Scienstanford 2017
%
% See also
%   piRead, piWrite, piBlockExtractC4D

%%  Identify the blockname.  

varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('txtLines',@(x)(iscell(txtLines) && ~isempty(txtLines)));

% We need a valid list of potential block names here.
addParameter(p,'blockname','Camera',@ischar);
p.parse(txtLines,varargin{:});

blockName = p.Results.blockname;

% Initialize


%% Extract lines that correspond to specified keyword

nLines = length(txtLines);
blockList=[]; blockLinesList=[];nn=1; 
for ii=1:nLines
    thisLine = txtLines{ii};
    if length(thisLine) >= length(blockName)
        % The line is long enough, so compare if it starts with the blockname
        if strncmp(thisLine,blockName,length(blockName))
            % It does, so this is the start
            blockBegin = ii;
            % Keep adding lines whose first symbol is a double quote (")
            for jj=(ii+1):nLines
                if isempty(txtLines{jj}) || ~isequal(txtLines{jj}(1),'"') || jj==nLines % isempty(txtLines{jj})
                    % Some other character, so get out.
                    if isempty(txtLines{jj}) || isempty(str2num(txtLines{jj}(1:2)))
                    blockEnd = jj;
                    blockLines = txtLines(blockBegin:(blockEnd-1));
                    blockLinesList{nn} = blockLines;
                    switch blockName
                        case {'MakeNamedMaterial','Material'}
                            blockList{nn} = parseBlockMaterial(blockLines);
                        case 'Texture'
                            blockList{nn} = parseBlockTexture(texLines,ii);
                        otherwise
                            blockList{nn} = parseBlock(blockLines, blockName);
                            blockLinesList{nn} = blockLines;
                    end
                    nn=nn+1;
                    break;
                end
                end
            end
        end
    end
end

if numel(blockList)==1 && ...
        ~(strcmp(blockName, 'Texture') || ...
        strcmp(blockName, 'MakeNamedMaterial'))
    blockList = blockList{1};
    blockLinesList = blockLinesList{1}; 
end
end

function s = parseBlock(blockLines, blockName)
%% If it's a transform, automatically return without parsing
s=[];
if(strcmp(blockName,'Transform') || ...
        strcmp(blockName,'LookAt')|| ...
        strcmp(blockName,'ConcatTransform')|| ...
        strcmp(blockName,'Scale'))
    return;
end
        
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
    
    if isempty(s)
        warning('No information found for block %s\n',blockName);
        s = struct([]);
    end

end
end

















