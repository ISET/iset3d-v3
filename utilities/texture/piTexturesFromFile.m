function textureLines = piTexturesFromFile(fname)

%% Read the text from the fname

% Open, read, close
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n','CommentStyle',{'#'});
txtLines = tmp{1};
fclose(fileID);

for ii = 1:size(txtLines)
    if ~isempty(txtLines(ii))
        if ~piContains(txtLines(ii),'Texture')
            txtLines{ii}=[];
        end
    end
end
textureLines = txtLines(~cellfun('isempty',txtLines));

end