function thisR = piLightRead(thisR)
% Read light information from both world text and file
%
% Synopsis:
% 
% Description:
%
%
%

% Examples
%{
thisR = piRecipeDefault('scene name', 'SimpleSceneLight');
piWrite(thisR);
scene = piRender(thisR);
sceneWindow(scene);
%}
%{
thisR = piRecipeDefault('scene name', 'MacBethCheckerCusLight');
piLightSet(thisR, 1, 'type', 'point');
piLightSet(thisR, 1, 'cameracoordinate', true);
piWrite(thisR);
scene = piRender(thisR);
sceneWindow(scene);
%}
%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.parse(thisR)

%% Get light from world
thisR.lights = piLightGetFromText(thisR, thisR.world,'printinfo', false);

% Remove the light from the world as we already stored them in thisR.lights
thisR = piLightDeleteWorld(thisR, 'all');

%% Get light from scene_lights.pbrt file
[p,n,~] = fileparts(thisR.inputFile);
fname_lights = sprintf('%s_lights.pbrt',n);
inputFile_lights=fullfile(p,fname_lights);
if exist(inputFile_lights,'file')
    fileID = fopen(inputFile_lights);
    txt = textscan(fileID,'%s','Delimiter','\n');
    newLights = piLightGetFromText(thisR, txt{1}, 'print', false);
    if ~isempty(newLights)
        thisR.lights{end+1:end+numel(newLights)} = newLights{:};
    else
        warning('%s exists but no light found. \n', inputFile_lights);
    end
end


end