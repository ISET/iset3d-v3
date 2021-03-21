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
    switch shape.meshshape
        case 'disk'
            shape.height = piParameterGet(txt, 'float height');
            shape.radius = piParameterGet(txt, 'float radius');
            shape.phimax = piParameterGet(txt, 'float phimax');
            shape.innerradius = piParameterGet(txt, 'float innerradius');
        case 'shpere'
            shape.radius = piParameterGet(txt, 'float radius');
            shape.zmin = piParameterGet(txt, 'float zmin');
            shape.zmax = piParameterGet(txt, 'float zmax');
            shape.phimax = piParameterGet(txt, 'float phimax'); 
        case 'cone'
            shape.height = piParameterGet(txt, 'float height');
            shape.radius = piParameterGet(txt, 'float radius');
            shape.phimax = piParameterGet(txt, 'float phimax');           
        case 'cylinder'
            shape.radius = piParameterGet(txt, 'float radius');
            shape.zmin = piParameterGet(txt, 'float zmin');
            shape.zmax = piParameterGet(txt, 'float zmax');
            shape.phimax = piParameterGet(txt, 'float phimax');
        case 'hyperboloid'
            shape.p1 = piParameterGet(txt, 'point p1');
            shape.p2 = piParameterGet(txt, 'point p2');
            shape.phimax = piParameterGet(txt, 'float phimax');   
        case 'paraboloid'
            shape.radius = piParameterGet(txt, 'float radius');
            shape.zmin = piParameterGet(txt, 'float zmin');
            shape.zmax = piParameterGet(txt, 'float zmax');
            shape.phimax = piParameterGet(txt, 'float phimax');
        case 'curve'
            % todo
        case {'trianglemesh', 'plymesh'}
            
            if find(piContains(keyWords, 'filename'))
                shape.filename = piParameterGet(txt, 'string filename');
                %                 shape.filename = keyWords{find(piContains(keyWords, 'filename')) + 2};
            end
            if find(piContains(keyWords, 'integer indices'))
                shape.integerindices = uint64(piParameterGet(txt, 'integer indices'));
                % Convert it to integer format
                %                 shape.integerindices = keyWords{find(piContains(keyWords, 'integer indices')) + 1};
            end
            if find(piContains(keyWords, 'point P'))
                shape.pointp = piParameterGet(txt, 'point P');
                %                 shape.pointp = keyWords{find(piContains(keyWords, 'point P')) + 1};
            end
            if find(piContains(keyWords, 'float uv'))
                % If file extension is ply, don't do this. 
                ext = '';
                if ~isempty(shape.filename)
                    [~, ~, ext] = fileparts(shape.filename);
                end
                if isequal(ext, '.ply')
                else
                    shape.floatuv = piParameterGet(txt, 'float uv');
                    % shape.floatuv = keyWords{find(piContains(keyWords, 'float uv')) + 1};
                end
            end
            
            if find(piContains(keyWords, 'normal N'))
                shape.normaln = piParameterGet(txt, 'normal N');
                %                 shape.normaln = keyWords{find(piContains(keyWords, 'normal N')) + 1};
            end
            % to add
            % float/texture alpha
            % float/texture shadowalpha
        case 'heightfield'
            % todo
        case 'loopsubdiv'
            % todo
        case 'nurbs'
            % todo
    end
end

end

function s = shapeCreate
    s.meshshape = '';
    s.filename='';
    s.integerindices = '';
    s.pointp = '';
    s.floatuv = '';
    s.normaln = '';
    s.height = '';
    s.radius = '';
    s.zmin = '';
    s.zmax = '';
    s.p1 = '';
    s.p2='';
    s.phimax = '';
end