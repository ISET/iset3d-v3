function thisR = piCameraShift(thisR, varargin)
% Create a vector displacement for the camera
%
% Syntax:
%  thisR = piCameraShift(recipe,'x',xAmount,...
%                               'y',yAmount,...
%                               'z',zAmount);
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

  deltaPosition = [0.75, 0, 0]';
  thisR = piCameraShift(thisR,'xAmount',deltaPosition(1),...
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

p.parse(thisR, varargin{:});

thisR  = p.Results.thisR;
xAmount = p.Results.xamount;
yAmount = p.Results.yamount;
zAmount = p.Results.zamount;

%% Rotate the direction by 90 degrees

% Currently we only address the shift in x-y plane, in the future we
% probaly want to consider the shift in 3D world.
lookAt = thisR.get('lookAt');
direction = -thisR.get('from to');
theta = atand(direction(1)/direction(3));
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];

xShift = [xAmount, 0] * R;
zShift = [0, zAmount] * R;

%{
    % Check the verDirection is perpendicular to the camera direction
    innerProduct = direction(1) * verDirection(1) + direction(3) *...
    verDirection(2)

    % Check the absolute value of the shift
    norm(verDirection)
%}

vShift = [xShift(1) + zShift(1), yAmount, xShift(2) + zShift(2)]';

thisR.set('from', lookAt.from + vShift);
thisR.set('to', lookAt.to + vShift);
end
