function materialList = piBlockExtractMaterial(thisR, txtLines, varargin)
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
%  thisR, txtLines
%
% Outputs:
%   materialR:  An array of structs defining the material
%
% Optional key/value pairs
%
% ZL SCIEN Stanford, 2018;
% Zheng Lyu, 2020
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

% Examples
%{
thisR = piRecipeDefault;
%}
%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('txtLines', @iscell);

p.parse(thisR, txtLines, varargin{:});

%% Parse the string on the material line
thisR.materials.list = cell(1, numel(txtLines));
for ii=1:numel(txtLines)
    thisLine = txtLines{ii};

    % Split the text line with ' "', '" ' and '"' to get key/val pair
    thisLine = strsplit(thisLine, {' "', '" ', '"'});
    thisLine = thisLine(~cellfun('isempty',thisLine));
    
    % Create a new material 
    matName = thisLine{2}; % Material name
    matType = thisLine{4}; % Material type
    newMat = piMaterialCreate(matName, 'type', matType);
    
    
    % For strings 3 to the end, parse
    for ss = 5:2:numel(thisLine)
        % Get parameter type and name
        keyTypeName = strsplit(thisLine{ss}, ' ');
        keyType = ieParamFormat(keyTypeName{1});
        keyName = ieParamFormat(keyTypeName{2});
        
        % Some corner cases
        % "index" should be replaced with "eta"
        switch keyName
            case 'index'
                keyName = 'eta';
        end
        
        switch keyType
            case {'string', 'texture'}
                thisVal = thisLine{ss + 1};
            case {'float', 'rgb', 'color', 'photolumi'}
                % Parse a float number from string
                % str2num can convert string to vector. str2double can't.
                thisVal = str2num(thisLine{ss + 1});
            case {'spectrum'}
                [~, ~, e] = fileparts(thisLine{ss + 1});
                if isequal(e, '.spd')
                    % Is a file
                    thisVal = thisLine{ss + 1};
                else
                    % Is vector
                    thisVal = str2num(thisLine{ss + 1});
                end
            case 'bool'
                if isequal(thisLine{ss + 1}, 'true')
                    thisVal = true;
                elseif isequal(thisLine{ss + 1}, 'false')
                    thisVal = false;
                end
            otherwise
                warning('Could not resolve the parameter type: %s', keyType);
                continue;
        end
        
        newMat = piMaterialSet(newMat, sprintf('%s value', keyName),...
                                thisVal);
        %{
        switch thisLine{ss}
            case 'string type'
                thisR.materials.list{ii}.stringtype = thisLine{ss+1};
            case 'float index'
                thisR.materials.list{ii}.floatindex = piParseNumericString(thisLine{ss+1});
            case 'texture Kd'
                thisR.materials.list{ii}.texturekd = thisLine{ss+1};
            case 'texture Ks'
                thisR.materials.list{ii}.textureks = thisLine{ss+1};
            case 'texture Kr'
                thisR.materials.list{ii}.texturekr = thisLine{ss+1};
            case 'rgb Kr'
                thisR.materials.list{ii}.rgbkr = piParseRGB(thisLine,ss);
            case 'rgb Ks'
                thisR.materials.list{ii}.rgbks = piParseRGB(thisLine,ss); 
            case 'rgb Kd'
                thisR.materials.list{ii}.rgbkd = piParseRGB(thisLine,ss);
            case 'rgb Kt'
                thisR.materials.list{ii}.rgbkt = piParseRGB(thisLine,ss);
            case 'color Kd'
                thisR.materials.list{ii}.colorkd = piParseRGB(thisLine,ss);
            case 'color Ks'
                thisR.materials.list{ii}.colorks = piParseRGB(thisLine,ss);
            case 'float uroughness'
                thisR.materials.list{ii}.floaturoughness = piParseNumericString(thisLine{ss+1});
            case 'float vroughness'
                thisR.materials.list{ii}.floatvroughness = piParseNumericString(thisLine{ss+1});
            case 'float roughness'
                thisR.materials.list{ii}.floatroughness = piParseNumericString(thisLine{ss+1});
            case 'spectrum Kd'
                thisR.materials.list{ii}.spectrumkd = thisLine{ss+1};
            case 'spectrum Ks'
                thisR.materials.list{ii}.spectrumks = thisLine{ss+1};
            case 'spectrum k'
                thisR.materials.list{ii}.spectrumk = thisLine{ss+1};
            case 'spectrum Kr'
                % How do we check if it's going to be a string or numeric values?  
                thisR.materials.list{ii}.spectrumkr = piParseNumericSpectrum(thisLine,ss); 
            case 'spectrum Kt'
                thisR.materials.list{ii}.spectrumkt = piParseNumericSpectrum(thisLine,ss); 
            case 'spectrum eta'
                thisR.materials.list{ii}.spectrumeta = thisLine{ss+1};
            case 'string namedmaterial1'
                thisR.materials.list{ii}.stringnamedmaterial1 = thisLine{ss+1};
            case 'string namedmaterial2'
                thisR.materials.list{ii}.stringnamedmaterial2 = thisLine{ss+1};
            case 'texture bumpmap'
                thisR.materials.list{ii}.texturebumpmap = thisLine{ss+1};
            case 'bool remaproughness'
                thisR.materials.list{ii}.boolremaproughness = thisLine{ss+1};
            case 'string bsdffile'   
                thisR.materials.list{ii}.bsdffile = thisLine{ss+1};
            case 'photolumi fluorescence'
                thisR.materials.list{ii}.photolumifluorescence = thisLine{ss+1};
        end
        %}
    end
    thisR.materials.list{ii} = newMat;
end

materialList = thisR.materials.list;
fprintf('Read %d materials\n', numel(materialList));

end