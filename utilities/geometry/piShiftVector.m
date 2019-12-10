function dShift = piShiftVector(varargin)
% 
% Calculate the actual shift position according to the current camera
% direction and the shift vector.
%
% 
%   % Example
    %{
        lookAt.from = [12.9, 2.7958, 65.4330]';
        lookAt.to = [-16.0619, 2.6958, 73.2936]';
        deltaPosition = [0.75, 0, 0]';
        dShift = piShiftVector('lookAt',lookAt, 'shift vector', deltaPosition)
    %}
%

%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addParameter('lookAt', [], @isstruct);
p.addParameter('shiftvector', [0,0,0], @isvector);
p.parse(varargin{:});

lookAt = p.Results.lookAt;
shiftVector = p.Results.shiftvector;

%% Rotate the direction by 90 degrees
% Currently we only address the shift in x-y plane, in the future we
% probaly want to consider the shift in 3D world.

direction = lookAt.to - lookAt.from;
theta = atand(direction(1)/direction(3));
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];

verDirection = [shiftVector(1), shiftVector(3)] * R;
%{
    % Check the verDirection is perpendicular to the camera direction
    innerProduct = direction(1) * verDirection(1) + direction(3) *...
    verDirection(2)

    % Check the absolute value of the shift
    norm(verDirection)
%}
dShift = [verDirection(1), shiftVector(2), verDirection(2)]';
end
