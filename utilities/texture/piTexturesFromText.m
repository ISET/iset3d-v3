function textureLines = piTexturesFromText(txtLines)

%% Read the text from the fname

for ii = 1:size(txtLines)
    if ~isempty(txtLines(ii))
        if ~piContains(txtLines(ii),'Texture')
            txtLines{ii}=[];
        end
    end
end
textureLines = txtLines(~cellfun('isempty',txtLines));

end