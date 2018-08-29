function piMaterialWrite(thisR)
% Write the material file from PBRT V3, as input from Cinema 4D
%
% The main scene file (scene.pbrt) includes a scene_materials.pbrt
% file.  This routine writes out the materials file from the
% information in the recipe.
%
% ZL, SCIEN STANFORD, 2018

%% 
p = inputParser;
p.addRequired('thisR',@(x)isequal(class(x),'recipe'));
p.parse(thisR);

%% 
workingDir = fileparts(thisR.outputFile);
% copy spds to working directroy
spds_path = fullfile(piRootPath,'data','spds');
desdir = fullfile(workingDir,'spds');
if ~exist(desdir,'dir'), mkdir(desdir);end
status = copyfile(spds_path,desdir);
if(~status), error('Failed to copy spds directory to docker working directory.');end
% copy skymaps to working directroy
skymaps_path = fullfile(piRootPath,'data','skymaps');
desdir=fullfile(workingDir,'skymaps');
if ~exist(desdir,'dir'), mkdir(desdir);end
status = copyfile(skymaps_path,desdir);
if(~status), error('Failed to copy skymaps directory to docker working directory.');end
% copy brdfs to working directroy
brdfs_path = fullfile(piRootPath,'data','bsdfs');
desdir = fullfile(workingDir,'bsdfs');
if ~exist(desdir,'dir'), mkdir(desdir);end
status = copyfile(brdfs_path,desdir);
if(~status), error('Failed to copy bsdfs directory to docker working directory.');end

%% Parse the output file, working directory, stuff like that.

% Converts any jpg file names in the PBRT files into png file names
ntxtLines=length(thisR.materials.txtLines);
for jj = 1:ntxtLines
    str = thisR.materials.txtLines(jj);
    if contains(str,'.jpg"')
        thisR.materials.txtLines(jj) = strrep(str,'jpg','png');
    end
    if contains(str,'.jpg "')
        thisR.materials.txtLines(jj) = strrep(str,'jpg ','png');
    end    
    % photoshop exports texture format with ".JPG "(with extra space) ext.
    if contains(str,'.JPG "')
        thisR.materials.txtLines(jj) = strrep(str,'JPG ','png');
    end
    if contains(str,'.JPG"')
        thisR.materials.txtLines(jj) = strrep(str,'JPG','png');
    end    
    if contains(str,'bmp')
        thisR.materials.txtLines(jj) = strrep(str,'bmp','png');
    end
    if contains(str,'tif')
        thisR.materials.txtLines(jj) = strrep(str,'tif','png');
    end
end

%% Empty any line that contains MakeNamedMaterial
% The remaining lines have a texture definition.

output = thisR.materials.outputFile_materials;
[~,materials_fname,~]=fileparts(output);
thisR.world{length(thisR.world)-2} = sprintf('Include "%s.pbrt" ',materials_fname);
txtLines = thisR.materials.txtLines;
for i = 1:size(txtLines)
    if ~isempty(txtLines(i))
        if contains(txtLines(i),'MakeNamedMaterial')
            txtLines{i}=[];
        end
    end
end

% Squeeze out the empty lines. Some day we might get the parsed
% textures here. 
textureLines = txtLines(~cellfun('isempty',txtLines));

for jj = 1: length(textureLines)
    textureLines_tmp = [];
    thisLine_tmp = textscan(textureLines{jj},'%q');
    thisLine_tmp = thisLine_tmp{1};
    for ii = 1:length(thisLine_tmp)
        if contains(thisLine_tmp{ii},'.png')
            filename = thisLine_tmp{ii};
            if ~contains(filename,'textures/')
            thisLine_tmp{ii} = fullfile('textures',filename);
            end
        end
        if ii == 1
            textureLines_tmp = strcat(textureLines_tmp,thisLine_tmp{ii});
        else
            string = sprintf('"%s"',thisLine_tmp{ii});
            textureLines_tmp = strcat(textureLines_tmp,{' '},string);
        end 
    end
    textureLines{jj} = textureLines_tmp{1};
end
textureLines{length(textureLines)+1} = 'Texture "windy_bump" "float" "windy"';
%% Create txtLines for the material struct array
field =fieldnames(thisR.materials.list);
materialTxt = cell(1,length(field));
 
for ii=1:length(materialTxt)
    % Converts the material struct to text
    materialTxt{ii} = piMaterialText(thisR.materials.list.(cell2mat(field(ii)))); 
end

%% Write to scene_material.pbrt texture-material file

fileID = fopen(output,'w');
fprintf(fileID,'# Exported by piMaterialWrite on %i/%i/%i %i:%i:%0.2f \n',clock);
for row=1:length(textureLines)
    fprintf(fileID,'%s\n',textureLines{row});
end

% Add the materials
nPaintLines = {};
gg = 1;
for dd = 1:length(materialTxt)
    if contains(materialTxt{dd},'paint_base') &&...
            ~contains(materialTxt{dd},'mix')||...
        contains(materialTxt{dd},'paint_mirror') &&...
            ~contains(materialTxt{dd},'mix')   
        nPaintLines{gg} = dd;
        gg = gg+1;
    end
