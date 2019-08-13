function [depthrange, depthmap] = piSceneDepth(thisR)
% Compute the depth (meters) of the objects in the scene
%
% Syntax
%   [depthrange, depthmap] = piSceneDepth(thisR)
%
% Brief description
%   Calculate the depth image quickly and return the depth range and a
%   depth map (meters).
%
% Wandell, 2019
%
% See also
%  t_piIntro_lens

%% Set the recipe to permit fast calculation

% Not sure this is necessary
thisCopy = thisR.copy;
thisCopy.set('max depth',1); % Number of bounces
% thisCopy.set('camera type','perspective');
thisCopy.set('rays per pixel',1);
thisCopy.camera = piCameraCreate('perspective');

%% The render returns the depth map in meters

depthmap   = piRender(thisCopy, 'render type','depth');
tmp = depthmap(depthmap > 0);
depthrange = [min(tmp(:)), max(tmp(:))];

%% If no output arguments plot the histogram

if nargout == 0
    ieNewGraphWin;
    histogram(depthmap(:));
    xlabel('mm'); ylabel('n pixels'); set(gca,'yscale','log');
    grid on;
end

end
