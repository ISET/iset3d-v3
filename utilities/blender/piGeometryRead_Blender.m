function renderRecipe = piGeometryRead_Blender(renderRecipe)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: below added
% Adapted from piGeometryRead.m
% to extract scale and rotation information separately per object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read a C4d geometry file and extract object information into a recipe
%
% Syntax:
%   renderRecipe = piGeometryRead(renderRecipe)
%
% Input
%   renderRecipe:  an iset3d recipe object describing the rendering
%     parameters.  This object includes the inputFile and the
%     outputFile, which are used to find the  directories containing
%     all of the pbrt scene data.
%
% Return
%    renderRecipe - Updated by the processing in this function
%
% Zhenyi, 2018
% Henryk Blasinski 2020
%
% Description
%   This includes a bunch of sub-functions and a logic that needs further
%   description.
%
% See also
%   piGeometryWrite

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

% If it was converted into ISET3d format, we don't need to do much work.
if piContains(txtLines(1),'# PBRT geometry file converted from C4D exporter output')
    convertedflag = true;
else
    convertedflag = false;
end

if ~convertedflag
    % It was not converted, so we go to work.
    
    renderRecipe.assets = parseGeometryText(txtLines,'');

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

%%
function [res, children, parsedUntil] = parseGeometryText(txt, name)
%
% Inputs:
%
%   txt         - remaining text to parse
%   name        - current object name
%
% Outputs:
%   res         - struct of results
%   children    - Attributes under the current object
%   parsedUntil - line number of the parsing end
%
% Description:
%
%   The geometry text comes from C4D export. We parse the lines of text in 
%   'txt' cell array and recrursively create a tree structure of geometric objects.

res = [];
groupobjs = [];
children = [];

i = 1;
while i <= length(txt)
    
    currentLine = txt{i};
    
    % Return if we've reached the end of current attribute
    if strcmp(currentLine,'AttributeEnd')
        
        % Assemble all the read attributes into either a groub object, or a
        % geometry object. Only group objects can have subnodes (not
        % children). This can be confusing but is somewhat similar to
        % previous representation.
        
        if exist('rot','var') || exist('position','var')
            resCurrent = createGroupObject();
            
            % If present populate fields.
            if exist('name','var'), resCurrent.name = name; end
            if exist('sz','var'), resCurrent.size = sz; end
            if exist('rot','var'), resCurrent.rotate = rot; end
            if exist('position','var'), resCurrent.position = position; end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % NOTE: below added
            % to populate the 'scale' field
            
            if exist('scale','var'), resCurrent.scale = scale; end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        % This is an Attribute inside an Attribute
        [subnodes, subchildren, retLine] = parseGeometryText(txt(i+1:end), name);
        groupobjs = cat(1, groupobjs, subnodes);
        
        % Give an index to the subchildren to make it different from its
        % parents and brothers (we are not sure if it works for more than
        % two levels). We name the subchildren based on the line number and
        % how many subchildren there are already.
        if ~isempty(subchildren)
            subchildren.name = sprintf('%d_%d_%s', i, numel(children)+1, subchildren.name);
        end
        children = cat(1, children, subchildren);
        i =  i + retLine;
        
    elseif piContains(currentLine,'#ObjectName')
        [name, sz] = parseObjectName(currentLine);
        
    elseif piContains(currentLine,'ConcatTransform')
        [rot, position] = parseConcatTransform(currentLine);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % NOTE: below added
    % to extract scale and rotation information separately per object
    % (the Blender exporter uses 'Transform' instead of 'ConcatTransform'
    % per object, which is why the statement below looks for the 'Transform'
    % line, but the new 'parseTransform' helper function below could be 
    % used for 'ConcatTransform' lines from the C4D exporter as well)
    
    elseif piContains(currentLine,'Transform')
        [position, rot, scale] = parseTransform(currentLine);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    elseif piContains(currentLine,'MediumInterface')
        % MediumInterface could be water or other scattering media.
        medium = currentLine;
        
    elseif piContains(currentLine,'NamedMaterial')
        mat = currentLine;
        
    elseif piContains(currentLine,'AreaLightSource')
        areaLight = currentLine;
        
    elseif piContains(currentLine,'LightSource') ||...
            piContains(currentLine, 'Rotate') ||...
            piContains(currentLine, 'Scale')
        if ~exist('lght','var')
            lght{1} = currentLine;
        else
            lght{end+1} = currentLine;
        end
        
    elseif piContains(currentLine,'Shape')
        shape = currentLine;
    else
      %  warning('Current line skipped: %s', currentLine);
    end

    i = i+1;
end

res = createGroupObject();
res.name = 'root';
res.groupobjs = groupobjs;
res.children = children;

parsedUntil = i;

end

%%
function [name, sz] = parseObjectName(txt)
% Parse an ObjectName string in 'txt' to extract the object name and size.
%
% Cinema4D produces a line with #ObjectName in it. The format of the
% #ObjectName line appears to be something like this:
%
%   #ObjectName Plane:Vector(5000, 0, 5000)
%
% The only cases we have seen are NAME:Vector(X,Z,Y).  Someone seems to
% know the meaning of these three values which are read into 'res' below.
% The length is 2*X, width is 2*Y and height is 2*Z.
% 
% Perhaps these numbers should always be treated as in meters or maybe
% centimeters?  We need to figure this out.  For the slantedBar scene we
% had the example above, and we think the scene might be about 100 meters,
% so this would make sense.
%
% We do not have a routine to fill in these values for non-Cinema4D
% objects.


