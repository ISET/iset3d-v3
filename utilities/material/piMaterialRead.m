function [materiallist, txtLines] = piMaterialRead(fname,varargin)
% Parses a *_material.pbrt file written by the PBRT Cinema 4D exporter
%
% Syntax:
%   [materialR, txtLines] = piReadMaterial(fname,varargin)
%
% Description
%  PBRT version 3 has a nice FBX exporter (Cinema 4D format).  We read
%  that file here so we can adjust the material properties within
%  Matlab.
%
% Inputs
%  fname:  Text file 
%
% Outputs:
%  materials: Array of material structs
%  txtLines:  All the text in the file
%
% ZL SCIEN Stanford, 2018
%
% See also:
%   piBlockExtract, piWriteMaterial
   
%{
materials = piReadMaterial('carandbuilding_materials.pbrt','version',3);
%}

%%
p = inputParser;
p.addRequired('fname',@(x)(exist(fname,'file')));
p.addParameter('recipe',[],@(x)(isequal(class(x),'recipe')));
p.addParameter('version',3,@(x)isnumeric(x));

p.parse(fname,varargin{:});

ver = p.Results.version;
thisR = p.Results.recipe;
%% Check version number
if(ver ~= 3)
    error('Only PBRT version 3 Cinema 4D exporter is supported.');
end
%%
TextureIndexList = find(piContains(thisR.world, 'Texture '));
if ~isempty(TextureIndexList)
    for ii = 1:length(TextureIndexList)
        IndexTexture = TextureIndexList(ii);
        % check indentation
        TextureLines{ii} = thisR.world{IndexTexture};
%         while strcmp(thisR.world{IndexTexture+1}(1),'"')
%             
%             TextureLines{ii} = [TextureLines{ii},' ',thisR.world{IndexTexture+1}];
%             IndexTexture = IndexTexture+1;
%             if isempty(thisR.world{IndexTexture+1}),break;end
%         end
    end
end
MaterialIndexList = find(piContains(thisR.world, 'MakeNamedMaterial '));
if ~isempty(MaterialIndexList)
    for ii = 1:length(MaterialIndexList)
        IndexMaterial = MaterialIndexList(ii);
        MaterialLines{ii} = thisR.world{IndexMaterial};
%         while strcmp(thisR.world{IndexMaterial+1}(1),'"')
%             MaterialLines{ii} = [MaterialLines{ii},' ',thisR.world{IndexMaterial+1}];
%             IndexMaterial = IndexMaterial+1;
%             if isempty(thisR.world{IndexMaterial+1}),break;end
%         end
    end
end
txtLines = [];
if ~isempty(TextureIndexList) && ~isempty(MaterialIndexList)
    txtLines = TextureLines; 
    if ~isempty(MaterialLines)
        for ii = 1:length(MaterialLines)
            txtLines{length(TextureLines)+ii}=MaterialLines{ii};
        end
    end
elseif isempty(TextureIndexList) && ~isempty(MaterialIndexList)
    txtLines = MaterialLines;
elseif isempty(MaterialIndexList) && ~isempty(TextureIndexList)
    txtLines = TextureLiens;
end
%% Read the text from the fname
if isempty(txtLines)
    % Open, read, close
    fileID = fopen(fname);
    tmp = textscan(fileID,'%s','Delimiter','\n','CommentStyle',{'#'});
    txtLines = tmp{1};
    fclose(fileID);
end

%% Extract lines that correspond to specified keyword
if ~isempty(txtLines)
    materiallist = piBlockExtractMaterial(txtLines);
else
    disp('No materials defined in the scene.')
end

%% pass materials to recipe.materials
% thisR = recipe;
% thisR.materials = materials;
% thisR.txtLines = txtLines;
end

function materiallist = piBlockExtractMaterial(txtLines)
% Extract parameters of a material from a block of text
%
% Syntax:
%
% Desription:
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
        % remove brackets
        thisLine(strcmp(thisLine, '['))=[];
        thisLine(strcmp(thisLine, ']'))=[];
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
                    
                case 'rgb opacity'
                    materials(cnt).rgbopacity = piParseRGB(thisLine,ss);
                    
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

%%
function val = piParseNumericString(str)
str = strrep(str,'[','');
str = strrep(str,']','');
val = str2double(str);
end

%%
function rgb = piParseRGB(thisLine,ss)
r = piParseNumericString(thisLine{ss+1});
g = piParseNumericString(thisLine{ss+2});
b = piParseNumericString(thisLine{ss+3});
rgb = [r,g,b];
end

function output = piParseNumericSpectrum(thisLine,ss)
% A hack for now, since it's possible for there to be more than 4 values...
output = zeros(1,4);
output(1) = piParseNumericString(thisLine{ss+1});
output(2) = piParseNumericString(thisLine{ss+2});
output(3) = piParseNumericString(thisLine{ss+3});
output(4) = piParseNumericString(thisLine{ss+4});
end

