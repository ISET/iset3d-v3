function val = piTextureText(texture, varargin)
% Compose text for textures
%
% Input:
%   texture - texture struct
%
% Outputs:
%   val     - text
%
% ZLY, 2021
% 
% See also

%% Parse input
p = inputParser;
p.addRequired('texture', @isstruct);

p.parse(texture, varargin{:});

%% Concatenate string
% Name
if ~strcmp(texture.name, '')
    valName = sprintf('Texture "%s" ', texture.name);
else
    error('Bad texture structure')
end

% format
formTxt = sprintf(' "%s"', texture.format);
val = strcat(valName, formTxt);

% type
tyTxt = sprintf(' "%s"', texture.type);
val = strcat(val, tyTxt);

%% For each field that is not empty, concatenate it to the text line
textureParams = fieldnames(texture);

for ii=1:numel(textureParams)
    if ~isequal(textureParams{ii}, 'name') && ...
            ~isequal(textureParams{ii}, 'type') && ...
            ~isequal(textureParams{ii}, 'format') && ...
            ~isempty(texture.(textureParams{ii}).value)
         thisType = texture.(textureParams{ii}).type;
         thisVal = texture.(textureParams{ii}).value;
         
         if ischar(thisVal)
             thisText = sprintf(' "%s %s" "%s" ',...
                 thisType, textureParams{ii}, thisVal);
         elseif isnumeric(thisVal)
            if isinteger(thisType)
                thisText = sprintf(' "%s %s" [%s] ',...
                     thisType, textureParams{ii}, num2str(thisVal, '%d'));
            else
                thisText = sprintf(' "%s %s" [%s] ',...
                     thisType, textureParams{ii}, num2str(thisVal, '%.4f '));
            end
         end

         val = strcat(val, thisText);
        
    end
