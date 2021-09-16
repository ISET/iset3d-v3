function thisR = addGridToRecipe(thisR,lightGrid)
for l=1:numel(lightGrid)
thisR.set('light', 'add', lightGrid{l});
end
end

