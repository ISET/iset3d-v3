function thisR = piJson2Recipe(JsonFile, varargin)
% Convert a json format of a recipe to the recipe class
%
% Syntax
%   thisR = piJson2Recipe(JsonFile, update)
%
% Brief Description
%   We often store recipes as JSON files.  When we read them back in
%   Matlab treats them as a struct.  We want them to be @recipe.  Here
%   we create an @recipe object and copy the struct into the recipe.
%
% Input
%   JsonFile:  File name of the json file containing the scene recipe
%   update:  Disable update if set to be false (Default is true).   
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

%%
p = inputParser;
p.addRequired('JsonFile');
p.addParameter('update', true, @islogical);
p.parse(JsonFile, varargin{:});

JsonFile = p.Results.JsonFile;
update   = p.Results.update;
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

if update
    %% Change the path to the lens file
    if isfield(thisR.camera, 'lensfile')
        [~,lensName, extend] = fileparts(thisR.camera.lensfile.value);
        if ~isempty(which(strcat(lensName, extend)))
            thisR.camera.lensfile.value = which(strcat(lensName, extend));
        end
    end
    %%
    % piUpdateRecipe - convert the old version of recipe to newer one
    % where texture is a separate slot.
    if isempty(thisR.textures)
        thisR = piUpdateRecipe(thisR);
    end
end
end