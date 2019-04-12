function rotpoint = piPointRotate(point, center, theta)
% Rotate the point theta degrees around the center.
%
% Syntax:
%   rotpoint = piPointRotate(point, center, theta)
%
% Description:
%    Using the provided information, rotate the point 'point' by 'theta'
%    degrees around the center point 'center'.
%
% Inputs:
%    point    - Matrix. A 1x2 matrix of the 2 Dimensional point [x, y]
%    center   - Matrix. A 1x2 matrix of the 2 Dimensional point [x, y] at
%               which 'point' will rotate around.
%    theta    - Numeric. The rotation in degrees.
%
% Outputs:
%    rotpoint - Matrix. A 1x2 matrix of the rotated 2 Dimensional point in
%               the format [x, y].
%
% Optional key/value pairs:
%    None.
%

%%
% Create rotation matrix
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
% Rotate your point(s)
% point = point';
% center  = center';
rotpoint = R * (point + center)' + center';
rotpoint = rotpoint';
end
