function thisR = piRecipeTranslate(thisR,origin)
%  Move the camera and objects so that the camera is at origin
%
%
% Description
%
% The rotation matrices for the three axes are
%
% X-axis
%      1      0      0
%      0   cos(a)  -sin(a)
%      0   sin(a)   cos(a)
%   
% Y-axis
%      cos(b)   0   sin(b)
%      0        1   0
%      -sin(b)  0   cos(b)
%
% Z-axis
%      cos(d)  -sin(d)   0
%      sin(d)   cos(d)   0
%      0          0      1

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

direction = thisR.get('lookat direction');   % Unit vector
zaxis = [0 0 1];   % Unit zaxis

% Find the 3D rotation matrix that brings direction to the zaxis.
% Call piDCM2angle to get the x,y,z rotations
% Call piAssetRotate with those three rotations

% Alternatively
% Find the rotations in deg around the x and y axes so that the new
% direction vector aligns with the zaxis.  
% First find a rotation angle around the x-axis into the x-z plane (y=0).
%
% The angle must satisfy
%  0 = [0   cos(a)  -sin(a)]*direction
%  0 = cos(a)*direction(2) - sin(a)*direction(3)
%  sin(a)*direction(3) = cos(a)*direction(2)
%  sin(a)/cos(a) = (direction(2)/direction(3))
%  tan(a) = (direction(2)/direction(3))
%  a = atan(direction(2)/direction(3))
xRotationMatrix = rotationVectorToMatrix([deg2rad(45),0,0]);
d2 = xRotationMatrix*direction(:)


% Rotate again, this time to be perpendicular to the x-axis (x=0). 
%
%  0 =  cos(b)*d2(1) + 0*d2(2) +  sin(b)*d2(3)
%  sin(b)/cos(b) = -d2(1)/d2(3)
%  b = atan(-d2(1)/d2(3))

rotation = [a,b,0];


for ii=1:numel(objects)
    piAssetRotate('asset',objects(ii),rotation);
end



u = zaxis; v = direction;
CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);
ztheta = real(acosd(CosTheta));

xaxis = 

R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
vR = v*R;


end
