function txt = piShape2Text(shape)
% Convert the shape struct to text
%%
txt = "Shape ";

if isfield(shape, 'meshshape') && ~isempty(shape.meshshape)
    txt = strcat(txt, '"', shape.meshshape, '"', " ");
end

if isfield(shape, 'integerindices') && ~isempty(shape.integerindices)
    txt = strcat(txt, '"integer indices"'," ", shape.integerindices," ");
end
if isfield(shape, 'pointp') && ~isempty(shape.pointp)
    txt = strcat(txt, '"point P"', " ", shape.pointp, " ");
end
if isfield(shape, 'floatuv') && ~isempty(shape.floatuv)
    txt = strcat(txt, '"float uv"', " ", shape.floatuv, " ");
end
if isfield(shape, 'normaln') && ~isempty(shape.normaln)
    txt = strcat(txt, '"normal N"', " ", shape.normaln);
end
end