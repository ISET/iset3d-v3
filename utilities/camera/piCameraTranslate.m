function thisR = piCameraTranslate(thisR, varargin)
% Create a vector displacement for the camera
%
% Syntax:
%  thisR = piCameraShift(recipe,'x shift',x,...
%                               'y shift',y,...
%                               'z shift',z);
%
% Brief description:
%  Calculate a new camera position given by the specified shift in camera space
%
% Inputs:
%  recipe  - The recipe of the scene
%
% Optional key/val pairs:
%  xshift - The shift in x direction in camera space (meters)
%  yshift - The shift in y direction in camera space (meters)
%  zshift - The shift in z direction in camera space (meters)
%  fromto - Whether to change the from, to or both {'from','to','both'}  
%           (default 'both')
%
% Outputs
%  recipe - Camera position updated for the shift
%
% Description
%  The lookAt vector in a recipe points in a particular direction.
%  You can find this direction using recipe.get('direction')
%
%  By default this routine displaces the camera position by some
%  amount in the (x,y) plane that is perpendicular to the lookAt
%  direction (z)
%
%  This routine calculates the shift that should be applied to the
%  current lookAt to shift the camera position in the x, y and z
%  directions. The lookAt in the recipe is updated and returned.
%


%}
%  Suppose the world coordinates of the scene are (x,y,z) space.
%  The viewing direction is 'direction'
%  In the camera space, 'direction' is the z-axis, call this the z'
%  direction.
%
%  We need to define the x',y' dimensions in the camera space.
%  We know that these are perpendicular to z'.  We make the x' axis
%  perpendicular to (y,z') and the y' axis perpendicular to (x',z').
%  We identify these directions using the cross product.
%
%  And we would like y' to be in the plane defined by (y,z')
%  Then x' is perpendicular to z' and y'
%
%     x' = cross(direction,y) and y' = cross(direction,x)
%  or
%     y' = nullspace(x',z')
%
%
%  See also
%   piCameraRotate

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
  
  % Write a recipePlot and have it do things 
  % recipePlot(thisR,'direction').  Maybe other stuff.
  deltaPosition = [1, 0, 0]';
  newR = thisR.copy;
  newR = piCameraShift(newR,'xshift',deltaPosition(1),...
      'yshift',deltaPosition(2),...
      'zshift',deltaPosition(3));
  
  deltaPosition = [0, 1, 0]';
  newR = thisR.copy;
  newR = piCameraShift(newR,'xshift',deltaPosition(1),...
      'yshift',deltaPosition(2),...
      'zshift',deltaPosition(3));
  
  deltaPosition = [0, 0, 1]';
  newR = thisR.copy;
  newR = piCameraShift(newR,'xshift',deltaPosition(1),...
      'yshift',deltaPosition(2),...
      'zshift',deltaPosition(3));
%}


%% Parse

% Remove spaces, force lower case
varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('thisR', @(x)isequal(class(x),'recipe'));

p.addParameter('xshift', 0, @isscalar);
p.addParameter('yshift', 0, @isscalar);
p.addParameter('zshift', 0, @isscalar);
p.addParameter('fromto', 'both', @(x)(ismember(x,{'from','to','both'})));

p.parse(thisR, varargin{:});

thisR  = p.Results.thisR;
xshift = p.Results.xshift;
yshift = p.Results.yshift;
zshift = p.Results.zshift;
fromto = p.Results.fromto;

%% Adjust the position

% Find the looking direction
lookAt    = thisR.get('lookAt');   % A structure with all the info
direction = thisR.get('to from'); % The direction to - from.
direction = direction/norm(direction);

% The three should follow the 'left hand rule' for the axis
cameraX = cross([0 1 0],direction); cameraX = cameraX/norm(cameraX);
cameraY = cross(cameraX,direction); cameraY = cameraY/norm(cameraY);
% We want cameraY to be pointing in the same direction as lookAt.up
up = thisR.get('up');
if dot(cameraY,up) < 0, cameraY = -1*cameraY; end
cameraX = reshape(cameraX, size(direction)); cameraY = reshape(cameraY, size(direction));

%{
 ieNewGraphWin;
 line([0 direction(1)],[0,direction(2)],[0,direction(3)],'color','k');    hold on
 line([0 cameraX(1)],[0,cameraX(2)],[0,cameraX(3)],'color','b')
 line([0 cameraY(1)],[0,cameraY(2)],[0,cameraY(3)],'color','r')
 grid on; axis equal; xlabel('X'); ylabel('Y'); zlabel('Z')
%}

shift = xshift*cameraX + yshift*cameraY + zshift*direction;
switch fromto
    case 'from'
        thisR.set('from',lookAt.from + reshape(shift, size(lookAt.from)));
    case 'to'
        thisR.set('to', lookAt.to + reshape(shift, size(lookAt.to)));
    case 'both'
        thisR.set('from',lookAt.from + reshape(shift, size(lookAt.from)));
        thisR.set('to',  lookAt.to + reshape(shift, size(lookAt.to)));
    otherwise
        error('Unknown "from to" type %s', fromto);
end

end
