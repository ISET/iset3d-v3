function recipe = piMoveObject(recipe,objectName,transformType,transform,varargin)
% Move an object inside of a scene. 
%
% Syntax
%   recipe = piMoveObject(recipe,objectName,transformType,transform,varargin)
%
% We look for an object within the WorldBegin/WorldEnd block with
% objectName. We then insert the given transform, so the object can be
% translated, rotated, scaled, or transformed within the scene. 
%
% Input
%   recipe:         a recipe object that includes a WorldBegin/WorldEnd block.
%   objectName:     the name of the PBRT object we'd like to transform. This
%                   must match what's in the PBRT file
%   transformType:  translate, rotate, scale, or transform
%   transform:      Depends on the transform type. For translate it's [x y z],
%                   for rotate its a 4x1 vector of the rotation degree and the axis. For a
%                   transform it's a 4x4 transformation matrix. 
%
% Optional parameter/values
%
% Return
%    recipe - the same recipe but with an updated WorldBegin/WorldEnd
%             block.
%
% TL Scien Stanford 2017

%%
p = inputParser;
p.addRequired('recipe',@(x)isequal(class(x),'recipe'));
p.addRequired('objectName',@(x)ischar(x));
p.addRequired('transformType',@(x)ischar(x)); % TODO: Check that it matches a given transform type
p.addRequired('transform');

p.parse(recipe,objectName,transformType,transform,varargin{:});

%% Check input types and create transform line

switch transformType
    case {'Translate','translate'}
        if(size(transform,1) == 1 && size(transform,2) == 3)
            transformLine = sprintf('Translate %f %f %f', ...
                transform(1),transform(2),transform(3));
        end
    case {'Rotate','rotate'}
        if(size(transform,1) == 1 && size(transform,2) == 4)
            transformLine = sprintf('Rotate %f %f %f %f', ...
                transform(1),transform(2),transform(3),transform(4));
        end
    case {'Scale','scale'}
        if(size(transform,1) == 1 && size(transform,2) == 3)
            transformLine = sprintf('Scale %f %f %f', ...
                transform(1),transform(2),transform(3));
        end
    case {'Transform','transform'}
        warning('Transform case not implemented yet...');
    otherwise
        warning('Did not recognize transformType.');
end

if(isempty(transformLine))
    warning('Transform did not match the transform type.');
end
        
%% Look for the object within the world block

world = recipe.world;

% Find an ObjectBegin/ObjectEnd block within world. This will not always
% exist, especially for wild scenes that weren't exported from RTB4.
targetLine = sprintf('ObjectBegin "%s"',objectName);
foundFlag = 0;
for ii = 1:length(world)
    currLine = world{ii};
    if(strcmp(currLine,targetLine))
        
        foundFlag = 1;
        
        % Add line
        worldTop = {world{1:ii}};
        worldBottom = {world{ii+1:end}};
        newLine = {transformLine};
        recipe.world = [worldTop newLine worldBottom];
        
        break;
        
    end
end

if(~foundFlag)
    warning('Did not find object: %s \n',objectName);
end

end
