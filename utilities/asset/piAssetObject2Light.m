function thisR = piAssetObject2Light(thisR, index, lght)
% Change an object node to light. This is especially for the area light
% Inputs:
%   thisR - recipe
%   index - index of the asset 
%   light - a light struct
%
% Output:
%   thisR - modified recipe
%
% The template for the core command will be: t = t.set(n2, 'I changed.');
%
%% Extract the information from object node
objectNode = thisR.assets.get(index);
objectName = objectNode.name;
shape = objectNode.shape;

%% Create a new node to replace the object node
lightNode = piAssetCreate('type', 'light');
lightNode.lght = {lght}; % Convert the light to cell
lightNode.name = objectName;
lightNode.lght{1}.shape = shape;

thisR.assets = thisR.assets.set(index, lightNode);
end