end
%% Old version
%{
% Compose the texture definition line for PBRT

% Texture name
val_name = sprintf('Texture "%s" ', texture.name);
val = val_name;

% Texture format
if strcmp(texture.format,'spectrum')
    val_format = sprintf(' "spectrum"');
elseif strcmp(texture.format, 'float')
    val_format = sprintf(' "float"');
else
    error('Unknown texture format "%s" for texture: %s', texture.format, texture.name);
end
val = strcat(val, val_format);

% Texture type
if isfield(texture,'type')
    val_type = sprintf(' "%s"', texture.type);
    val = strcat(val, val_type);
end

% Texture string mapping
if isfield(texture, 'stringmapping')
    val_stringmapping = sprintf(' "string mapping" "%s" ', texture.stringmapping);
    val = strcat(val, val_stringmapping);
end

% Texture float uscale
if isfield(texture, 'floatuscale')
    val_floatuscale = sprintf(' "float uscale" [%0.5f] ', texture.floatuscale);
    val = strcat(val, val_floatuscale);
end

% Texture float vscale
if isfield(texture, 'floatvscale')
    val_floatvscale = sprintf(' "float vscale" [%0.5f] ', texture.floatvscale);
    val = strcat(val, val_floatvscale);
end

% Texture float udelta
if isfield(texture, 'floatudelta')
    val_floatudelta = sprintf(' "float udelta" [%0.5f] ', texture.floatudelta);
    val = strcat(val, val_floatudelta);
end

% Texture float vdelta
if isfield(texture, 'floatvdelta')
    val_floatvdelta = sprintf(' "float vdelta" [%0.5f] ', texture.floatvdelta);
    val = strcat(val, val_floatvdelta);
end

% Texture vector v1
if isfield(texture, 'vectorv1')
    val_vectorv1 = sprintf(' "vector3f v1" [%s] ', strrep(num2str(texture.vectorv1), '  ', ' '));
    val = strcat(val, val_vectorv1);
end

% Texture vector v2
if isfield(texture, 'vector v2')
    val_vectorv2 = sprintf(' "vector3f v2" [%s] ', strrep(num2str(texture.vectorv2), '  ', ' '));
    val = strcat(val, val_vectorv2);
end

% Texture spectrum value
if isfield(texture, 'spectrumvalue')
    if strcmp(texture.spectrumvalue(1), '[') % Spectrum is stored as vector
        val_spectrumvalue = sprintf(' "spectrum value" %s ', texture.spectrumvalue);
    else                                     % Spectrum is stored as string
        val_spectrumvalue = sprintf(' "spectrum value" "%s" ', texture.spectrumvalue);
    end
    val = strcat(val, val_spectrumvalue);
end

% Texture spectrum tex1
if isfield(texture, 'spectrumtex1')
    if strcmp(texture.spectrumtex1(1), '[')
        val_spectrumtex1 = sprintf(' "spectrum tex1" %s ', texture.spectrumtex1);
    else
        val_spectrumtex1 = sprintf(' "spectrum tex1" "%s" ', texture.spectrumtex1);
    end
    val = strcat(val, val_spectrumtex1);
end

% Texture spectrum tex2
if isfield(texture, 'spectrumtex2')
    if strcmp(texture.spectrumtex2(1), '[')
        val_spectrumtex2 = sprintf(' "spectrum tex2" %s ', texture.spectrumtex2);
    else
        val_spectrumtex2 = sprintf(' "spectrum tex2" "%s" ', texture.spectrumtex2);
    end
    val = strcat(val, val_spectrumtex2);
end

% Texture float tex1
if isfield(texture, 'floattex1')
    val_spectrumfloattex1 = sprintf(' "float tex1" [%0.5f] ', texture.floattex1);
    val = strcat(val, val_spectrumfloattex1);
end

% Texture float tex2
if isfield(texture, 'floattex2')
    val_spectrumfloattex2 = sprintf(' "float tex2" [%0.5f] ', texture.floattex2);
    val = strcat(val, val_spectrumfloattex2);
end

% Texture float amount
if isfield(texture, 'floatamount')
    val_floatamount = sprintf(' "float amount" [%0.5f] ', texture.floatamount);
    val = strcat(val, val_floatamount);
end

% Texture spectrum v00
if isfield(texture, 'spectrumv00')
    if strcmp(texture.spectrumv00(1), '[')
        val_spectrumv00 = sprintf(' "spectrum v00" %s ', texture.spectrumv00);
    else
        val_spectrumv00 = sprintf(' "spectrum v00" "%s" ', texture.spectrumv00);        
    end
    val = strcat(val, val_spectrumv00);
end

% Texture spectrum v01
if isfield(texture, 'spectrumv01')
    if strcmp(texture.spectrumv01(1), '[')
        val_spectrumv01 = sprintf(' "spectrum v01" %s ', texture.spectrumv01);
    else
        val_spectrumv01 = sprintf(' "spectrum v01" "%s" ', texture.spectrumv01);        
    end
    val = strcat(val, val_spectrumv01);
end

% Texture spectrum v10
if isfield(texture, 'spectrumv10')
    if strcmp(texture.spectrumv10(1), '[')
        val_spectrumv10 = sprintf(' "spectrum v10" %s ', texture.spectrumv10);
    else
        val_spectrumv10 = sprintf(' "spectrum v10" "%s" ', texture.spectrumv10);        
    end
    val = strcat(val, val_spectrumv10);
end

% Texture spectrum v11
if isfield(texture, 'spectrumv11')
    if strcmp(texture.spectrumv11(1), '[')
        val_spectrumv11 = sprintf(' "spectrum v11" %s ', texture.spectrumv11);
    else
        val_spectrumv11 = sprintf(' "spectrum v11" "%s" ', texture.spectrumv11);        
    end
    val = strcat(val, val_spectrumv11);
end

% Texture float v00
if isfield(texture, 'floatv00')
    val_floatv00 = sprintf(' "float v00" [%0.5f] ', texture.floatv00);
    val = strcat(val, val_floatv00);
end

% Texture float v01
if isfield(texture, 'floatv01')
    val_floatv01 = sprintf(' "float v01" [%0.5f] ', texture.floatv01);
    val = strcat(val, val_floatv01);
end

% Texture float v10
if isfield(texture, 'floatv10')
    val_floatv10 = sprintf(' "float v10" [%0.5f] ', texture.floatv10);
    val = strcat(val, val_floatv10);
end

% Texture float v11
if isfield(texture, 'floatv11')
    val_floatv11 = sprintf(' "float v11" [%0.5f] ', texture.floatv11);
    val = strcat(val, val_floatv11);
end

% Texture string filename
if isfield(texture, 'stringfilename')
    val_stringfilename = sprintf(' "string filename" "%s" ', texture.stringfilename);
    val = strcat(val, val_stringfilename);
end

% Texture string wrap
if isfield(texture, 'stringwrap')
    val_stringwrap = sprintf(' "string wrap" "%s" ', texture.stringwrap);
    val = strcat(val, val_stringwrap);
end

% Texture float maxanisotropy
if isfield(texture, 'floatmaxanisotropy')
    val_floatmaxanisotropy = sprintf(' "float maxanisotropy" [%0.5f] ',...
                                    texture.floatmaxanisotropy);
    val = strcat(val, val_floatmaxanisotropy);
end

% Texture bool trilinear
if isfield(texture, 'booltrilinear')
    val_booltrilinear = sprintf(' "bool trilinear" "%s" ', texture.booltrilinear);
    val = strcat(val, val_booltrilinear);
end

% Texture float scale
if isfield(texture, 'floatscale')
    val_floatscale = sprintf(' "float scale" [%0.5f] ', texture.floatscale);
    val = strcat(val, val_floatscale);
end

% Texture bool gamma
if isfield(texture, 'boolgamma')
    val_boolgamma = sprintf(' "bool gamma" "%s" ', texture.boolgamma);
    val = strcat(val, val_boolgamma);
end

% Texture integer dimension
if isfield(texture, 'integerdimension')
    val_integerdimension = sprintf(' "integer dimension" [%d] ',...
                                int16(texture.integerdimension));
    val = strcat(val, val_integerdimension);
end

% Texture string aamode
if isfield(texture, 'stringaamode')
    val_stringaamode = sprintf(' "string aamode" "%s" ', texture.stringaamode);
    val = strcat(val, val_stringaamode);
end

% Texture spectrum inside
if isfield(texture, 'spectruminside')
    if strcmp(texture.spectruminside(1), '[')
        val_spectruminside = sprintf(' "spectrum inside" %s ',...
                                    texture.spectruminside);
    else
        val_spectruminside = sprintf(' "spectrum inside" "%s" ', ...
                                    texture.spectruminside);
    end
    val = strcat(val, val_spectruminside);
end

% Texture float inside
if isfield(texture, 'floatinside')
    val_floatinside = sprintf(' "float inside" [%0.5f] ', texture.floatinside);
    val = strcat(val, val_floatinside);
end

% Texture spectrum outside
if isfield(texture, 'spectrumoutside')
    if strcmp(texture.spectrumoutside(1), '[')
        val_spectrumoutside = sprintf(' "spectrum outside" %s ',...
                                    texture.spectrumoutside);
    else
        val_spectrumoutside = sprintf(' "spectrum outside" "%s" ', ...
                                    texture.spectrumoutside);
    end
    val = strcat(val, val_spectrumoutside);
end

% Texture float outside
if isfield(texture, 'floatoutside')
    val_floatoutside = sprintf(' "float outside" [%0.5f] ', texture.floatoutside);
    val = strcat(val, val_floatoutside);
end

% Texture integer octaves
if isfield(texture, 'integeroctaves')
    val_integeroctaves = sprintf(' "integer octaves" [%d] ', int16(texture.integeroctaves));
    val = strcat(val, val_integeroctaves);
end

% Texture float roughness
if isfield(texture, 'floatroughness')
    val_floatroughness = sprintf(' "float roughness" [%0.5f] ', texture.floatroughness);
    val = strcat(val, val_floatroughness);
end

% Texture float variation
if isfield(texture, 'floatvariation')
    val_floatvariation = sprintf(' "float variation" [%0.5f] ', texture.floatvariation);
    val = strcat(val, val_floatvariation);
end

% Texture spectrum basisone
if isfield(texture, 'spectrumbasisone')
    if strcmp(texture.spectrumbasisone, '[')
        val_spectrumbasisone = sprintf(' "spectrum basisone" %s ',...
                                texture.spectrumbasisone);
    else
        val_spectrumbasisone = sprintf(' "spectrum basisone" "%s" ',...
                                texture.spectrumbasisone);
    end
    val = strcat(val, val_spectrumbasisone);
end

% Texture spectrum basistwo
if isfield(texture, 'spectrumbasistwo')
    if strcmp(texture.spectrumbasistwo, '[')
        val_spectrumbasistwo = sprintf(' "spectrum basistwo" %s ',...
                                texture.spectrumbasistwo);
    else
        val_spectrumbasistwo = sprintf(' "spectrum basistwo" "%s" ',...
                                texture.spectrumbasistwo);
    end
    val = strcat(val, val_spectrumbasistwo);
end

% Texture spectrum basisthree
if isfield(texture, 'spectrumbasisthree')
    if strcmp(texture.spectrumbasisthree, '[')
        val_spectrumbasisthree = sprintf(' "spectrum basisthree" %s ',...
                                texture.spectrumbasisthree);
    else
        val_spectrumbasisthree = sprintf(' "spectrum basisthree" "%s" ',...
                                texture.spectrumbasisthree);
    end
    val = strcat(val, val_spectrumbasisthree);
end

%{
%% Empty any line that contains MakeNamedMaterial
% The remaining lines have a texture definition.

output = thisR.materials.outputFile_materials;
[~,materials_fname,~]=fileparts(output);
txtLines = thisR.materials.txtLines;
for ii = 1:size(txtLines)
    if isfield(txtLines(ii))
        if piContains(txtLines(ii),'MakeNamedMaterial')
            txtLines{ii}=[];
        end
    end
end

% Squeeze out the empty lines. Some day we might get the parsed
% textures here.
textureLines = txtLines(~cellfun('isempty',txtLines));

for jj = 1: length(textureLines)
    textureLines_tmp = [];
    %     thisLine_tmp = textscan(textureLines{jj},'%q');
    thisLine_tmp= strsplit(textureLines{jj},' ');
    if ~strcmp(thisLine_tmp{length(thisLine_tmp)}(1),'"')
        for nn= length(thisLine_tmp):-1:1
            if strcmp(thisLine_tmp{nn}(1),'"')
                for kk = nn:length(thisLine_tmp)-1
                    % combine all the string from nn to end;
                    thisLine_tmp{nn} = [thisLine_tmp{nn},' ',thisLine_tmp{kk+1}];
                end
                thisLine_tmp((nn+1):length(thisLine_tmp))=[];
                break;
            end
        end
    end
    %     thisLine_tmp = thisLine_tmp{1};
    for ii = 1:length(thisLine_tmp)
        if piContains(thisLine_tmp{ii},'filename')
            index = ii;
        end
    end
    for ii = 1:length(thisLine_tmp)
        if piContains(thisLine_tmp{ii},'.png')
            if piContains(thisLine_tmp{ii-1},'filename')
                filename = thisLine_tmp{ii};
                if ~piContains(filename,'"textures/')
                    if ispc
                        thisLine_tmp{ii} = strrep(fullfile('"textures',filename(2:length(filename))),'\','/');
                    else
                        thisLine_tmp{ii} = fullfile('"textures',filename(2:length(filename)));
                    end
                end
            else
                thisLine_tmp{index+1} = thisLine_tmp{ii};
                thisLine_tmp(index+2:ii)   = '';
                filename = thisLine_tmp{index+1};
                if ~piContains(filename,'"textures/')
                    if ispc
                        thisLine_tmp{index+1} = strrep(fullfile('"textures',filename(2:length(filename))),'\','/');
                    else
                        thisLine_tmp{index+1} = fullfile('"textures',filename(2:length(filename)));
                    end
                end
            end
        end
        % if ii == length(thisLine_tmp), break; end
    end
    for ii = 1:length(thisLine_tmp)
        if ii == 1
            textureLines_tmp = strcat(textureLines_tmp,thisLine_tmp{ii});
        else
            %             string = sprintf('%s"',thisLine_tmp{ii});
            textureLines_tmp = strcat(textureLines_tmp,{' '},thisLine_tmp{ii});
        end
    end
    textureLines{jj} = textureLines_tmp{1};
end
% textureLines{length(textureLines)+1} = 'Texture "windy_bump" "float" "windy" "float uscale" [512] "float vscale" [512] ';
%}
%}