function output = piParseNumericSpectrum(thisLine,ss)
% A hack for now, since it's possible for there to be more than 4 values...
output = zeros(1,4);
output(1) = piParseNumericString(thisLine{ss+1});
output(2) = piParseNumericString(thisLine{ss+2});
output(3) = piParseNumericString(thisLine{ss+3});
output(4) = piParseNumericString(thisLine{ss+4});
end