end

% Find material names contains 'paint_base' or 'paint_mirror'
if ~isempty(nPaintLines)
    for hh = 1:length(nPaintLines)
    fprintf(fileID,'%s\n',materialTxt{nPaintLines{hh}});
    materialTxt{nPaintLines{hh}} = [];
    end
    materialTxt = materialTxt(~cellfun('isempty',materialTxt));
%     nmaterialTxt = length(materialTxt)-length(nPaintLines);
    for row=1:length(materialTxt)
        fprintf(fileID,'%s\n',materialTxt{row});
        
    end
else
    for row=1:length(materialTxt)
        fprintf(fileID,'%s\n',materialTxt{row});
        
    end
end
fclose(fileID);

[~,n,e] = fileparts(output);
fprintf('Material file %s written successfully.\n', [n,e]);

end

%% function that converts the struct to text
function val = piMaterialText(materials)
% For each type of material, we have a method to write a line in the
% material file.
%

val_name = sprintf('MakeNamedMaterial "%s" ',materials.name);
val = val_name;
val_string = sprintf(' "string type" "%s" ',materials.string);
val = strcat(val, val_string);

if ~isempty(materials.floatindex)
    val_floatindex = sprintf(' "float index" [%0.5f] ',materials.floatindex);
    val = strcat(val, val_floatindex);
end

if ~isempty(materials.texturekd)
    val_texturekd = sprintf(' "texture Kd" "%s" ',materials.texturekd);
    val = strcat(val, val_texturekd);
end

if ~isempty(materials.texturekr)
    val_texturekr = sprintf(' "texture Kr" "%s" ',materials.texturekr);
    val = strcat(val, val_texturekr);
end

if ~isempty(materials.textureks)
    val_textureks = sprintf(' "texture Ks" "%s" ',materials.textureks);
    val = strcat(val, val_textureks);
end

if ~isempty(materials.rgbkr)
    val_rgbkr = sprintf(' "rgb Kr" [%0.5f %0.5f %0.5f] ',materials.rgbkr);
    val = strcat(val, val_rgbkr);
end

if ~isempty(materials.rgbks)
    val_rgbks = sprintf(' "rgb Ks" [%0.5f %0.5f %0.5f] ',materials.rgbks);
    val = strcat(val, val_rgbks);
end

if ~isempty(materials.rgbkd)
    val_rgbkd = sprintf(' "rgb Kd" [%0.5f %0.5f %0.5f] ',materials.rgbkd);
    val = strcat(val, val_rgbkd);
end

if ~isempty(materials.colorkd)
    val_colorkd = sprintf(' "color Kd" [%0.5f %0.5f %0.5f] ',materials.colorkd);
    val = strcat(val, val_colorkd);
end

if ~isempty(materials.colorks)
    val_colorks = sprintf(' "color Ks" [%0.5f %0.5f %0.5f] ',materials.colorks);
    val = strcat(val, val_colorks);
end

if ~isempty(materials.floaturoughness)
    val_floaturoughness = sprintf(' "float uroughness" [%0.5f] ',materials.floaturoughness);
    val = strcat(val, val_floaturoughness);
end

if ~isempty(materials.floatvroughness)
    val_floatvroughness = sprintf(' "float vroughness" [%0.5f] ',materials.floatvroughness);
    val = strcat(val, val_floatvroughness);
end

if ~isempty(materials.floatroughness)
    val_floatroughness = sprintf(' "float roughness" [%0.5f] ',materials.floatroughness);
    val = strcat(val, val_floatroughness);
end

if ~isempty(materials.spectrumkd)
    val_spectrumkd = sprintf(' "spectrum Kd" "%s" ',materials.spectrumkd);
    val = strcat(val, val_spectrumkd);
end

if ~isempty(materials.spectrumks)
    val_spectrumks = sprintf(' "spectrum Ks" "%s" ',materials.spectrumks);
    val = strcat(val, val_spectrumks);
end

if ~isempty(materials.spectrumk)
    val_spectrumks = sprintf(' "spectrum k" "%s" ',materials.spectrumk);
    val = strcat(val, val_spectrumks);
end

if ~isempty(materials.spectrumeta)
    val_spectrumks = sprintf(' "spectrum eta" "%s" ',materials.spectrumeta);
    val = strcat(val, val_spectrumks);
end

if ~isempty(materials.stringnamedmaterial1)
    val_stringnamedmaterial1 = sprintf(' "string namedmaterial1" "%s" ',materials.stringnamedmaterial1);
    val = strcat(val, val_stringnamedmaterial1);
end

if ~isempty(materials.stringnamedmaterial2)
    val_stringnamedmaterial2 = sprintf(' "string namedmaterial2" "%s" ',materials.stringnamedmaterial2);
    val = strcat(val, val_stringnamedmaterial2);
end
if isfield(materials,'texturebumpmap')
if ~isempty(materials.texturebumpmap)
    val_texturekr = sprintf(' "texture bumpmap" "%s" ',materials.texturebumpmap);
    val = strcat(val, val_texturekr);
end
end
end
