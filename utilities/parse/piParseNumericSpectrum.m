function [samples, values] = piParseNumericSpectrum(thisLine)
%{
thisLine = '400 0.1 500 0.2 600 0.3 700 0.5';
output = piParseNumericSpectrum(thisLine)
%}


thisLine = strsplit(thisLine, ' ');
if mod(numel(thisLine), 2)~=0
    error('Found odd number of values for spectrum.')
end
nSamples = numel(thisLine)/2;
for ii = 1:nSamples
    samples(1, ii) = str2num(thisLine{ii*2-1});
    values(1, ii) = str2num(thisLine{ii});
end

%{
str
% A hack for now, since it's possible for there to be more than 4 values...
output = zeros(1,4);
output(1) = piParseNumericString(thisLine{ss+1});
output(2) = piParseNumericString(thisLine{ss+2});
output(3) = piParseNumericString(thisLine{ss+3});
output(4) = piParseNumericString(thisLine{ss+4});
%}
end