function thisR = piAddLights(thisR,lightGrid)
% Add a cell array of lights to the recipe
for l=1:numel(lightGrid)
thisR.set('light', 'add', lightGrid{l});
end
end

