function [depthrange, depthmap] = piSceneDepth(thisR)
% Compute the depth (meters) of the objects in the scene
%
% Syntax
%   [depthrange, depthmap] = piSceneDepth(thisR)
%
% Brief description
%   Calculate the depth image quickly and return the depth range and a
%   depth map histogram (meters).
%
% Wandell, 2019
%
% See also
%  t_piIntro_lens

% TODO:  See issue we have with the lens.  Here we remove the camera and
% replace it with a pinhole.  But really PBRT should also return the same
% depth map even if there is a lens.  When we are computing the depth map
% PBRT should use a pinhole.  I think!

%% Make a version of the recipe that matches but with a pinhole

% We think we should not have to do this to correctly get the depth.  The
% PBRT calculation should be independent of the lens!!!
pinholeR        = thisR.copy;
pinholeR.camera = piCameraCreate('pinhole');

%% The render returns the depth map in meters

depthmap   = piRender(pinholeR, 'render type','depth');
tmp        = depthmap(depthmap > 0);
depthrange = [min(tmp(:)), max(tmp(:))];

%% If no output arguments plot the histogram

if nargout == 0
    ieNewGraphWin;
    histogram(depthmap(:));
    xlabel('m'); ylabel('n pixels'); set(gca,'yscale','log');
    grid on;
end

end
