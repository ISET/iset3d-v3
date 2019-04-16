function world2Cam = piLookat2Transform(from, to, up)
% Convert lookAt representation to world2Cam matrix
%
% Syntax
%  transform_matrix = lookat2transform(from, to, up)
%
%  The 3 lookAt vectors are converted to the transform matrix
%
% Inputs
%    'from' camera location in world coordinates.
%    'to'   point where the camera is looking at in world coordinates.
%    'up'   up direction in world coordinates
%
% See also:  piTransform2LookAt
%
% Examples
%{
from = [100,0,0]; to = [0 0 0]; up = [0 0 1];
w2c = piLookat2Transform(from,to,up)
%}
% Notes
%  Is transform_matrix also called world2Cam?  I assume so and renamed.
%
%  The world2Cam representation is homogeneous coordinates transform.
%  If you know a location in world coordinates, this provides the
%  location in camera coordinate frame.
%
% By AJ Oct2017


% Logic
%
% The transform_matrix is 4x4.  It represents how to map each point
% and vector in the world coordinate into camera coordinate. 
%
% First we initialize it in a way that the 4th column is the [from 1],
% 3rd column is [normalized(dir) 0]; Then we calculate left =
% cross(normalized(up), normalized(dir)), new_up = cross(dir, left).
% The first column is [left 0]; second column is [new_up 0]. By this
% setup, we can map the camera location in world coordinate to the
% origin in camera coordinate, direction vector into z axis and up
% vector into y axis in the camera coordinate. The calculation above
% strictly follows the definition in pbrt version2.


% Calculate the rows/cols
dir = (to - from)/norm(to - from);
norm_up = up/norm(up);
left = cross(norm_up, dir);
left = left/norm(left);
new_up = cross(dir, left);

% Make assignments
world2Cam = zeros(4,4);
world2Cam(1:3, 4) = from;
world2Cam(1:3, 1) = left;
world2Cam(1:3, 2) = new_up;
world2Cam(1:3, 3) = dir;
world2Cam(4,4) = 1;

% One last inversion
world2Cam = inv(world2Cam);

end