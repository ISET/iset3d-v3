function recipe = ...
    piWorldFindAndReplace(recipe, oldString, newString, varargin)
% Find & Replace a given string within the world.
%
% Syntax:
%   recipe = piFindAndReplace(recipe, oldString, newString, [varargin])
%
% Description:
%    Find a replace a given string. We only do this within the World block
%    for lights and objects in the base pbrt scene (not xxx_materials.pbrt
%    or xxx_geometry.pbrt).
%
% Inputs:
%    recipe    - Recipe. A recipe object which includes a
%                WorldBegin/WorldEnd block.
%    oldString - String. String to find
%    newString - String. String to replace it with
%
% Outputs:
%    recipe    - Recipe. The modified recipe (with an updated
%                WorldBegin/WorldEnd block).
%
% Optional key/value pairs:
%    None.
%

% History:
%    XX/XX/17  TL   Scien Stanford 2017
%    03/25/19  JNM  Documentation pass

%% Initialize
p = inputParser;
p.addRequired('recipe', @(x)isequal(class(x), 'recipe'));
p.addRequired('oldString', @(x)ischar(x));
p.addRequired('newString', @(x)ischar(x));

p.parse(recipe, oldString, newString, varargin{:});

%% Look for the old string within the world block

world = recipe.world;

foundCount = 0;
for ii = 1:length(world)
    currLine = world{ii};
    if ~isempty(strfind(currLine, oldString))
        foundCount = foundCount + 1;
        currLine = strrep(currLine, oldString, newString);
        world{ii} = currLine;
    end
end

if foundCount == 0
    warning('Did not find string: %s \n', oldString);
else
    fprintf('Found and replaced %i instances. \n', foundCount);
end

% Update world
recipe.world = world;

end
