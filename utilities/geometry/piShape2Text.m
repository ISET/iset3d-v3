function txt = piShape2Text(shape)
% Convert the shape struct to text
%%
txt = "Shape ";

if isfield(shape, 'meshshape')
    txt = strcat(txt, '"', shape.meshshape, '"', " ");
end

if isfield(shape, 'integerindices')
    txt = strcat(txt, '"integer indices"', shape.integerindices," ");
end
if isfield(shape, 'pointp')
    txt = strcat(txt, '"point P"', shape.pointp, " ");
end
if isfield(shape, 'floatuv')
    txt = strcat(txt, '"float uv"', shape.floatuv, " ");
end
if isfield(shape, 'normaln')
    txt = strcat(txt, '"normal N"', shape.normaln);
end
end