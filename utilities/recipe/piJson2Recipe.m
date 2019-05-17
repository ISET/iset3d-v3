function thisR = piJson2Recipe(JsonFile)
% Convert a json format of a recipe to the recipe class
%
% Syntax
%   thisR = piJson2Recipe(JsonFile)
%
% Description:
%    Convert a JSON formatted recipe file to a recipe class object.
%
% Inputs:
%    JsonFile - String. The file name of the json file containing the
%               recipe for the scene.
%
% Outputs:
%   thisR     - Object. The scene recipe object.
%
% Optional key/value pairs:
%    None.
%

% History:
%    XX/XX/XX  ZL   maybe?
%    05/17/19  JNM  Documentation pass

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