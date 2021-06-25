function [M,Rx,Ry,Rz] = piRotate(theAnglesDeg)
% Return a 3d rotation matrix for the x,y,z angles in deg
%
% Synopsis
%    [M,Rx,Ry,Rz] = piRotate(theAnglesDeg)
%
% Input
%   theAnglesDeg - x,y,z rotation angles
%
% Output
%   M - Rotation matrix from the product of the 3 rotation matrices
%   Rx,Ry,Rz the three component matrices
%
% Description
%
% X-axis
%      1      0      0
%      0   cos(a)  -sin(a)
%      0   sin(a)   cos(a)
%   
% Y-axis
%      cos(b)   0   sin(b)
%      0        1   0
%      -sin(b)  0   cos(b)
%
% Z-axis
%      cos(d)  -sin(d)   0
%      sin(d)   cos(d)   0
%      0          0      1
%
% See also
%   piRotationMatrix (special for PBRT)
%

% Examples:
%{
theAnglesDeg = [ 0 45 0]
piRotate(theAnglesDeg)
%}

% Convert to radians
rad = deg2rad(theAnglesDeg);
x = rad(1); y = rad(2); z = rad(3);

% Calculate
Rx = [1 0 0; 0 cos(x) -sin(x); 0 sin(x) cos(x)];
Ry = [cos(y) 0 sin(y); 0 1 0; -sin(y) 0 cos(y)];
Rz = [cos(z) -sin(z) 0; sin(z) cos(z) 0; 0 0 1];

M = Rx*Ry*Rz;

end
