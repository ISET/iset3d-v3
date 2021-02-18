function newTexture = parseBlockTexture(currentLine)

thisLine = strrep(currentLine,'[','');
thisLine = strrep(thisLine,']','');
if iscell(thisLine)
    thisLine = thisLine{1};
end
thisLine = strsplit(thisLine, {' "', '" ', '"', '  '});
switch thisLine{1}
    case 'Texture'
        textName = thisLine{2};
        form = thisLine{3};
        textType = thisLine{4};
    otherwise
        warning('Unable to resolve the texture line.')
        return
end

newTexture = piTextureCreate(textName, 'type', textType, 'format', form);

% Split the text line with ' "', '" ' and '"' to get key/val pair
thisLine = thisLine(~cellfun('isempty',thisLine));

for ss = 5:2:numel(thisLine)
    % Get parameter type and name
    keyTypeName = strsplit(thisLine{ss}, ' ');
    keyType = ieParamFormat(keyTypeName{1});
    keyName = ieParamFormat(keyTypeName{2});
    
    switch keyType
        case {'string'}
            thisVal = thisLine{ss + 1};
        case {'float', 'rgb', 'color'}
            thisVal = str2num(thisLine{ss + 1});
        case {'integer'}
            thisVal = uint64(str2num(thisLine{ss + 1}));
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
    
    newTexture = piTextureSet(newTexture, sprintf('%s value', keyName),...
        thisVal);
end
%{
%% Parse the string on the material line
thisLine = currentLine;
thisLine = erase(thisLine,'[ ');
thisLine = erase(thisLine,' ]');

thisLine = textscan(thisLine, '%q');
thisLine = thisLine{1};
nStrings = numel(thisLine);
newTexture.linenumber = 1;
newTexture.name = thisLine{2};
% For strings 3 to end, parse the parameters
for ss = 3:nStrings
    switch thisLine{ss}
        case 'spectrum'
            newTexture.format = 'spectrum';
        case 'float'
            newTexture.format = 'float';
        case {'constant', 'scale', 'mix', 'bilerp', 'imagemap',...
                'checkerboard', 'dots', 'fbm', 'wrinkled', 'marble'}
            newTexture.type = thisLine{ss};
        case 'string mapping'
            newTexture.stringmapping = thisLine{ss+1};
        case 'float uscale'
            newTexture.floatuscale = piParseNumericString(thisLine{ss+1});
        case 'float vscale'
            newTexture.floatvscale = piParseNumericString(thisLine{ss+1});
        case 'float udelta'
            newTexture.floatudelta = piParseNumericString(thisLine{ss+1});
        case 'float vdelta'
            newTexture.floatvdelta = piParseNumericString(thisLine{ss+1});
        case 'vector v1'
            newTexture.vectorv1 = piParseRGB(thisLine, ss);
        case 'vector v2'
            newTexture.vectorv2 = piParseRGB(thisLine, ss);
        case 'spectrum value'
            newTexture.spectrumvalue = thisLine{ss+1};
        case 'float value'
            newTexture.floatvalue = piParseNumericString(thisLine{ss+1});
        case 'spectrum tex1'
            newTexture.spectrumtex1 = thisLine{ss+1};
        case 'float tex1'
            newTexture.floattex1 = piParseNumericString(thisLine{ss+1});
        case 'spectrum tex2'
            newTexture.spectrumtex2 = thisLine{ss+1};
        case 'float tex2'
            newTexture.floattex2 = piParseNumericString(thisLine{ss+1});
        case 'float amount'
            newTexture.floatamount = piParseNumericString(thisLine{ss+1});
        case 'spectrum v00'
            newTexture.spectrumv00 = thisLine{ss+1};
        case 'spectrum v01'
            newTexture.spectrumv01 = thisLine{ss+1};
        case 'spectrum v10'
            newTexture.spectrumv10 = thisLine{ss+1};
        case 'spectrum v11'
            newTexture.spectrumv11 = thisLine{ss+1};
        case 'float v00'
            newTexture.floatv00 = piParseNumericString(thisLine{ss+1});
        case 'float v01'
            newTexture.floatv01 = piParseNumericString(thisLine{ss+1});
        case 'float v10'
            newTexture.floatv10 = piParseNumericString(thisLine{ss+1});
        case 'float v11'
            newTexture.floatv11 = piParseNumericString(thisLine{ss+1});
        case 'string filename'
            newTexture.stringfilename = thisLine{ss+1};
        case 'string wrap'
            newTexture.stringwarp = thisLine{ss+1};
        case 'float maxanisotropy'
            newTexture.floatmaxanisotropy = piParseNumericString(thisLine{ss+1});
        case 'bool trilinear'
            newTexture.booltrilinear = thisLine{ss+1};
        case 'float scale'
            newTexture.floatscale = piParseNumericString(thisLine{ss+1});
        case 'bool gamma'
            newTexture.boolgamma = thisLine{ss+1};
        case 'integer dimension'
            newTexture.integerdimension = int16(piParseNumericString(thisLine{ss+1}));
        case 'string aamode'
            newTexture.stringaamode = thisLine{ss+1};
        case 'spectrum inside'
            newTexture.spectruminside = thisLine{ss+1};
        case 'float inside'
            newTexture.floatinside = piParseNumericString(thisLine{ss+1});
        case 'spectrum outside'
            newTexture.spectrumoutside = thisLine{ss+1};
        case 'float outside'
            newTexture.floatoutside = piParseNumericString(thisLine{ss+1});
        case 'integer octaves'
            newTexture.integeroctaves = int16(piParseNumericString(thisLine{ss+1}));
        case 'float roughness'
            newTexture.floatroughness = piParseNumericString(thisLine{ss+1});
        case 'float variation'
            newTexture.floatvariation = piParseNumericString(thisLine{ss+1});
        case 'spectrum basisone'
            newTexture.spectrumbasisone = thisLine{ss+1};
        case 'spectrum basistwo'
            newTexture.spectrumbasistwo = thisLine{ss+1};
        case 'spectrum basisthree'
            newTexture.spectrumbasisthree = thisLine{ss+1};
    end
end
%}
end