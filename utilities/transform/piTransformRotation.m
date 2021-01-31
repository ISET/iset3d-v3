function transform = piTransformRotation(thisAx, deg, varargin)
%%
% Synopsis:
%   transform = piTransformRotation(thisAx, rotation, rotDeg)
%
% Brief description:
%   Calculate transform matrix around a certain axis. Info:
%   http://www.pbr-book.org/3ed-2018/Geometry_and_Transformations/Transformations.html
%   Points and vectors are represented in homogeneous coordinates.
%
% Inputs:
%   thisAx  - rotate around this vector (x, y, z, 0)
%   deg  - rotation degree
%
% Returns:
%   transform - transform matrix (4 x 4)
%

% Examples
%{
%}

%% Parse input
p = inputParser;
p.addRequired('thisAx', @isvector);
p.addRequired('deg', @isscalar);
p.parse(thisAx, deg, varargin{:});

%% Calculate matrix from PBRT book, there might be a matrix calculation
transform = eye(4);

transform(1, 1) = thisAx(1)^2 + (1-thisAx(1)^2) * cosd(deg);
transform(1, 2) = thisAx(1)*thisAx(2)*(1-cosd(deg)) - thisAx(3)*sind(deg);
transform(1, 3) = thisAx(1)*thisAx(3)*(1-cosd(deg)) + thisAx(2)*sind(deg);

transform(2, 1) = thisAx(1)*thisAx(2)*(1-cosd(deg)) + thisAx(3)*sind(deg);
transform(2, 2) = thisAx(2)^2 + (1-thisAx(2)^2) * cosd(deg);
transform(2, 3) = thisAx(2)*thisAx(3)*(1-cosd(deg)) - thisAx(1)*sind(deg);

transform(3, 1) = thisAx(1)*thisAx(3)*(1-cosd(deg)) - thisAx(2)*sind(deg);
transform(3, 2) = thisAx(2)*thisAx(3)*(1-cosd(deg)) + thisAx(1)*sind(deg);
transform(3, 3) = thisAx(3)^2 + (1-thisAx(3)^2)*cosd(deg);

end