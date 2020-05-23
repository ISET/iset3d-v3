function materialLines = piMaterialsFromFile(fname)
%% Read the text from the fname

% Open, read, close
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n','CommentStyle',{'#'});
txtLines = tmp{1};
fclose(fileID);

for ii = 1:size(txtLines)
    if ~isempty(txtLines(ii))
        if ~piContains(txtLines(ii),'MakeNamedMaterial')
            txtLines{ii}=[];
        end
    end
end

materialLines = txtLines(~cellfun('isempty',txtLines));
end