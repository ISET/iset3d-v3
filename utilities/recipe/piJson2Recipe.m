function thisRV2 = piJson2Recipe(JsonFile, varargin)
% Convert a json format recipe to the ISET3d recipe class
%
% Syntax
%   thisR = piJson2Recipe(JsonFile, update)
%
% Brief Description
%   On Flywheel we often store recipes as JSON files.  When we read them
%   into Matlab they are structs. We convert them to the @recipe class
%   here. 
%
%   The conversion will run with both V1 and V2 JSON recipe data.  It calls
%   piRecipeUpdate to flip from V1 to V2.
%
% Input
%   JsonFile:  File name of the json file containing the scene recipe
%   update:    Disable update if set to be false (Default is true).   
% 
% Output
%   thisR:     @recipe object
%
% Description:
%   Over time we may make changes to the @recipe format.  If we do, then
%   adjustments for the older formats happen in here through the
%   piUpdateRecipe call.  The version of the recipe is stored in the
%   variable @recipe.recipeVer, though for Version 1 this slot is missing.
%
%   We test the update from V1 to V2 using the script
%
% See also
%   piRecipeUpdate, @recipe, jsonread, jsonwrite

% Examples:
%{
fname = 'city4_9_30_v0.0_f40.00front_o270.00_201952151746.json';
thisR = piJson2Recipe(fname);
%}

%% Parse parameters

p = inputParser;
p.addRequired('JsonFile');
p.addParameter('update', true, @islogical);
p.parse(JsonFile, varargin{:});

JsonFile = p.Results.JsonFile;
update   = p.Results.update;

%% Read the file
thisR_tmp = jsonread(JsonFile);

%% Loop through the fields and assign them

% Find the field names in the json file recipe
fds = fieldnames(thisR_tmp);
if any(~ieContains(fds,'recipeVer')) || ~isequal(thisR_tmp.recipeVer,2)
%     disp('Version 1 recipe read in'); % silence the function
    thisVersion = 1;
else
    thisVersion = 2;
end

% Create a V2 recipe class 
thisRV2 = recipe;

% Assign the struct to a recipe class.  Some times we store extra fields in
% the JSON files.  So we use try/catch rather than force the assignment.
for dd = 1:length(fds)
    try
        thisRV2.(fds{dd})= thisR_tmp.(fds{dd});
    catch
        warning('Unrecognized field %s\n',fds{dd});
    end
end

if update
    %% Change the path to the lens file
    if isfield(thisRV2.camera, 'lensfile')
        [~,lensName, extend] = fileparts(thisRV2.camera.lensfile.value);
        if ~isempty(which(strcat(lensName, extend)))
            thisRV2.camera.lensfile.value = which(strcat(lensName, extend));
        end
    end
    
    %% piUpdateRecipe - 
    % convert the old material, lights and asset formats    
    
    % thisRV2 is a hybrid at this point.  It is a V2 class recipe, but in
    % fact, key fields have not been properly updated.  We do that here.
    if isempty(thisRV2.textures)
        thisRV2 = piRecipeUpdate(thisRV2);
    end
elseif thisVersion == 1
    disp('update not set.  Returning a Version 1 recipe.');
end
    
end