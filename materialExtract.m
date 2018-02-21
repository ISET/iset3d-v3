function materialR = materialExtract(txtLines,blockName)
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
            if ~(blockBegin == length(txtLines))
                if(~isempty('blockBegin') && ~isempty('blockEnd'))
                    for jj=(ii+1):nLines
                        if isempty(txtLines{jj}) || ~isequal(txtLines{jj}(1),'"') % isempty(txtLines{jj})
                            % Some other character, so get out.
                            blockEnd = jj;
                            break;
                        end
                    end
                    blockLines = txtLines(blockBegin:(blockEnd-1));
                end
            else
                blockLines = txtLines(blockBegin:blockBegin);
            end
            % Parse the block
            if ~isempty(blockLines)
                C = textscan(blockLines{1},'%q');
                C = C{1};
                valuetype = C{2};
                materialR.(valuetype) = blockLines{1};
            end
        end
    end
end
end


