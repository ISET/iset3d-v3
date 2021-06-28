function [obj,results] = piWRS(thisR)
% Write, render, show radiance image
%
% Write, Render, Show a scene specified by a recipe
%
% Synopsis
%   [isetObj, results] = piWRS(thisR)
% 
% See also
%   piRender, sceneWindow, oiWindow

piWrite(thisR);

[obj,results] = piRender(thisR,'render type','radiance');

switch obj.type
    case 'scene'
        sceneWindow(obj);
    case 'opticalimage'
        oiWindow(obj);
end

end