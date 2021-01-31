function shape = piParseShape(txt)
% Parse the shape information into struct
% Logic:
%   Normally the shape line has this format:
%   'Shape "SHAPE" "integerindices" [] "point P" [] 
%    "float uv" [] "normal N" []'
%   We split the string based on the '"' and get each component
%
% Test
%{
thisR = piRecipeDefault('scene name', 'MacBethChecker');
%}
%%
keyWords = strsplit(txt, '"');
shape = shapeCreate;
% keyWords
if find(piContains(keyWords, 'Shape '))
    shape.meshshape = keyWords{find(piContains(keyWords, 'Shape ')) + 1};
end
if find(piContains(keyWords, 'integer indices'))
    shape.integerindices = keyWords{find(piContains(keyWords, 'integer indices')) + 1};
end
if find(piContains(keyWords, 'point P'))
    shape.pointp = keyWords{find(piContains(keyWords, 'point P')) + 1};
end
if find(piContains(keyWords, 'float uv'))
    shape.floatuv = keyWords{find(piContains(keyWords, 'float uv')) + 1};
end

if find(piContains(keyWords, 'normal N'))
    shape.normaln = keyWords{find(piContains(keyWords, 'normal N')) + 1};
end
end

function s = shapeCreate
    s.meshshape = '';
    s.integerindices = '';
    s.pointp = '';
    s.floatuv = '';
    s.normaln = '';
end