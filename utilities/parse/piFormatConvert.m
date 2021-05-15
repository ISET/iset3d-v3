function [newlines] = piFormatConvert(txtLines)
% Format txtlines into a standard format.
nn=1;
nLines = numel(txtLines);

ii=1;
tokenlist = {'A', 'C' , 'F', 'I', 'L', 'M', 'N', 'O', 'P', 'R', 'S', 'T'};
txtLines = regexprep(txtLines, '\t', ' ');
while ii <= nLines
    thisLine = txtLines{ii};
    if ~isempty(thisLine)
        if length(thisLine) >= length('Shape')
            if any(strncmp(thisLine, tokenlist, 1)) && ...
                    ~strncmp(thisLine,'Include', length('Include')) && ...
                    ~strncmp(thisLine,'Attribute', length('Attribute'))
                % It does, so this is the start
                blockBegin = ii;
                % Keep adding lines whose first symbol is a double quote (")
                if ii == nLines
                    newlines{nn,1}=thisLine;
                    break;
                end
                for jj=(ii+1):nLines+1
                    if jj==nLines+1 || isempty(txtLines{jj}) || ~isequal(txtLines{jj}(1),'"')
                        if jj==nLines+1 || isempty(txtLines{jj}) || isempty(str2num(txtLines{jj}(1:2))) ||...
                                any(strncmp(txtLines{jj}, tokenlist, 1))
                            blockEnd = jj;
                            blockLines = txtLines(blockBegin:(blockEnd-1));
                            texLines=blockLines{1};
                            for texI = 2:numel(blockLines)
                                if ~strcmp(texLines(end),' ')&&~strcmp(blockLines{texI}(1),' ')
                                    texLines = [texLines,' ',blockLines{texI}];
                                else
                                    texLines = [texLines,blockLines{texI}];
                                end
                            end
                            newlines{nn,1}=texLines;nn=nn+1;
                            ii = jj-1;
                            break;
                        end
                    end
                    
                end
            else
                newlines{nn,1}=thisLine; nn=nn+1;
            end
        end
    end
    ii=ii+1;
end
newlines(piContains(newlines,'Warning'))=[];
end