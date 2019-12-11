function thisR = piCameraShift(thisR, varargin)
% Create a vector displacement for the camera
%
% Syntax:
%  thisR = piCameraShift(recipe,'xAmount',x,...
%                               'yAmount',y,...
%                               'zAmount',z);
% 
% Brief description:
%  Calculate the new camera position given a shift in camera space
%
% Inputs:
%  recipe  - The recipe of the scene 
%  xAmount - The amount of the shift in x direction in camera space
%  yAmount - The amount of the shift in y direction in camera space
%  zAmount - The amount of the shift in z direction in camera space
%
% Optional key/val pairs:
%  None.
%
% Outputs
%  New recipe with the camera position updated
%
% Description
%  The lookAt vector in a recipe points in a particular direction.
%  YOu can find this direction using recipe.get('direction')
%
%  We want to displace the camera position by some amount in the (x,y)
%  plane that is perpendicular to this direction.
% 
%  This routine calculates the shift that should be applied to the
%  current lookAt to achieve the new position that is shifted in the x, y
%  and z direction, and update the recipe.
%
%
%
% 
%  See also
%   

% Examples:
%{
  % Create a recipe
  sceneName = 'calChecker';
  squareSize = 0.3;
  outFile = fullfile(piRootPath,'local',sceneName,'calChecker.pbrt');
  thisR = piCreateCheckerboard(outFile,'numX',8,'numY',7,...
                        'dimX',squareSize,'dimY',squareSize);
  thisR.lookAt.from = [0;0;0];
  thisR.lookAt.to = [1;1;1];

  deltaPosition = [1, 0, 0]';
  newR = thisR.copy;
  newR = piCameraShift(newR,'xAmount',deltaPosition(1),...
                               'yAmount',deltaPosition(2),...
                               'zAmount',deltaPosition(3));

  deltaPosition = [0, 1, 0]';
  newR = thisR.copy;
  newR = piCameraShift(newR,'xAmount',deltaPosition(1),...
                               'yAmount',deltaPosition(2),...
                               'zAmount',deltaPosition(3));

  deltaPosition = [0, 0, 1]';
  newR = thisR.copy;
  newR = piCameraShift(newR,'xAmount',deltaPosition(1),...
                               'yAmount',deltaPosition(2),...
                               'zAmount',deltaPosition(3));
%}


%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addParameter('xamount', 0, @isscalar);
p.addParameter('yamount', 0, @isscalar);
p.addParameter('zamount', 0, @isscalar);
p.addParameter('fromto', 'both', @(x)ismember(x, {'from', 'to', 'both'}));

p.parse(thisR, varargin{:});

thisR  = p.Results.thisR;
xAmount = p.Results.xamount;
yAmount = p.Results.yamount;
zAmount = p.Results.zamount;
fromto = p.Results.fromto;

%% Rotate the direction by 90 degrees

% Currently we only address the shift in x-y plane, in the future we
% probaly want to consider the shift in 3D world.
lookAt = thisR.get('lookAt');
direction = -thisR.get('from to');
thetaXZ = atand(direction(1)/direction(3));
thetaY = acosd(direction(2) / norm(direction));
R = [cosd(thetaXZ) -sind(thetaXZ); sind(thetaXZ) cosd(thetaXZ)];


xShiftXZPlane = [xAmount, 0] * R;
xShiftWorldx = xShiftXZPlane(1);
xShiftWorldz = xShiftXZPlane(2);
xShiftWorldy = 0;

yShiftWorldy = yAmount * sind(thetaY);
yShiftWorldx = yAmount * cosd(thetaY) * sind(thetaXZ);
yShiftWorldz = yAmount * cosd(thetaY) * cosd(thetaXZ);

zShiftWorldy = zAmount * cosd(thetaY);
zShiftWorldx = zAmount * sind(thetaY) * sind(thetaXZ);
zShiftWorldz = zAmount * sind(thetaY) * cosd(thetaXZ);

%{
    % Check the verDirection is perpendicular to the camera direction
    innerProduct = direction(1) * verDirection(1) + direction(3) *...
    verDirection(2)

    % Check the absolute value of the shift
    norm(verDirection)
%}

vShift = [xShiftWorldx + yShiftWorldx + zShiftWorldx,...
          xShiftWorldy + yShiftWorldy + zShiftWorldy,...
          xShiftWorldz + yShiftWorldz + zShiftWorldz]';

switch fromto
    case 'from'
        thisR.set('from', lookAt.from + vShift);
    case 'to'
        thisR.set('to', lookAt.to + vShift);
    case 'both'
        thisR.set('from', lookAt.from + vShift);
        thisR.set('to', lookAt.to + vShift);
    otherwise
        error('Unknown "from to" type %s', fromto);
end

end
