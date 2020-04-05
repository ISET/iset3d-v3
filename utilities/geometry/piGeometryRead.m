function renderRecipe = piGeometryRead(renderRecipe)
%% Read a C4d geometry file and extract object information into a recipe
%
% Syntax:
%   renderRecipe = piGeometryRead(renderRecipe)
%
% Input
%   renderRecipe:  an iset3d recipe object describing the rendering
%     parameters.  This includes the inputFile and the outputFile,
%     which are used to find the  directories containing all of the
%     pbrt scene data.
%
%Return
%    renderRecipe - Updated by the processing in this function
%
% Zhenyi, 2018
% Henryk Blasinski 2020

%%
p = inputParser;
p.addRequired('renderRecipe',@(x)isequal(class(x),'recipe'));

%% Check version number
if(renderRecipe.version ~= 3)
    error('Only PBRT version 3 Cinema 4D exporter is supported.');
end

%% give a geometry.pbrt

% Best practice is to initalize the ouputFile.  Sometimes people
% don't.  So we do this as the default behavior.
[inFilepath, scene_fname] = fileparts(renderRecipe.inputFile);
inputFile = fullfile(inFilepath,sprintf('%s_geometry.pbrt',scene_fname));

% Save the JSON file at AssetInfo
% outputFile  = renderRecipe.outputFile;
outFilepath = fileparts(renderRecipe.outputFile);
AssetInfo   = fullfile(outFilepath,sprintf('%s.json',scene_fname));

%% Open the geometry file

% Read all the text in the file.  Read this way the text indents are
% ignored.
fileID = fopen(inputFile);
tmp = textscan(fileID,'%s','Delimiter','\n');
txtLines = tmp{1};
fclose(fileID);

%% Check whether the geometry have already been converted from C4D

% If it was converted, we don't need to do much work.
if piContains(txtLines(1),'# PBRT geometry file converted from C4D exporter output')
    convertedflag = true;
else
    convertedflag = false;
end

if ~convertedflag
    % It was not converted, so we go to work.
    % Check if a nested structure is exists
    
    renderRecipe.assets = parseText(txtLines);

    % jsonwrite(AssetInfo,renderRecipe);
    % fprintf('piGeometryRead done.\nSaving render recipe as a JSON file %s.\n',AssetInfo);
    
else
    % The converted flag is true, so AssetInfo is already stored in a
    % JSON file with the recipe information.  We just copy it isnto the
    % recipe.
    renderRecipe_tmp = jsonread(AssetInfo);
    
    % There may be a utility that accomplishes this.  We should find
    % it and use it here.
    fds = fieldnames(renderRecipe_tmp);
    renderRecipe = recipe;
    
    % Assign the each field in the struct to a recipe class
    for dd = 1:length(fds)
        renderRecipe.(fds{dd})= renderRecipe_tmp.(fds{dd});
    end
    
end

end


function [res, children, parsedUntil] = parseText(txt)

res = [];
groupobjs = [];
children = [];

i = 1;
while i <= length(txt)
    
    currentLine = txt{i};

    % Return if we've reached the current attribute
    if strcmp(currentLine,'AttributeEnd')
        
        % Assemble all the read attributes into either a groub object, or a
        % geometry object. Only group objects can have subnodes.
        
        if exist('rot','var') || exist('position','var')
            resCurrent = createGroupObject();
            if exist('name','var'), resCurrent.name = name; end
            if exist('size','var'), resCurrent.size = sz; end
            if exist('rotate','var'), resCurrent.rotate = rot; end
            if exist('position','var'), resCurrent.position = position; end
            
            resCurrent.groupobjs = groupobjs;
            resCurrent.children = children;
            children = [];
            res = cat(1,res,resCurrent);
            
        elseif exist('shape','var') || exist('mediumInterface','var') || exist('mat','var') || exist('areaLight','var') || exist('lght','var')
            resChildren = createGeometryObject();
            
            if exist('shape','var'), resChildren.shape = shape; end
            if exist('medium','var'), resChildren.medium = medium; end
            if exist('mat','var'), resChildren.material = mat; end
            if exist('lght','var'), resChildren.light = lght; end
            if exist('areaLight','var'), resChildren.areaLight = areaLight; end
            if exist('name','var'), resChildren.name = name; end
            
            children = cat(1,children, resChildren);
        
        elseif exist('name','var')
            resCurrent = createGroupObject();
            if exist('name','var'), resCurrent.name = name; end
           
            resCurrent.groupobjs = groupobjs;
            resCurrent.children = children;
            children = [];
            res = cat(1,res,resCurrent);  
        end
           
        parsedUntil = i;
        return;
        
    elseif strcmp(currentLine,'AttributeBegin')
        [subnodes, subchildren, retLine] = parseText(txt(i+1:end));
        groupobjs = cat(1, groupobjs, subnodes);
        children = cat(1, children, subchildren);
        i =  i + retLine;
        
    elseif contains(currentLine,'#ObjectName')
        [name, sz] = parseObjectName(currentLine);
        
    elseif contains(currentLine,'ConcatTransform')
        [rot, position] = parseConcatTransform(currentLine);
        
    elseif piContains(currentLine,'MediumInterface')
        medium = currentLine;
        
    elseif piContains(currentLine,'NamedMaterial')
        mat = currentLine;
        
    elseif piContains(currentLine,'AreaLightSource')
        areaLight = currentLine;
        
    elseif piContains(currentLine,'LightSource')
        lght = currentLine;
        
    elseif piContains(currentLine,'Shape')
        shape = currentLine;
        
    end

    i = i+1;
end

res = createGroupObject();
res.name = 'root';
res.groupobjs = groupobjs;
res.children = children;

parsedUntil = i;

end

function [name, sz] = parseObjectName(txt)

pattern = '#ObjectName';
loc = strfind(txt,pattern);

pos = strfind(txt,':');
name = txt(loc(1)+length(pattern) + 1:max(pos(1)-1, 1));

posA = strfind(txt,'(');
posB = strfind(txt,')');
res = sscanf(txt(posA(1)+1:posB(1)-1),'%f, %f, %f');

sz.pmin = [-res(1) -res(3)];
sz.pmax = [res(1) res(3)];

sz.l = 2*res(1);
sz.w = 2*res(2);
sz.h = 2*res(3);

end

function [rotation, translation] = parseConcatTransform(txt)

posA = strfind(txt,'[');
posB = strfind(txt,']');

tmp  = sscanf(txt(posA(1):posB(1)), '[%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
tform = reshape(tmp,[4,4]);
dcm = [tform(1:3); tform(5:7); tform(9:11)];
                    
[rotz,roty,rotx]= piDCM2angle(dcm);
rotx = rotx*180/pi;
roty = roty*180/pi;
rotz = rotz*180/pi;
                   
rotation = [rotx, roty, rotz;
            fliplr(eye(3));];

translation = reshape(tform(13:15),[3,1]);
end


function obj = createGroupObject()

obj.name = [];
obj.size.l = 0;
obj.size.w = 0;
obj.size.h = 0;
obj.size.pmin = [0 0];
obj.size.pmax = [0 0];
obj.scale = [1 1 1];
obj.position = [0 0 0];
obj.rotate = [0 0 0;
              0 0 1;
              0 1 0;
              1 0 0];

obj.children = [];
obj.groupobjs = [];
          

end

function obj = createGeometryObject()
% This function creates a geometry object and initializes all fields to
% empty values.

obj.name = [];
obj.index = [];
obj.mediumInterface = [];
obj.material = [];
obj.light = [];
obj.areaLight = [];
obj.shape = [];
obj.output = [];

end
