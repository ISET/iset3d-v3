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

% Check the lights.  Make sure they are a cell even if only one light.
if isstruct(thisR_tmp.lights)
    theLights = thisR_tmp.lights;
    thisR_tmp.lights = {theLights};
end

% The rotation field of the light struct has the wrong shape.

%% Assets

% The assets are stored as structs.  We convert them to a tree - we have to
% deal with the root node and the fact that the asset can only be added
% when its parent is already part of the tree.
if ~isempty(thisR_tmp.assets)
    % The first node is the root. Its parent value is 0 and ID is 1  
    assetTree = tree('root');

    % Pull out the nodes.  
    nnodes = numel(thisR_tmp.assets.Parent);
    nodes = thisR_tmp.assets.Node;
    
    % Add each of the nodes, first attaching to the root
    for ii=2:nnodes
        assetTree = assetTree.addnode( 1, nodes{ii});
    end
    
    parentID = thisR_tmp.assets.Parent;
    % Now set the correct parent.
    for ii=2:nnodes
        assetTree = assetTree.setparent(ii, parentID(ii));
    end    
end
thisR_tmp.assets = assetTree;


% Convert the materials and textures to a container.Map
if ~isempty(thisR_tmp.textures)
    textureMap  = containers.Map;
    fds = fieldnames(thisR_tmp.textures.list);
    for ii=1:numel(fds)
        thisTexture =  thisR_tmp.textures.list.(fds{ii});
        textureMap(thisTexture.name) = thisTexture;
    end 
end
thisR_tmp.textures.list = textureMap;

% Material
if ~isempty(thisR_tmp.materials)    
    materialMap = containers.Map;
    fds = fieldnames(thisR_tmp.materials.list);
    for ii=1:numel(fds)
        thisMaterial = thisR_tmp.materials.list.(fds{ii});
        materialMap(thisMaterial.name) = thisMaterial;
    end
end

thisR_tmp.materials.list = materialMap;

%% Loop through the fields and assign them

% Find the field names in the json file recipe
fds = fieldnames(thisR_tmp);
if any(~ieContains(fds,'recipeVer')) || ~isequal(thisR_tmp.recipeVer,2)
%     disp('Version 1 recipe read in'); % silence the function
    thisVersion = 1;
else
    thisVersion = 2;
end

%% Some of the fields that should be rows are columns.  

% We fix those here in what should become a separate and general routine.
thisR_tmp.lookAt.from = thisR_tmp.lookAt.from(:)';
thisR_tmp.lookAt.to = thisR_tmp.lookAt.to(:)';
thisR_tmp.lookAt.up = thisR_tmp.lookAt.up(:)';

%%


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