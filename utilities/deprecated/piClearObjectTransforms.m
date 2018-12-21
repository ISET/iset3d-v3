function recipe = piClearObjectTransforms(recipe,objectName,varargin)
% Clear all existing transforms on an object 
%
% Syntax
%   recipe = piClearObjectTransforms(recipe,objectName,varargin)
%
% We look for an object within the WorldBegin/WorldEnd block with
% objectName. We then remove all transforms below it. 
%
% Input
%   recipe:         a recipe object that includes a WorldBegin/WorldEnd block.
%   objectName:     the name of the PBRT object we'd like to clear transforms
%                   for. This must match what's in the PBRT file

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
   
%% Look for the object within the world block

world = recipe.world;
transformLines = [];

% Find an ObjectBegin/ObjectEnd block within world. This will not always
% exist, especially for wild scenes that weren't exported from RTB4.
targetLine = sprintf('ObjectBegin "%s"',objectName);
foundFlag = 0;
for ii = 1:length(world)
    currLine = world{ii};
    if(strcmp(currLine,targetLine))
        
        foundFlag = 1;
        
        % Look for lines that have a transform
        noTransforms = 0;
        jj = ii;
        while(~noTransforms)
            jj = jj + 1;
            currLine = world{jj};
            if(~isempty(strfind(currLine,'Translate')) || ...
               ~isempty(strfind(currLine,'Scale')) || ...
               ~isempty(strfind(currLine,'Transform')) || ...
               ~isempty(strfind(currLine,'Rotate')))          
                % Save line indices
                transformLines = [transformLines jj];
            else
                noTransforms = 1;
            end
        end
        break;
        
    end
end

if(~foundFlag)
    warning('Did not find object: %s \n',objectName);
end

% Remove the offending lines
if(~isempty(transformLines))
    recipe.world = {world{1:transformLines(1)-1} world{transformLines(end)+1:end}};
end

end
