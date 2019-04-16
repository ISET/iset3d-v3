function thisR = piJson2Recipe(JsonFile)
% Convert a json format of a recipe to the recipe class
%
% Syntax
%   thisR = piJson2Recipe(JsonFile)
%
% Description
%    
%
% Input
%   JsonFile:  File name of the json file containing the scene recipe
% 
% Output
%   thisR:     Scene recipe object
%
% ZL, maybe
%
% See also
%

%% Read the file
thisR_tmp = jsonread(JsonFile);

%% Loop through the fields and assign them
fds = fieldnames(thisR_tmp);
thisR = recipe;

% Assign the struct to a recipe class
for dd = 1:length(fds)
    thisR.(fds{dd})= thisR_tmp.(fds{dd});
end

end