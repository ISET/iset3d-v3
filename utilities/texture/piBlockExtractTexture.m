function texturelist = piBlockExtractTexture(thisR, textureLines)

%%
nLines   = numel(textureLines);
%% Parse the string on the material line
for ii=1:nLines
    thisLine = textureLines{ii};
    thisLine = textscan(thisLine, '%q');
    thisLine = thisLine{1};
    nStrings = size(thisLine);
    
    
    piTextureCreate(thisR, 'name', thisLine{2}, 'linenumber', ii);

    % For strings 3 to end, parse the parameters
    for ss = 3:nStrings
        switch thisLine{ss}
            case 'spectrum'
                thisR.textures.list{ii}.format = 'spectrum';
            case 'float'
                thisR.textures.list{ii}.format = 'float';
            case {'constant', 'scale', 'mix', 'bilerp', 'imagemap',...
                  'checkerboard', 'dots', 'fbm', 'wrinkled', 'marble'}
                thisR.textures.list{ii}.type = thisLine{ss};
            case 'string mapping'
                thisR.textures.list{ii}.stringmapping = thisLine{ss+1};
            case 'float uscale'
                thisR.textures.list{ii}.floatuscale = piParseNumericString(thisLine{ss+1});
            case 'float vscale'
                thisR.textures.list{ii}.floatvscale = piParseNumericString(thisLine{ss+1});
            case 'float udelta'
                thisR.textures.list{ii}.floatudelta = piParseNumericString(thisLine{ss+1});
            case 'float vdelta'
                thisR.textures.list{ii}.floatvdelta = piParseNumericString(thisLine{ss+1});
            case 'vector v1'
                thisR.textures.list{ii}.vectorv1 = piParseRGB(thisLine, ss);
            case 'vector v2'
                thisR.textures.list{ii}.vectorv2 = piParseRGB(thisLine, ss);
            case 'spectrum value'
                thisR.textures.list{ii}.spectrumvalue = thisLine{ss+1};
            case 'float value'
                thisR.textures.list{ii}.floatvalue = piParseNumericString(thisLine{ss+1});
            case 'spectrum tex1'
                thisR.textures.list{ii}.spectrumtex1 = thisLine{ss+1};
            case 'float tex1'
                thisR.textures.list{ii}.floattex1 = piParseNumericString(thisLine{ss+1});
            case 'spectrum tex2'
                thisR.textures.list{ii}.spectrumtex2 = thisLine{ss+1};
            case 'float tex2'
                thisR.textures.list{ii}.floattex2 = piParseNumericString(thisLine{ss+1});
            case 'float amount'
                thisR.textures.list{ii}.floatamount = piParseNumericString(thisLine{ss+1});
            case 'spectrum v00'
                thisR.textures.list{ii}.spectrumv00 = thisLine{ss+1};
            case 'spectrum v01'
                thisR.textures.list{ii}.spectrumv01 = thisLine{ss+1};
            case 'spectrum v10'
                thisR.textures.list{ii}.spectrumv10 = thisLine{ss+1};
            case 'spectrum v11'
                thisR.textures.list{ii}.spectrumv11 = thisLine{ss+1};
            case 'float v00'
                thisR.textures.list{ii}.floatv00 = piParseNumericString(thisLine{ss+1});
            case 'float v01'
                thisR.textures.list{ii}.floatv01 = piParseNumericString(thisLine{ss+1});
            case 'float v10'
                thisR.textures.list{ii}.floatv10 = piParseNumericString(thisLine{ss+1});
            case 'float v11'
                thisR.textures.list{ii}.floatv11 = piParseNumericString(thisLine{ss+1});
            case 'string filename'
                thisR.textures.list{ii}.stringfilename = thisLine{ss+1};
            case 'string wrap'
                thisR.textures.list{ii}.stringwarp = thisLine{ss+1};
            case 'float maxanisotropy'
                thisR.textures.list{ii}.floatmaxanisotropy = piParseNumericString(thisLine{ss+1});
            case 'bool trilinear'
                thisR.textures.list{ii}.booltrilinear = thisLine{ss+1};
            case 'float scale'
                thisR.textures.list{ii}.floatscale = piParseNumericString(thisLine{ss+1});
            case 'bool gamma'
                thisR.textures.list{ii}.boolgamma = thisLine{ss+1};
            case 'integer dimension'
                thisR.textures.list{ii}.integerdimension = int16(piParseNumericString(thisLine{ss+1}));
            case 'string aamode'
                thisR.textures.list{ii}.stringaamode = thisLine{ss+1};
            case 'spectrum inside'
                thisR.textures.list{ii}.spectruminside = thisLine{ss+1};
            case 'float inside'
                thisR.textures.list{ii}.floatinside = piParseNumericString(thisLine{ss+1});
            case 'spectrum outside'
                thisR.textures.list{ii}.spectrumoutside = thisLine{ss+1};
            case 'float outside'
                thisR.textures.list{ii}.floatoutside = piParseNumericString(thisLine{ss+1});
            case 'integer octaves'
                thisR.textures.list{ii}.integeroctaves = int16(piParseNumericString(thisLine{ss+1}));
            case 'float roughness'
                thisR.textures.list{ii}.floatroughness = piParseNumericString(thisLine{ss+1});
            case 'float variation'
                thisR.textures.list{ii}.floatvariation = piParseNumericString(thisLine{ss+1});
            case 'spectrum basisone'
                thisR.textures.list{ii}.spectrumbasisone = thisLine{ss+1};
            case 'spectrum basistwo'
                thisR.textures.list{ii}.spectrumbasistwo = thisLine{ss+1};
            case 'spectrum basisthree'
                thisR.textures.list{ii}.spectrumbasisthree = thisLine{ss+1};
        end
    end
end

thisR.textures.list = thisR.textures.list';
texturelist = thisR.textures.list;
fprintf('Read %d textures\n', nLines);
end