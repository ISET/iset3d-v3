function thisR = piRecipRectify(thisR,origin)
%  Move the camera and objects so that the camera is at origin
%
%
% Description
%
% See piRotate for the rotation matrices for the three axes
% See also
%

% Examples
%{
 thisR = piRecipeDefault('scene name','simple scene');
 piAssetGeometry(thisR);
 origin = [0 0 0];
 thisR = piRecipeTranslate(thisR,origin);
 piAssetGeometry(thisR);
 thisR.show('objects');
%}

%% Find the camera position
from = thisR.get('from');

%% Move the camera to the specified origin

d = origin - from;
piCameraTranslate(thisR,'xshift',d(1), ...
    'yshift',d(2), ...
    'zshift',d(3));

objects = thisR.get('objects');
for ii=1:numel(objects)
    thisR.set('asset',objects(ii),'translate',d);
end

%% Rotate all the objects so that the from-to is along the z-axis

% Angle to the z axis
direction = thisR.get('lookat direction');   % Unit vector
zaxis = [0 0 1];
CosTheta = max(min(dot(direction,zaxis),1),-1);
ztheta = real(acosd(CosTheta));

% If the direction is different from down the z-axis, do the rest.
% Otherwise, return.  We consider 'different' to be within half a degree, I
% guess. 
%
if ztheta < 0.5, return; end

% Find the rotations in deg around the x and y axes so that the new
% direction vector aligns with the zaxis. 
%
% First find a rotation angle around the x-axis into the x-z plane.
% The angle must satisfy y = 0.  So, we take out the row of the x-rotation
% matrix
%
%  0 = [0   cos(a)  -sin(a)]*direction(:)
%  0 = cos(a)*direction(2) - sin(a)*direction(3)
%  sin(a)*direction(3) = cos(a)*direction(2)
%  sin(a)/cos(a) = (direction(2)/direction(3))
%  tan(a) = (direction(2)/direction(3))
%  a = atan(direction(2)/direction(3))
%

% Test with different direction vectors
%
% direction = [1 2 0];
% direction = [-1 0 2];
xAngle = atan2(direction(2),direction(3));   % Radians
xRotationMatrix = piRotate([rad2deg(xAngle),0,0]);
direction2 = xRotationMatrix*direction(:);

%{
% y entry of this vector should be 0
  direction2
%}

% Rotate again, this time to be perpendicular to the x-axis (x=0). 
%
%  0 =  cos(b)*d2(1) + 0*d2(2) +  sin(b)*d2(3)
%  sin(b)/cos(b) = -d2(1)/d2(3)
%  b = atan(-d2(1)/d2(3))
yAngle = atan2(-direction2(1),direction2(3));

%
%{
% Should be zero
  cos(yAngle)*direction2(1) + sin(yAngle)*direction2(3)
% Should be aligned with z-axis
 yRotationMatrix = piRotate([0,rad2deg(yAngle),0]);
 direction3 = yRotationMatrix*direction2(:)
%}

rMatrix = piRotate([xAngle,yAngle,0]);

% We have the angles.  Rotate every object's position and its orientation
for ii=1:numel(objects)
    pos = thisR.get('asset',objects(ii),'world coordinate');
    pos = rMatrix*pos(:);
    thisR.set('asset',objects(ii),'world coordinate',pos);
    piAssetRotate('asset',objects(ii),[xAngle,yAngle,0]);
end

end

%{
% NOTES
u = zaxis; v = direction;

CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);
ztheta = real(acosd(CosTheta));

xaxis = 

R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
vR = v*R;
%}
% Find the 3D rotation matrix that brings direction to the zaxis.
% Call piDCM2angle to get the x,y,z rotations
% Call piAssetRotate with those three rotations

