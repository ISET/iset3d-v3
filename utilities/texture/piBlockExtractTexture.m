function texturelist = piBlockExtractTexture(textureLines)

%%
nLines   = numel(textureLines);
%% Parse the string on the material line
for ii=1:nLines
    thisLine = textureLines{ii};
    thisLine = textscan(thisLine, '%q');
    thisLine = thisLine{1};
    nStrings = size(thisLine);
    
    textures(ii) = piTextureCreate;
    textures(ii).linenumber = ii;
    textures(ii).name = thisLine{2};
    
    % For strings 3 to end, parse the parameters
    for ss = 3:nStrings
        switch thisLine{ss}
            case 'spectrum'
                textures(ii).format = 'spectrum';
            case 'float'
                textures(ii).format = 'float';
            case {'constant', 'scale', 'mix', 'bilerp', 'imagemap',...
                  'checkerboard', 'dots', 'fbm', 'wrinkled', 'marble'}
                textures(ii).type = thisLine{ss};
            case 'string mapping'
                textures(ii).stringmapping = thisLine{ss+1};
            case 'float uscale'
                textures(ii).floatuscale = piParseNumericString(thisLine{ss+1});
            case 'float vscale'
                textures(ii).floatvscale = piParseNumericString(thisLine{ss+1});
            case 'float udelta'
                textures(ii).floatudelta = piParseNumericString(thisLine{ss+1});
            case 'float vdelta'
                textures(ii).floatvdelta = piParseNumericString(thisLine{ss+1});
            case 'vector v1'
                textures(ii).vectorv1 = piParseRGB(thisLine, ss);
            case 'vector v2'
                textures(ii).vectorv2 = piParseRGB(thisLine, ss);
            case 'spectrum value'
                textures(ii).spectrumvalue = thisLine{ss+1};
            case 'float value'
                textures(ii).floatvalue = piParseNumericString(thisLine{ss+1});
            case 'spectrum tex1'
                textures(ii).spectrumtex1 = thisLine{ss+1};
            case 'float tex1'
                textures(ii).floattex1 = piParseNumericString(thisLine{ss+1});
            case 'spectrum tex2'
                textures(ii).spectrumtex2 = thisLine{ss+1};
            case 'float tex2'
                textures(ii).floattex2 = piParseNumericString(thisLine{ss+1});
            case 'float amount'
                textures(ii).floatamount = piParseNumericString(thisLine{ss+1});
            case 'spectrum v00'
                textures(ii).spectrumv00 = thisLine{ss+1};
            case 'spectrum v01'
                textures(ii).spectrumv01 = thisLine{ss+1};
            case 'spectrum v10'
                textures(ii).spectrumv10 = thisLine{ss+1};
            case 'spectrum v11'
                textures(ii).spectrumv11 = thisLine{ss+1};
            case 'float v00'
                textures(ii).floatv00 = piParseNumericString(thisLine{ss+1});
            case 'float v01'
                textures(ii).floatv01 = piParseNumericString(thisLine{ss+1});
            case 'float v10'
                textures(ii).floatv10 = piParseNumericString(thisLine{ss+1});
            case 'float v11'
                textures(ii).floatv11 = piParseNumericString(thisLine{ss+1});
            case 'string filename'
                textures(ii).stringfilename = thisLine{ss+1};
            case 'string wrap'
                textures(ii).stringwarp = thisLine{ss+1};
            case 'float maxanisotropy'
                textures(ii).floatmaxanisotropy = piParseNumericString(thisLine{ss+1});
            case 'bool trilinear'
                textures(ii).booltrilinear = thisLine{ss+1};
            case 'float scale'
                textures(ii).floatscale = piParseNumericString(thisLine{ss+1});
            case 'bool gamma'
                textures(ii).boolgamma = thisLine{ss+1};
            case 'integer dimension'
                textures(ii).integerdimension = int16(piParseNumericString(thisLine{ss+1}));
            case 'string aamode'
                textures(ii).stringaamode = thisLine{ss+1};
            case 'spectrum inside'
                textures(ii).spectruminside = thisLine{ss+1};
            case 'float inside'
                textures(ii).floatinside = piParseNumericString(thisLine{ss+1});
            case 'spectrum outside'
                textures(ii).spectrumoutside = thisLine{ss+1};
            case 'float outside'
                textures(ii).floatoutside = piParseNumericString(thisLine{ss+1});
            case 'integer octaves'
                textures(ii).integeroctaves = int16(piParseNumericString(thisLine{ss+1}));
            case 'float roughness'
                textures(ii).floatroughness = piParseNumericString(thisLine{ss+1});
            case 'float variation'
                textures(ii).floatvariation = piParseNumericString(thisLine{ss+1});
            case 'spectrum basisone'
                textures(ii).spectrumbasisone = thisLine{ss+1};
            case 'spectrum basistwo'
                textures(ii).spectrumbasistwo = thisLine{ss+1};
            case 'spectrum basisthree'
                textures(ii).spectrumbasisthree = thisLine{ss+1};
        end
    end
end
for ii = 1:nLines
    texturelist.(textures(ii).name(isstrprop(textures(ii).name, 'alpha'))) = textures(ii);
end
fprintf('Read %d textures', nLines);
end