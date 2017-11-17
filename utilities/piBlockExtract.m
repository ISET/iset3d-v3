function blockLines = piBlockExtract(txtLines,varargin)
% piBlockExtract - Extract text blocks that correspond to the given keyword.
%
% Syntax
%   blockLines = piBlockExtract(txtLines,varargin)
% 
% Input
%   txtLines - Cell array of text lines, usually from piRead
% 
% Optional parameters
%   'blockName' - A string defining the block.  Case insensitivie????
%
% Return
%   blockLines - Cell array of text lines in the block
%
% Examples in source
%
% TL Scienstanford 2017

% Examples
%{
   txtLines = piRead('/home/wandell/pbrt-v2-spectral/pbrt-scenes/sanmiguel.pbrt');
   cameraBlock = piExtractBlock(txtLines,'blockName','camera')
%}


%%  Identify the blockname.  

p = inputParser;
p.addRequired('txtLines',@(x)(iscell(txtLines) && ~isempty(txtLines)));
addParameter(p,'blockName','Camera',@ischar);
p.parse(txtLines,varargin{:});

blockName = p.Results.blockName;

%% Extract lines that correspond to specified keyword

blockBegin = []; blockEnd = [];
nLines = length(txtLines);
for ii=1:nLines
    thisLine = txtLines{ii};
    if length(thisLine) >= length(blockName)
        % The line is long enough, so compare if it starts with the blockname
        if strncmp(thisLine,blockName,length(blockName))
            % It does, so this is the start
            blockBegin = ii;
            % Keep adding lines whose first symbol is a double quote (")
            for jj=(ii+1):nLines
                if isempty(txtLines{jj}) || ~isequal(txtLines{jj}(1),'"') % isempty(txtLines{jj})
                    % Some other character, so get out.
                    blockEnd = jj;
                    break;
                end
            end
        end
    end
end

% If not blockBegin/End return empty
blockLines = [];  

% Otherwise, return the textlines
if(~isempty('blockBegin') && ~isempty('blockEnd'))
    blockLines = txtLines(blockBegin:(blockEnd-1));
end


end
