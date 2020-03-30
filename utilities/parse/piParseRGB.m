function rgb = piParseRGB(thisLine,ss)
r = piParseNumericString(thisLine{ss+1});
g = piParseNumericString(thisLine{ss+2});
b = piParseNumericString(thisLine{ss+3});
rgb = [r,g,b];
end