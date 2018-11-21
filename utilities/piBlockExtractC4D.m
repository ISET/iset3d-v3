function [s,blockLines] = piBlockExtractC4D(txtLines,varargin)
%
p = inputParser;
p.addRequired('txtLines',@(x)(iscell(txtLines) && ~isempty(txtLines)));
addParameter(p,'blockName','Camera',@ischar);
p.parse(txtLines,varargin{:});

blockName = p.Results.blockName;
%%
nLetters = length(blockName);
nLines = length(txtLines);
blockLines = [];
s = [];

%% Parse the string on the material line

for ii=1:nLines
    thisLine = txtLines{ii}; 
    if strncmpi(thisLine,blockName,nLetters)
        
        % If it's a transform, automatically return without parsing
        if(strcmp(blockName,'Transform') || ...
                strcmp(blockName,'LookAt')|| ...
                strcmp(blockName,'ConcatTransform')|| ...
                strcmp(blockName,'Scale'))
            blockLines = {thisLine};
            return;
        end
        
        thisLine = textscan(thisLine,'%q');
        thisLine = thisLine{1};
        nStrings = length(thisLine);
        blockType = thisLine{1};
        blockSubtype = thisLine{2};
        s = struct('type',blockType,'subtype',blockSubtype);
        dd = 3;
        while dd <= nStrings
            if contains(thisLine{dd},' ')
                C = strsplit(thisLine{dd},' ');
                valueType = C{1};
                valueName = C{2};
            end
            value = thisLine{dd+1};
            
            % Convert value depending on type
            if(isempty(valueType))
                continue;
            elseif(strcmp(valueType,'string'))
                % Do nothing.
            elseif(strcmp(valueType,'float') || strcmp(valueType,'integer'))
                value = strrep(value,'[','');
                value = strrep(value,']','');
                value = str2double(value);
            else
                error('Did not recognize value type, %s, when parsing PBRT file!',valueType);
            end
            
            tempStruct = struct('type',valueType,'value',value);
            s.(valueName) = tempStruct;
            dd = dd+2;
        end
        blockLines = thisLine;
    end
end

% fprintf('Read %d materials on %d lines\n',cnt,nLines);

end