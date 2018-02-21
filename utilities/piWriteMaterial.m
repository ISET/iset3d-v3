function piWriteMaterial(materials,txtLines,output)
% find cells except for NamedMaterial

%% Parse the output file, working directory, stuff like that.

%%
% Empty any line that contains MakeNamedMaterial
% The remaining lines have a texture definition.
for i = 1:size(txtLines)
    if ~isempty(txtLines(i))
        if contains(txtLines(i),'MakeNamedMaterial')
            txtLines{i}=[];
        end
    end
end

% Squeeze out the empty lines????
% Some day we might get the parsed textures here.
% textureLines = squeeze(txtLines);

%% Create txtLines for the material struct array
materialTxt = cell(1,length(materials));
for ii=1:length(materials)
  materialTxt{ii} = piMaterialText(materials(ii)); % function that converts the struct to text
end

%% Combine txtLines that are textures and defined materials
% materiallist = vertcat(txtLines(~cellfun('isempty',txtLines)),struct2cell(materialR));

%% Write to .pbrt texture-material file

fileID = fopen(output,'w');

for row=1:size(txtLines)
    fprintf(fileID,'%s\n',txtLines{row});
end

% Add the materials
for row=1:size(materiallist)
    fprintf(fileID,'%s\n',materialTxt{row});
end

fclose(fileID);

end
