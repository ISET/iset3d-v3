function materiallist = piBlockExtractMaterial(txtLines)
% Extract parameters of a material from a block of text
%
% Syntax:
%
% Description:
%  The Cinema 4D exporter puts the materials and textures in a
%  separate file.  This function reads that file and returns the
%  collection of materials so we can edit their properties.
%
%
% Inputs
%  txtLines
%
% Outputs:
%   materialR:  An array of structs defining the material
%
% Optional key/value pairs
%
% ZL SCIEN Stanford, 2018;

% Notes
%  The format for PBRT V2 differs noticeably from V3.  In particular,
%    MakeNamedMaterial is just Material.
%  Cinema 4D exporter always puts the materials on a single line, but
%    V2 scenes can be formatted much more loosely across lines.
%
%  

% Programming todo
%  We should be able to handle the 'mix' case and these others at some
%  point.
% MakeNamedMaterial "paint_mirror" "string type" "mirror" "rgb Kr" [.1 .1 .1]
% MakeNamedMaterial "paint_base" "string type" "substrate" "color Kd" [.7 .125 .125] "color Ks" [.1 .1 .1] "float uroughness" .01 "float vroughness" .01 
% MakeNamedMaterial "BODY"  "string type" "mix" "string namedmaterial1" [ "paint-mirror" ] "string namedmaterial2" [ "paint-base" ] 
%
% We aren't sure about the whole set of possibilities.  We have
% covered the ones in our current Cinema 4D export.  But ...
%

%%
nLetters = length('MakeNamedMaterial');
nLines = length(txtLines);

%% Parse the string on the material line
cnt = 0;
for ii=1:nLines
    thisLine = txtLines{ii};
    if strncmp(thisLine,'MakeNamedMaterial',nLetters)
        cnt = cnt+1;

        thisLine = textscan(thisLine,'%q');
        thisLine = thisLine{1};
        nStrings = size(thisLine);

        % It does, so this is the start
        materials(cnt) = piMaterialCreate;
        materials(cnt).linenumber = ii;
        materials(cnt).name = thisLine{2};
        
        % For strings 3 to the end, parse
        for ss=3:nStrings
            
            switch thisLine{ss}
                case 'string type'
                    materials(cnt).string = thisLine{ss+1};

                case 'float index'
                    materials(cnt).floatindex = piParseNumericString(thisLine{ss+1});
                    
                case 'texture Kd'
                    materials(cnt).texturekd = thisLine{ss+1};
                    
                case 'texture Ks'
                    materials(cnt).textureks = thisLine{ss+1};
                    
                case 'texture Kr'
                    materials(cnt).texturekr = thisLine{ss+1};
                    
                case 'rgb Kr'
                    materials(cnt).rgbkr = piParseRGB(thisLine,ss);

                case 'rgb Ks'
                    materials(cnt).rgbks = piParseRGB(thisLine,ss); 

                case 'rgb Kd'
                    materials(cnt).rgbkd = piParseRGB(thisLine,ss);

                case 'rgb Kt'
                    materials(cnt).rgbkt = piParseRGB(thisLine,ss);

                case 'color Kd'
                    materials(cnt).colorkd = piParseRGB(thisLine,ss);

                case 'color Ks'
                    materials(cnt).colorks = piParseRGB(thisLine,ss);

                case 'float uroughness'
                    materials(cnt).floaturoughness = piParseNumericString(thisLine{ss+1});
                case 'float vroughness'
                    materials(cnt).floatvroughness = piParseNumericString(thisLine{ss+1});
                case 'float roughness'
                    materials(cnt).floatroughness = piParseNumericString(thisLine{ss+1});
                case 'spectrum Kd'
                    materials(cnt).spectrumkd = thisLine{ss+1};
                case 'spectrum Ks'
                    materials(cnt).spectrumks = thisLine{ss+1};
                case 'spectrum k'
                    materials(cnt).spectrumk = thisLine{ss+1};
                case 'spectrum Kr'
                    % How do we check if it's going to be a string or numeric values?  
                    materials(cnt).spectrumkr = piParseNumericSpectrum(thisLine,ss); 
                case 'spectrum Kt'
                    materials(cnt).spectrumkt = piParseNumericSpectrum(thisLine,ss); 
                case 'spectrum eta'
                    materials(cnt).spectrumeta = thisLine{ss+1};
                case 'string namedmaterial1'
                    materials(cnt).stringnamedmaterial1 = thisLine{ss+1};
                case 'string namedmaterial2'
                    materials(cnt).stringnamedmaterial2 = thisLine{ss+1};
                case 'texture bumpmap'
                    materials(cnt).texturebumpmap = thisLine{ss+1};
                case 'bool remaproughness'
                    materials(cnt).boolremaproughness = thisLine{ss+1};
                case 'string bsdffile'   
                    materials(cnt).bsdffile = thisLine{ss+1};
                case 'photolumi fluorescence'
                    materials(cnt).photolumifluorescence = thisLine{ss+1};
                otherwise
                    % fprintf('Unknown case %s\n',thisLine{ss});
            end
        end
    end
end
for jj = 1:cnt
materiallist.(materials(jj).name)= materials(jj);
end
fprintf('Read %d materials on %d lines\n',cnt,nLines);

end