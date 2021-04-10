%% Test the piJson2Recipe conversion
%
% This mainly tests converting from Version 1 to Version 2
%

% Load a Version 1 json file for the SimpleScene and update to Version 2.
% The json file is stored in data/recipeV1 for validation purpose.
%
thisR = piJson2Recipe('simpleScene.json');

%% Copy the Simple Scene into the local directory

%% Replace the default recipe with this recipe

%% Render

%% END