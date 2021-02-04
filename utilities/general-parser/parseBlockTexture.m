function texturelist = parseBlockTexture(textureLines,ii)
%% Parse the string on the material line
thisLine = textureLines;
thisLine = erase(thisLine,'[ ');
thisLine = erase(thisLine,' ]');

thisLine = textscan(thisLine, '%q');
thisLine = thisLine{1};
nStrings = numel(thisLine);
texturelist.linenumber = ii;
texturelist.name = thisLine{2};
% For strings 3 to end, parse the parameters
for ss = 3:nStrings
    switch thisLine{ss}
        case 'spectrum'
            texturelist.format = 'spectrum';
        case 'float'
            texturelist.format = 'float';
        case {'constant', 'scale', 'mix', 'bilerp', 'imagemap',...
                'checkerboard', 'dots', 'fbm', 'wrinkled', 'marble'}
            texturelist.type = thisLine{ss};
        case 'string mapping'
            texturelist.stringmapping = thisLine{ss+1};
        case 'float uscale'
            texturelist.floatuscale = piParseNumericString(thisLine{ss+1});
        case 'float vscale'
            texturelist.floatvscale = piParseNumericString(thisLine{ss+1});
        case 'float udelta'
            texturelist.floatudelta = piParseNumericString(thisLine{ss+1});
        case 'float vdelta'
            texturelist.floatvdelta = piParseNumericString(thisLine{ss+1});
        case 'vector v1'
            texturelist.vectorv1 = piParseRGB(thisLine, ss);
        case 'vector v2'
            texturelist.vectorv2 = piParseRGB(thisLine, ss);
        case 'spectrum value'
            texturelist.spectrumvalue = thisLine{ss+1};
        case 'float value'
            texturelist.floatvalue = piParseNumericString(thisLine{ss+1});
        case 'spectrum tex1'
            texturelist.spectrumtex1 = thisLine{ss+1};
        case 'float tex1'
            texturelist.floattex1 = piParseNumericString(thisLine{ss+1});
        case 'spectrum tex2'
            texturelist.spectrumtex2 = thisLine{ss+1};
        case 'float tex2'
            texturelist.floattex2 = piParseNumericString(thisLine{ss+1});
        case 'float amount'
            texturelist.floatamount = piParseNumericString(thisLine{ss+1});
        case 'spectrum v00'
            texturelist.spectrumv00 = thisLine{ss+1};
        case 'spectrum v01'
            texturelist.spectrumv01 = thisLine{ss+1};
        case 'spectrum v10'
            texturelist.spectrumv10 = thisLine{ss+1};
        case 'spectrum v11'
            texturelist.spectrumv11 = thisLine{ss+1};
        case 'float v00'
            texturelist.floatv00 = piParseNumericString(thisLine{ss+1});
        case 'float v01'
            texturelist.floatv01 = piParseNumericString(thisLine{ss+1});
        case 'float v10'
            texturelist.floatv10 = piParseNumericString(thisLine{ss+1});
        case 'float v11'
            texturelist.floatv11 = piParseNumericString(thisLine{ss+1});
        case 'string filename'
            texturelist.stringfilename = thisLine{ss+1};
        case 'string wrap'
            texturelist.stringwarp = thisLine{ss+1};
        case 'float maxanisotropy'
            texturelist.floatmaxanisotropy = piParseNumericString(thisLine{ss+1});
        case 'bool trilinear'
            texturelist.booltrilinear = thisLine{ss+1};
        case 'float scale'
            texturelist.floatscale = piParseNumericString(thisLine{ss+1});
        case 'bool gamma'
            texturelist.boolgamma = thisLine{ss+1};
        case 'integer dimension'
            texturelist.integerdimension = int16(piParseNumericString(thisLine{ss+1}));
        case 'string aamode'
            texturelist.stringaamode = thisLine{ss+1};
        case 'spectrum inside'
            texturelist.spectruminside = thisLine{ss+1};
        case 'float inside'
            texturelist.floatinside = piParseNumericString(thisLine{ss+1});
        case 'spectrum outside'
            texturelist.spectrumoutside = thisLine{ss+1};
        case 'float outside'
            texturelist.floatoutside = piParseNumericString(thisLine{ss+1});
        case 'integer octaves'
            texturelist.integeroctaves = int16(piParseNumericString(thisLine{ss+1}));
        case 'float roughness'
            texturelist.floatroughness = piParseNumericString(thisLine{ss+1});
        case 'float variation'
            texturelist.floatvariation = piParseNumericString(thisLine{ss+1});
        case 'spectrum basisone'
            texturelist.spectrumbasisone = thisLine{ss+1};
        case 'spectrum basistwo'
            texturelist.spectrumbasistwo = thisLine{ss+1};
        case 'spectrum basisthree'
            texturelist.spectrumbasisthree = thisLine{ss+1};
    end
end
end