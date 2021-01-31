function [newAX, newAY, newAZ, newAXYZ] = piTransformAxis(aX, aY, aZ, transform)
%% 
% Synopsis
%   [newAX, newAY, newAZ] = piTransformAxis(transform, aX, aY, aZ)
%
% Brief description:
%   Calculate new axis x, y and z with a transformation matrix
%   Points and vectors are represented in homogeneous coordinates.
%
% Inputs:
%   aX          - x axis (4 x 1)
%   aY          - y axis (4 x 1)
%   aZ          - z axis (4 x 1)
%   transform   - transformation matrix (4 x 4)
%
% Returns:
%   newAX       - new x axis
%   newAY       - new y axis
%   newAZ       - new z axis
%   newAXYZ     - new axis concatenated

% Examples
%{
%}

%% Parse Input
p = inputParser;
p.addRequired('aX', @isvector);
p.addRequired('aY', @isvector);
p.addRequired('aZ', @isvector);
p.addRequired('transform', @ismatrix);

p.parse(aX, aY, aZ, transform);

%% Calculate new axis
aX = reshape(aX, numel(aX), 1);
aY = reshape(aY, numel(aY), 1);
aZ = reshape(aZ, numel(aZ), 1);

newAX = transform * aX;
newAY = transform * aY;
newAZ = transform * aZ;

newAXYZ = cat(2, newAX, newAY, newAZ, [0;0;0;1]);

end