% Find the location of #ObjectName in the string
pattern = '#ObjectName';
loc = strfind(txt,pattern);

% Look for a colon
pos = strfind(txt,':');
name = txt(loc(1)+length(pattern) + 1:max(pos(1)-1, 1));

posA = strfind(txt,'(');
posB = strfind(txt,')');
res = sscanf(txt(posA(1)+1:posB(1)-1),'%f, %f, %f');

% Position minimima and maxima for lower left (X,Y), upper right.
sz.pmin = [-res(1) -res(3)];
sz.pmax = [res(1) res(3)];

% We are not really sure what these coordinates represent with respect to
% the scene or the camera direction.  For one case we analyzed (a plane)
% this is what the values meant.
sz.l = 2*res(1);   % length (X)
sz.w = 2*res(2);   % depth (Z)
sz.h = 2*res(3);   % height (Y)

end

%%
function [rotation, translation] = parseConcatTransform(txt)
% Given a string 'txt' extract the information about transform.

posA = strfind(txt,'[');
posB = strfind(txt,']');

tmp  = sscanf(txt(posA(1):posB(1)), '[%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
tform = reshape(tmp,[4,4]);
dcm = [tform(1:3); tform(5:7); tform(9:11)];
                    
[rotz,roty,rotx]= piDCM2angle(dcm);
if ~isreal(rotz) || ~isreal(roty) || ~isreal(rotx)
    warning('piDCM2angle returned complex angles.  JSONWRITE will fail.');
    % dcm
    % txt(posA(1):posB(1))
end

%{
% Forcing to real is not a good idea.  
rotx = real(rotx*180/pi);
roty = real(roty*180/pi);
rotz = real(rotz*180/pi);
%}
% {                   
rotx = rotx*180/pi;
roty = roty*180/pi;
rotz = rotz*180/pi;
%}

% Comment needed
rotation = [rotz, roty, rotx;
                fliplr(eye(3))];

translation = reshape(tform(13:15),[3,1]);
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: helper function added
% to extract translation, rotation, and scale parameters from the 
% transformation matrix
% (this helper function is currently only called for Blender exports 
% because the Blender export uses 'Transform' understead of 
% 'ConcatTransform', but this helper function could be called for
% 'ConcatTransform' lines from the C4D exporter as well)

function [translation, rotation, scale] = parseTransform(txt)

% Get transformation matrix from the input (the 'Transform' line)
openidx  = strfind(txt,'[');
closeidx = strfind(txt,']');
tmp = sscanf(txt(openidx(1):closeidx(1)), '[%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
T = reshape(tmp,[4,4]);

% Extract translation from the transformation matrix
translation = reshape(T(13:15),[3,1]);

% Compute new transformation matrix without translation
T = T(1:3,1:3);

% Extract the pure rotation component of the new transformation matrix
% using polar decomposition (the pbrt method)
R = T;
ii=0;
normii=1;
while ii<100 && normii>.0001
    % Successively average the matrix with its inverse transpose until
    % convergence
    Rnext = 0.5 * (R + inv(R.'));
    % Compute norm of difference between R and Rnext
    normii = norm(abs(R - Rnext));
    % Reset for next iteration
    R = Rnext;
    ii = ii+1;
end

% Calculate rotation angles about the X, Y, and Z axes from the transform matrix
% (citation: Slabaugh, Gregory G., "Computing Euler angles from a rotation matrix", 
% https://www.gregslabaugh.net/publications/euler.pdf, December 5, 2020)
if abs(round(R(3,1),2))~=1
    roty = -asin(R(3,1));
    cosy = cos(roty);
    rotx = atan2(R(3,2)/cosy, R(3,3)/cosy);
    rotz = atan2(R(2,1)/cosy, R(1,1)/cosy);
else
    rotz = 0;
    if R(3,1)==-1
        roty = pi/2;
        rotx = rotz + atan2(R(1,2),R(1,3));
    else
        roty = -pi/2;
        rotx = -rotz + atan2(-R(1,2),-R(1,3));
    end
end

% Convert rotation angles from radians to degrees
rotx = rotx*180/pi;
roty = roty*180/pi;
rotz = rotz*180/pi;

% Set up rotation matrix in pbrt format
rotation = [rotz, roty, rotx; fliplr(eye(3))];

% Compute scale matrix using rotation matrix and transformation matrix
S = R\T;

% Set up scale parameters in pbrt format
scale = [S(1,1) S(2,2), S(3,3)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%
function obj = createGroupObject()
% Initialize a structure representing a group object.
%
% What makes something a group object rather than a child?
% What if we want to read the nodes and edges of an object, can we do it?

obj.name = [];      % String
obj.size.l = 0;     % Length
obj.size.w = 0;     % Width
obj.size.h = 0;     % Height
obj.size.pmin = [0 0];    % No idea
obj.size.pmax = [0 0];    % No idea

obj.scale = [1 1 1];
obj.position = [0 0 0];   % Maybe the middle of the object?

obj.rotate = [0 0 0;
              0 0 1;
              0 1 0;
              1 0 0];

obj.children = [];
obj.groupobjs = [];
          

end

%%
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
