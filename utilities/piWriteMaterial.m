 function workingDir = piWriteMaterial(materialR,txtLines,output)
% find cells except for NamedMaterial
for i= 1:size(txtLines)
    if ~isempty(txtLines(i))
    if contains(txtLines(i),'MakeNamedMaterial')
        txtLines{i}=[];
    end
    end
end
% Combine predefined texture and defined materials
materiallist = vertcat(txtLines(~cellfun('isempty',txtLines)),struct2cell(materialR));
% write to .pbrt files
fileID = fopen(output,'w');
for row=1:size(materiallist)
    fprintf(fileID,'%s\n',materiallist{row});
end
fclose(fileID);
end
