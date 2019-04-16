function [from, to, up, flip] = piTransform2LookAt(world2Cam)
% Convert world2Cam transform matrix to from/to/up representation
% 
% Syntax
%   [from, to, up] = piTransform2LookAt(world2Cam)
%
% Inputs
%  world2cam - a 4x4 transform matrix 
%
% Returns
%  from - camera location in the scene
%  to - the direction the camera is pointing
%  up - direction of camera (up)
%
% These are all 1x3 vectors. 
%
%{
% Example

%}
% AJ, Oct 2017

% As we know the transform matrix being passed around in pbrt is a
% transform matrix from world coordinate to camera coordinate. We first need to compute its
% inverse which can transform any point and vector in the camera coordinate into the
% world coordinate
% cam2World = inv(world2Cam);

% camera location in world coordinate will be tranformed to origin in the
% camra coordinate by definition. Using this trait and reverse it back, we get from =
% cam2World*origin
from = world2Cam\[0 0 0 1]';
% from = cam2World*[0 0 0 1]';
% the direction vector (dir = from - to) in world coordinate is mapped to z
% axis in the camera coordinate. Using this trait and reverse it
% back, we get dir = cam2World*z_axis
dir = world2Cam\[0 0 1 0]';
% dir = cam2World*[0 0 1 0]';

to   = from  + dir;
to   = to(1:3);
from = from(1:3);
% the up direction vector in world coordinate is mapped to y axis in
% the camera coordinate. Using this trait and reverse it back, we get up =
% cam2World*y_axis. 

% However, we need to know that here we need to check if the
% determinant of world2Cam matrix is positive. If it is positive, it
% means there is no reflection happed in this transform. We can
% calculate as usual. If the determinant is negative, it means a
% reflection happened and the righthand coordinate system is flipped
% to the lefthand coordinate system. Therefore, to get 'up' back we
% need to map -y axis back to the world instead of y-axis. Also, we
% need to mention that, in this case, a transform matrix cannot be
% replaced by a single LookAt but a LookAt and a scaling matrix to
% express this reflection part. We have to keep tracking of the
% determinant of the transform matrix in doing this translations
if det(world2Cam) < 0 
    % up = world2Cam\[0 -1 0 0]';
    flip = 1;
else                   
    % up = world2Cam\[0 1 0 0]';
    flip = 0;
end
up = world2Cam\[0 1 0 0]'; % TL: I don't think the above up's are correct, just from trial and error.  
up = up(1:3);

from = from';
up = up';
to = to';

end