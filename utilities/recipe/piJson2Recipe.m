function thisR = piJson2Recipe(JsonFile)
% Convert a json format of a recipe to the recipe class
%
% Syntax
%   thisR = piJson2Recipe(JsonFile)
%
% Brief Description
%   We often store recipes as JSON files.  When we read them back in
%   Matlab treats them as a struct.  We want them to be @recipe.  Here
%   we create an @recipe object and copy the struct into the recipe.
%
% Input
%   JsonFile:  File name of the json file containing the scene recipe
% 
% Output
%   thisR:     Scene recipe object
%
% Description:
%   Over time we may make changes to the format of the recipe.  If we
%   do, then adjustments for the older formats happen in here through
%   the piUpdateRecipe call.
%
% Authors: ZL, Zheng Lyu maybe
%
% See also
%   recipe, jsonread, jsonwrite

%% Read the file
thisR_tmp = jsonread(JsonFile);

%% Loop through the fields and assign them
fds = fieldnames(thisR_tmp);
thisR = recipe;

% Assign the struct to a recipe class.  Some times we store extra fields in
% the JSON files.  So we use try/catch rather than force the assignment.
for dd = 1:length(fds)
    try
        thisR.(fds{dd})= thisR_tmp.(fds{dd});
    catch
        warning('Unrecognized field %s\n',fds{dd});
    end
end

% piUpdateRecipe - convert the old version of recipe to newer one
% where texture is a separate slot.
if isempty(thisR.textures)
    thisR = piUpdateRecipe(thisR);
end

end