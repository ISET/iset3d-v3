function tranform_matrix = lookat2transform(from, to, up)
% this function takes the 3 vectors we read from the LookAt line in pbrt
% and calculate the transform matrix which is passed around in pbrt. 

% 'from' indicates the coordiates of camera location as a point in world
% coordinates.
% 'to' indicates the coordinates of where the camera is looking at as a point
% in world coordinates.
% 'up' indicates the direction of where the camera up location is as a
% vector in the world coordinates.

% By AJ Oct2017

% the transform matrix is a 4x4 matrix represents how to map each point and
% vector in the world coordinate into camera coordinate.
% First we initialize it in a way that the 4th column is the [from 1], 3rd
% column is [normalized(dir) 0]; 
% Then we calculate left = cross(normalized(up), normalized(dir)), new_up =
% cross(dir, left). The first column is [left 0]; second column is [new_up
% 0]. By this setup, we can map the camera location in world coordinate to
% the origin in camera coordinate, direction vector into z axis and up
% vector into y axis in the camera coordinate. The calculation above
% strictly follows the definition in pbrt version2.
tranform_matrix = zeros(4,4);
tranform_matrix(1:3, 4) = from;
dir = (to - from)/norm(to - from);
norm_up = up/norm(up);
left = cross(norm_up, dir);
left = left/norm(left);
new_up = cross(dir, left);
tranform_matrix(1:3, 1) = left;
tranform_matrix(1:3, 2) = new_up;
tranform_matrix(1:3, 3) = dir;
tranform_matrix(4,4) = 1;
tranform_matrix = inv(tranform_matrix);
end