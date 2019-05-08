function thisR = piJson2Recipe(JsonFile)
% Convert a JSON file to a recipe object
%
% Syntax:
%   thisR = piJson2Recipe(JsonFile)
%
% Description:
%    convert the provided JSON file to a recipe object.
%
% Inputs:
%    JsonFile - String. The full filepath to the JSON file.
%
% Outputs:
%    thisR    - Object. A recipe object containing the contents of the
%               provided JSON file.
%
% Optional key/value pairs:
%    None.
%

thisR_tmp = jsonread(JsonFile);
fds = fieldnames(thisR_tmp);
thisR = recipe;
% Assign the struct to a recipe class
for dd = 1:length(fds), thisR.(fds{dd})= thisR_tmp.(fds{dd}); end

end