function transform = piTransformTranslation(aX, aY, aZ, translation)
%%
% Synopsis:
%   transform = piTransformTranslation(aX, aY, aZ, translation)
%
% Brief description:
%   Calculate transform matrix with certain axis coordinate system
%   Points and vectors are represented in homogeneous coordinates.
%   
% Inputs:
%   aX          - current x axis [a, b, c, 0]
%   aY          - current y axis [a, b, c, 0]
%   aZ          - current z axis (a, b, c, 0)
%   translation - translation along current x, y, z axis ()
%
% Returns:
%   transform   - transform matrix
%
%

% Examples
%{
aX = [1, 0, 0, 0]';
aY = [0, 1, 0, 0]';
aZ = [0, 0, 1, 0]';
translation = [1, 2, 3];
transform = piTransformTranslation(aX, aY, aZ, translation);
%}

%% Parse input
p = inputParser;
p.addRequired('aX', @isvector);
p.addRequired('aY', @isvector);
p.addRequired('aZ', @isvector);
p.addRequired('translation', @isvector);

%% Calculate translation
aX = reshape(aX, numel(aX), 1);
aY = reshape(aY, numel(aY), 1);
aZ = reshape(aZ, numel(aZ), 1);

aMatrix = [aX aY aZ];
offset = aMatrix(1:3, 1:3) * reshape(translation(1:3), 3, 1);

transform = eye(4);
transform(:, 4) = transform(:, 4) + [offset;0];
end