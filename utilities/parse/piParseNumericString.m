function val = piParseNumericString(str)
str = strrep(str,'[','');
str = strrep(str,']','');
val = str2double(str);
end