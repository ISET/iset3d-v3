function targetR = piRecipeCopy(thisR)
%% copy a recipe to a target recipe
% 
targetR = recipe;
fds = fieldnames(thisR);
for dd = 1:length(fds)
    targetR.(fds{dd})= thisR.(fds{dd});
end
end