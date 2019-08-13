function [depthrange, depthmap] = piSceneDepth(thisR)
% Compute the depth of the objects in the scene
%
% Syntax
%   [depthrange, depthmap] = piSceneDepth(thisR)
%
% Brief description
%   Calculate the depth image quickly and return the depth range and a
%   depth map.
%
% Wandell
%
% See also
%

%% Go for speed

thisR.set('max depth',1); % Number of bounces
thisR.set('camera type','perspective');
thisR.set('rays per pixel',1);

%% Render the depth map

depthmap   = piRender(thisR, 'render type','depth');
tmp = depthmap(depthmap > 0);
depthrange = [min(tmp(:)), max(tmp(:))];

%% If no output arguments plot the histogram

if nargout == 0
    ieNewGraphWin;
    histogram(depthmap(:));
    xlabel('meters'); ylabel('n pixels'); set(gca,'yscale','log');
    grid on;
end

end
