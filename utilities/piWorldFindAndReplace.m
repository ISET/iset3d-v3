function recipe = piWorldFindAndReplace(recipe,oldString,newString,varargin)
%
% Syntax
%   recipe = piFindAndReplace(recipe,oldString,newString)
%
% Find a replace a given string. We only do this within the World block. 
%
% Input
%   recipe:        a recipe object that includes a WorldBegin/WorldEnd block.
%   oldString:     String to find
%   newString:     String to replace it with
%
% Optional parameter/values
%   Nothing yet...
%
% Return
%    recipe - the same recipe but with an updated WorldBegin/WorldEnd
%             block.
%
% TL Scien Stanford 2017

%%
p = inputParser;
p.addRequired('recipe',@(x)isequal(class(x),'recipe'));
p.addRequired('oldString',@(x)ischar(x));
p.addRequired('newString',@(x)ischar(x)); 

p.parse(recipe,oldString,newString,varargin{:});
     
%% Look for the old string within the world block

world = recipe.world;

foundCount = 0;
for ii = 1:length(world)
    currLine = world{ii};
    if(~isempty(strfind(currLine,oldString)))
        
        foundCount = foundCount + 1;
        currLine = strrep(currLine,oldString,newString);
        world{ii} = currLine;
        
    end
end

if(foundCount == 0)
    warning('Did not find string: %s \n',oldString);
else
    fprintf('Found and replaced %i instances. \n',foundCount);
end

% Update world
recipe.world = world;

end
