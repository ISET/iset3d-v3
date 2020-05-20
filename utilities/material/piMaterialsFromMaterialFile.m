function textureLines = piMaterialsFromMaterialFile(txtLines)

for ii = 1:size(txtLines)
    if ~isempty(txtLines(ii))
        if ~piContains(txtLines(ii),'MakeNamedMaterial')
            txtLines{ii}=[];
        end
    end
end
textureLines = txtLines(~cellfun('isempty',txtLines));

end