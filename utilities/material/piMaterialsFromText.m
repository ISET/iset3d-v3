function materialLines = piMaterialsFromText(txtLines)
%% Read the text from the fname

for ii = 1:size(txtLines)
    if ~isempty(txtLines(ii))
        if ~piContains(txtLines(ii),'MakeNamedMaterial')
            txtLines{ii}=[];
        end
    end
end

materialLines = txtLines(~cellfun('isempty',txtLines));
end