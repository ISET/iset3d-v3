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

%% Create txtLines for texture struct array
% Texture txt lines creation are moved into piTextureText function.

if isfield(thisR.textures,'list') && ~isempty(thisR.textures.list)
    textureNum = numel(thisR.textures.list);
    textureTxt = cell(1, textureNum);

    for ii = 1:numel(textureTxt)
        textureTxt{ii} = piTextureText(thisR.textures.list{ii});
    end
else
    textureTxt = {};
end

%% Parse the output file, working directory, stuff like that.
% Commented by ZLY. Does this section do any work?

%{
% Converts any jpg file names in the PBRT files into png file names
ntxtLines=length(thisR.materials.txtLines);
for jj = 1:ntxtLines
    str = thisR.materials.txtLines(jj);
    if piContains(str,'.jpg"')
        thisR.materials.txtLines(jj) = strrep(str,'jpg','png');
    end
    if piContains(str,'.jpg "')
        thisR.materials.txtLines(jj) = strrep(str,'jpg ','png');
    end
    % photoshop exports texture format with ".JPG "(with extra space) ext.
    if piContains(str,'.JPG "')
        thisR.materials.txtLines(jj) = strrep(str,'JPG ','png');
    end
    if piContains(str,'.JPG"')
        thisR.materials.txtLines(jj) = strrep(str,'JPG','png');
    end
    if piContains(str,'bmp')
        thisR.materials.txtLines(jj) = strrep(str,'bmp','png');
    end
    if piContains(str,'tif')
        thisR.materials.txtLines(jj) = strrep(str,'tif','png');
    end
end
%}

%% Create txtLines for the material struct array
if isfield(thisR.materials, 'list') && ~isempty(thisR.materials.list)
    materialNum =numel(thisR.materials.list);
    materialTxt = cell(1, materialNum);

    for ii=1:length(materialTxt)
        % Converts the material struct to text
        materialTxt{ii} = piMaterialText(thisR.materials.list{ii});
    end
else
    materialTxt{1} = '';
end

%% Write to scene_material.pbrt texture-material file
output = thisR.materials.outputFile_materials;
fileID = fopen(output,'w');
fprintf(fileID,'# Exported by piMaterialWrite on %i/%i/%i %i:%i:%0.2f \n',clock);

if ~isempty(textureTxt)
    % Add textures
    for row=1:length(textureTxt)
        fprintf(fileID,'%s\n',textureTxt{row});
    end
end

% Add the materials
nPaintLines = {};
gg = 1;
for dd = 1:length(materialTxt)
    if piContains(materialTxt{dd},'paint_base') &&...
            ~piContains(materialTxt{dd},'mix')||...
            piContains(materialTxt{dd},'paint_mirror') &&...
            ~piContains(materialTxt{dd},'mix')
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

%% Write media to xxx_materials.pbrt

if ~isempty(thisR.media)
    for m=1:length(thisR.media.list)
        fprintf(fileID, piMediumText(thisR.media.list(m), workDir));
    end
end


fclose(fileID);

[~,n,e] = fileparts(output);
fprintf('Material file %s written successfully.\n', [n,e]);

end


%% function that converts the struct to text
function val = piMediumText(medium, workDir)
% For each type of material, we have a method to write a line in the
% material file.
%

val_name = sprintf('MakeNamedMedium "%s" ',medium.name);
val = val_name;
val_string = sprintf(' "string type" "%s" ',medium.type);
val = strcat(val, val_string);

if ~isempty(medium.absFile) || ~isempty(medium.vsfFile)
    resDir = fullfile(fullfile(workDir,'spds'));
    if ~exist(resDir,'dir')
        mkdir(resDir);
    end
    
    if ~isempty(medium.absFile)
        fid = fopen(fullfile(resDir,sprintf('%s_abs.spd',medium.name)),'w');
        fprintf(fid,'%s',medium.absFile);
        fclose(fid);
    
        val_floatindex = sprintf(' "string absFile" "spds/%s_abs.spd"',medium.name);
        val = strcat(val, val_floatindex);
    end
    
    if ~isempty(medium.vsfFile)
        fid = fopen(fullfile(resDir,sprintf('%s_vsf.spd',medium.name)),'w');
        fprintf(fid,'%s',medium.vsfFile);
        fclose(fid);
    
        val_floatindex = sprintf(' "string vsfFile" "spds/%s_vsf.spd"',medium.name);
        val = strcat(val, val_floatindex);
    end
    
else

    if ~isempty(medium.cPlankton)
        val_floatindex = sprintf(' "float cPlankton" %f ',medium.cPlankton);
        val = strcat(val, val_floatindex);
    end

    if ~isempty(medium.aCDOM440)
        val_texturekd = sprintf(' "float aCDOM440" %f ',medium.aCDOM440);
        val = strcat(val, val_texturekd);
    end

    if ~isempty(medium.aNAP400)
        val_texturekr = sprintf(' "float aNAP400" %f ',medium.aNAP400);
        val = strcat(val, val_texturekr);
    end

    if ~isempty(medium.cSmall)
        val_textureks = sprintf(' "float cSmall" %f ',medium.cSmall);
        val = strcat(val, val_textureks);
    end

    if ~isempty(medium.cLarge)
        val_textureks = sprintf(' "float cLarge" %f ',medium.cLarge);
        val = strcat(val, val_textureks);
    end

end

end

