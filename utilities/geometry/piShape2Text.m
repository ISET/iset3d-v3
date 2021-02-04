function txt = piShape2Text(shape)
% Convert the shape struct to text
%%
txt = "Shape ";

if isfield(shape, 'meshshape') && ~isempty(shape.meshshape)
    txt = strcat(txt, '"', shape.meshshape, '"');
end
if isfield(shape, 'filename') && ~isempty(shape.filename)
    txt = strcat(txt, ' "string filename" ', ' "',shape.filename,'"');
end
if isfield(shape, 'integerindices') && ~isempty(shape.integerindices)
%{
% From dev branch
<<<<<<< HEAD
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
=======
%}
    txt = strcat(txt, ' "integer indices"', [' [',piNum2String(shape.integerindices),']',]);
end
if isfield(shape, 'pointp') && ~isempty(shape.pointp)
    txt = strcat(txt, ' "point P"', [' [',piNum2String(shape.pointp),']',]);
end
if isfield(shape, 'floatuv') && ~isempty(shape.floatuv)
    txt = strcat(txt, ' "float uv"', [' [',piNum2String(shape.floatuv),']',]);
end
if isfield(shape, 'normaln') && ~isempty(shape.normaln)
    txt = strcat(txt, ' "normal N"', [' [',piNum2String(shape.normaln),']',]);
end
if isfield(shape, 'height') && ~isempty(shape.height)
    txt = strcat(txt, ' "float height"', [' [',piNum2String(shape.height),']',]);
end
if isfield(shape, 'radius') && ~isempty(shape.radius)
    txt = strcat(txt, ' "float radius"', [' [',piNum2String(shape.radius),']',]);
end
if isfield(shape, 'zmin') && ~isempty(shape.zmin)
    txt = strcat(txt, ' "float zmin"', [' [',piNum2String(shape.zmin),']',]);
end
if isfield(shape, 'zmax') && ~isempty(shape.zmax)
    txt = strcat(txt, ' "float zmax"', [' [',piNum2String(shape.zmax),']',]);
end
if isfield(shape, 'p1') && ~isempty(shape.p1)
    txt = strcat(txt, ' "float p1"', [' [',piNum2String(shape.p1),']',]);
end
if isfield(shape, 'p1') && ~isempty(shape.p1)
    txt = strcat(txt, ' "float p1"', [' [',piNum2String(shape.p1),']',]);
end
if isfield(shape, 'p2') && ~isempty(shape.p2)
    txt = strcat(txt, ' "float p2"', [' [',piNum2String(shape.p2),']',]);
end
if isfield(shape, 'phimax') && ~isempty(shape.phimax)
    txt = strcat(txt, ' "float phimax"', [' [',piNum2String(shape.phimax),']',]);
end
end