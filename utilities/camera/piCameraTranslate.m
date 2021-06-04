function thisR = piCameraTranslate(thisR, varargin)
% Create a vector displacement for the camera
%
% Synopsis:
%  thisR = piCameraTranslate(recipe,'x shift',x,...
%                               'y shift',y,...
%                               'z shift',z);
%
% Brief description:
%  Calculate a new camera position given by the specified shift in camera space
%
% Inputs
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
% Calculation notes:
%
%  Suppose the world coordinates of the scene are (x,y,z) space.
%  The viewing direction is 'direction'.  This is "to - from". We call this
%  the z' direction in the camera space to distinguish it from the
%  z-direction in the world. 
%
%  We need to define the x',y' dimensions in the camera space.
%  We know that these are perpendicular to z'.  
%
%  We make the x' axis perpendicular to [0,1,0] and z'. Then we make y'
%  axis perpendicular to (x',z'). 
%
%     x' = cross([0,1,0],direction) and y' = cross(direction,x')
%
% (there is a way to use the nullspace method to do this calculation, too).
%
%  Finally, we want the positive y' to be in the same direction as 'up'. So
%  we check the inner product of 'up' and y', and we make it positive. 
%
% See also
%    piCameraRotate

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
cameraX = reshape(cameraX, size(direction)); 
cameraY = reshape(cameraY, size(direction));

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
