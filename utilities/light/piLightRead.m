function thisR = piLightRead(thisR)
% Read light information from world text or from a file
%
% Synopsis:
%   thisR = piLightRead(thisR)
% 
% Description:
%   We create the lights slot in the recipe from text in the World or
%   from a file.
%
% See also
%   piRead

% Examples:
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
[thisR.lights, lightTextRanges] = piLightGetFromText(thisR.world, 'printinfo', false);

% Remove the light from the world because we stored them in thisR.lights
% We do not deal with world block any more
thisR = piDeleteWorldText(thisR, lightTextRanges);

% do we need this every time?
if isempty(thisR.lights)
    
    % Get light from scene_lights.pbrt file
    [p,n,~] = fileparts(thisR.inputFile);
    fname_lights = sprintf('%s_lights.pbrt',n);
    inputFile_lights=fullfile(p,fname_lights);
    
    if exist(inputFile_lights,'file')
        fileID = fopen(inputFile_lights);
        txt = textscan(fileID,'%s','Delimiter','\n');
        newLights = piLightGetFromText(txt{1}, 'print', false);
        if ~isempty(newLights)
            thisR.lights{end+1:end+numel(newLights)} = newLights{:};
        else
            warning('%s exists but no light found. \n', inputFile_lights);
        end
    end
    
end

end