function val = piMaterialText(material, varargin)
%% function that converts the struct to text
% For each type of material, we have a method to write a line in the
% material file.
%

%% Parse input
p = inputParser;
p.addRequired('material', @isstruct);

p.parse(material, varargin{:});

%% Concatatenate string

% BUG
% Legacy material formats ... sigh. Do we need to convert all of the
% material structs in the scenes?
%
% BUG:  ZLY and BW to address.
valName = sprintf('MakeNamedMaterial "%s" ',material.name);
if isfield(material,'type')
    valType = sprintf(' "string type" "%s" ',material.type);
elseif isfield(material,'stringtype')
    valType = sprintf(' "string type" "%s" ',material.stringtype);
else
    error('Bad material structure. %s.', material.name)
end

val = strcat(valName, valType);

%% For each field that is not empty, concatenate it to the text line
matParams = fieldnames(material);

for ii=1:numel(matParams)
    if ~isequal(matParams{ii}, 'name') && ...
            ~isequal(matParams{ii}, 'type') && ...
            ~isempty(material.(matParams{ii}).value)
         thisType = material.(matParams{ii}).type;
         thisVal = material.(matParams{ii}).value;
         
         % Quite annoying corner case. Diffusion (Kd), transmission (Kt), 
         % specular (Ks) and mirror reflection (Kr) have capital K.
         if isequal(matParams{ii}(1), 'k')
             matParams{ii}(1) = 'K';
         end
         if ischar(thisVal)
             thisText = sprintf(' "%s %s" "%s" ',...
                 thisType, matParams{ii}, thisVal);
         elseif isnumeric(thisVal)
             if isequal(thisType, 'photolumi')
                 % Fluorescence EEM needs more precision
                 thisText = sprintf(' "%s %s" [%s] ',...
                     thisType, matParams{ii}, num2str(thisVal, '%.10f '));
             else
                thisText = sprintf(' "%s %s" [%s] ',...
                     thisType, matParams{ii}, num2str(thisVal, '%.4f '));
             end
         end

         val = strcat(val, thisText);
        
    end
end

%%

