function mat = piParseGeometryMaterial(txt)
% Parse material name. It's quite easy,just split the text with ""
%
pos = strfind(txt, '"');
mat.namedmaterial = txt(pos(1) + 1:pos(2) - 1);
end