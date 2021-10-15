function [newRotM, rotDegs] = piTransformRotationInAbsSpace(rotVec, curRotM, varargin)
%{
% Description:
%   Get rotation matrix and rotation degrees in another space
%}
%%
p = inputParser;
p.addRequired('rotVec', @isvector);
p.addRequired('curRotM', @ismatrix);
p.parse(rotVec, curRotM, varargin{:});

%%
newRotM = eye(4);
% Loop through the three rotation                
for ii=1:numel(rotVec)
    if ~isequal(rotVec(ii), 0)
        % Axis in world space
        axWorld = zeros(4, 1);
        axWorld(ii) = 1;

        % Axis orientation in world space
        % axObj = inv(curRotM) * axWorld;
        axObj = curRotM \ axWorld;
        thisAng = rotVec(ii);

        % Get the rotation matrix in world space
        thisM = piTransformRotation(axObj, thisAng);
        newRotM = thisM * newRotM;
    end
end

% Get rotation deg around x, y and z axis in object
% space.
rotDegs = piTransformRotM2Degs(newRotM);
end