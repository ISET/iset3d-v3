function thisR = piJson2Recipe(JsonFile)
thisR_tmp = jsonread(JsonFile);

fds = fieldnames(thisR_tmp);
thisR = recipe;
% Assign the struct to a recipe class
for dd = 1:length(fds)
    thisR.(fds{dd})= thisR_tmp.(fds{dd});
end
end