%{
val_name = sprintf('MakeNamedMaterial "%s" ',materials.name);
val = val_name;
val_string = sprintf(' "string type" "%s" ',materials.stringtype);
val = strcat(val, val_string);

if isfield(materials, 'floatindex')
    val_floatindex = sprintf(' "float index" [%0.5f] ',materials.floatindex);
    val = strcat(val, val_floatindex);
end

if isfield(materials, 'texturekd')
    val_texturekd = sprintf(' "texture Kd" "%s" ',materials.texturekd);
    val = strcat(val, val_texturekd);
end

if isfield(materials, 'texturekr')
    val_texturekr = sprintf(' "texture Kr" "%s" ',materials.texturekr);
    val = strcat(val, val_texturekr);
end

if isfield(materials, 'textureks')
    val_textureks = sprintf(' "texture Ks" "%s" ',materials.textureks);
    val = strcat(val, val_textureks);
end

if isfield(materials, 'rgbkr')
    val_rgbkr = sprintf(' "rgb Kr" [%0.5f %0.5f %0.5f] ',materials.rgbkr);
    val = strcat(val, val_rgbkr);
end

if isfield(materials, 'rgbks')
    val_rgbks = sprintf(' "rgb Ks" [%0.5f %0.5f %0.5f] ',materials.rgbks);
    val = strcat(val, val_rgbks);
end

if isfield(materials, 'rgbkt')
    val_rgbkt = sprintf(' "rgb Kt" [%0.5f %0.5f %0.5f] ',materials.rgbkt);
    val = strcat(val, val_rgbkt);
end

if isfield(materials, 'rgbkd')
    val_rgbkd = sprintf(' "rgb Kd" [%0.5f %0.5f %0.5f] ',materials.rgbkd);
    val = strcat(val, val_rgbkd);
end

if isfield(materials, 'colorkd')
    val_colorkd = sprintf(' "color Kd" [%0.5f %0.5f %0.5f] ',materials.colorkd);
    val = strcat(val, val_colorkd);
end

if isfield(materials, 'colorks')
    val_colorks = sprintf(' "color Ks" [%0.5f %0.5f %0.5f] ',materials.colorks);
    val = strcat(val, val_colorks);
end
if isfield(materials, 'colorreflect')
    val_colorreflect = sprintf(' "color reflect" [%0.5f %0.5f %0.5f] ',materials.colorreflect);
    val = strcat(val, val_colorreflect);
end
if isfield(materials, 'colortransmit')
    val_colortransmit = sprintf(' "color transmit" [%0.5f %0.5f %0.5f] ',materials.colortransmit);
    val = strcat(val, val_colortransmit);
end

if isfield(materials, 'colormfp')
    val_colormfp = sprintf(' "color mfp" [%0.5f %0.5f %0.5f] ',materials.colormfp);
    val = strcat(val, val_colormfp);
end
if isfield(materials, 'floaturoughness')
    val_floaturoughness = sprintf(' "float uroughness" [%0.5f] ',materials.floaturoughness);
    val = strcat(val, val_floaturoughness);
end

if isfield(materials, 'floatvroughness')
    val_floatvroughness = sprintf(' "float vroughness" [%0.5f] ',materials.floatvroughness);
    val = strcat(val, val_floatvroughness);
end

if isfield(materials, 'floatroughness')
    val_floatroughness = sprintf(' "float roughness" [%0.5f] ',materials.floatroughness);
    val = strcat(val, val_floatroughness);
end
 
if isfield(materials,'floateta')
    val_floateta = sprintf(' "float eta" [%0.5f] ',materials.floateta);
    val = strcat(val, val_floateta);
end

if isfield(materials, 'spectrumkd')
    if (ischar(materials.spectrumkd))
        val_spectrumkd = sprintf(' "spectrum Kd" "%s" ',materials.spectrumkd);
    else
        data_str = sprintf('%f ',materials.spectrumkd);
        val_spectrumkd = sprintf(' "spectrum Kd" [ %s ] ',data_str); 
    end
    val = strcat(val, val_spectrumkd);
end

if isfield(materials, 'spectrumks')
    if(ischar(materials.spectrumks))
        val_spectrumks = sprintf(' "spectrum Ks" "%s" ',materials.spectrumks);
    else
        val_spectrumks = sprintf(' "spectrum Ks" [ %s ] ',num2str(materials.spectrumks)); 
    end
    val = strcat(val, val_spectrumks);
end

if isfield(materials, 'spectrumkr')
    if(isstring(materials.spectrumkr))
        val_spectrumkr = sprintf(' "spectrum Kr" "%s" ',materials.spectrumkr);
    else
        val_spectrumkr = sprintf(' "spectrum Kr" [%0.5f %0.5f %0.5f %0.5f] ',materials.spectrumkr);
    end
    val = strcat(val, val_spectrumkr);
end
if isfield(materials, 'spectrumkt')
    if(isstring(materials.spectrumkt))
        val_spectrumkt = sprintf(' "spectrum Kt" "%s" ',materials.spectrumkt);
    else
        val_spectrumkt = sprintf(' "spectrum Kt" [%0.5f %0.5f %0.5f %0.5f] ',materials.spectrumkt);
    end
    val = strcat(val, val_spectrumkt);
end
% if ~isempty(materials.spectrumk)
%     val_spectrumks = sprintf(' "spectrum k" "%s" ',materials.spectrumk);
%     val = strcat(val, val_spectrumks);
% end

if isfield(materials, 'spectrumeta')
    val_spectrumks = sprintf(' "spectrum eta" "%s" ',materials.spectrumeta);
    val = strcat(val, val_spectrumks);
end

if isfield(materials, 'stringnamedmaterial1')
    val_stringnamedmaterial1 = sprintf(' "string namedmaterial1" "%s" ',materials.stringnamedmaterial1);
    val = strcat(val, val_stringnamedmaterial1);
end

if isfield(materials, 'bsdffile')
    val_bsdfile = sprintf(' "string bsdffile" "%s" ',materials.bsdffile);
    val = strcat(val, val_bsdfile);
end
if isfield(materials, 'stringnamedmaterial2')
    val_stringnamedmaterial2 = sprintf(' "string namedmaterial2" "%s" ',materials.stringnamedmaterial2);
    val = strcat(val, val_stringnamedmaterial2);
end
if isfield(materials, 'texturebumpmap')
    val_texturekr = sprintf(' "texture bumpmap" "%s" ',materials.texturebumpmap);
    val = strcat(val, val_texturekr);
end
if isfield(materials, 'boolremaproughness')
    val_boolremaproughness = sprintf(' "bool remaproughness" "%s" ',materials.boolremaproughness);
    val = strcat(val, val_boolremaproughness);
end
if isfield(materials, 'eta')
    val_boolremaproughness = sprintf(' "float eta" %0.5f ',materials.eta);
    val = strcat(val, val_boolremaproughness);
end
if isfield(materials, 'amount')
    val_boolremaproughness = sprintf(' "spectrum amount" "%0.5f" ',materials.amount);
    val = strcat(val, val_boolremaproughness);
end
if isfield(materials, 'photolumifluorescence')
    val_photolumifluorescence = [sprintf(' "photolumi fluorescence" '),...
                                '[ ', sprintf('%.10f ', materials.photolumifluorescence),' ]'];
    val = strcat(val, val_photolumifluorescence);
end
if isfield(materials, 'floatconcentration')
    val_floatconcentration = sprintf(' "float concentration" [ %0.10f ] ',...
                                materials.floatconcentration);
    val = strcat(val, val_floatconcentration);
end
%}
end