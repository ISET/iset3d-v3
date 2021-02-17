function piMediaWrite(thisR)
% Write the material file from PBRT V3, as input from Cinema 4D
%
% The main scene file (scene.pbrt) includes a scene_materials.pbrt
% file.  This routine writes out the materials file from the
% information in the recipe.
%
% HB, SCIEN STANFORD, 2020

%%
p = inputParser;
p.addRequired('thisR',@(x)isequal(class(x),'recipe'));
p.parse(thisR);


%% Empty any line that contains MakeNamedMaterial
% The remaining lines have a texture definition.

for mm=1:numel(thisR.media.list)
    thisR.media.txtLine{mm} = piMediumText(thisR.media.list(mm));
end

%% Write to scene_material.pbrt texture-material file

output = thisR.media.outputFile_media;
fileID = fopen(output,'w');
fprintf(fileID,'# Exported by piMediaWrite on %i/%i/%i %i:%i:%0.2f \n',clock);
for row=1:length(thisR.media.txtLine)
    fprintf(fileID,'%s\n',thisR.media.txtLine{row});
end

fclose(fileID);

[~,n,e] = fileparts(output);
fprintf('Material file %s written successfully.\n', [n,e]);

end

%% function that converts the struct to text
function val = piMediumText(medium)
% For each type of material, we have a method to write a line in the
% material file.
%

val_name = sprintf('MakeNamedMedium "%s" ',medium.name);
val = val_name;
val_string = sprintf(' "string type" "%s" ',medium.type);
val = strcat(val, val_string);

end
