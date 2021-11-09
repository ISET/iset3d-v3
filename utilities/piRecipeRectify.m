function thisR = piRecipeRectify(thisR,varargin)
% Move the camera and objects so that the origin is 0 and the view
% direction is the z-axis
%
% Description
%
% Inputs
%   thisR
%
% Optional key/val pairs
%   rotate - Logical to supress rotation.  Default is true
%
% Return
%   thisR
%
% See piRotate for the rotation matrices for the three axes
% See also
%

% Examples
%{
 thisR = piRecipeDefault('scene name','simple scene');
 thisR.set('fov',60);
 thisR.set('film resolution',[160 160]);
 piAssetGeometry(thisR);
 piWRS(thisR); 

 thisR = piRecipeRectify(thisR);
 piAssetGeometry(thisR);
 piWRS(thisR);
%}

%% Parser
p = inputParser;
p.addRequired('thisR',@(x)(isa(x,'recipe')));
p.addParameter('rotate',true,@islogical);

p.parse(thisR,varargin{:});

%% Check if we need to insert a rectify node

% Identify all the children of root
idChildren = thisR.get('asset','root','children');

if numel(idChildren) == 1
    % If there is only one node, and it is called rectify just get it
    tmp = split(thisR.get('asset',idChildren,'name'),'_');
    if isequal(tmp{end},'rectify')
        % No need to insert a rectify node.  It is there already.
        idRectify = thisR.get('asset','rectify','id');
    else
        % Insert a rectify node below the root and before all other nodes
        rectNode = piAssetCreate('type','branch');
        rectNode.name = 'rectify';
        thisR.set('asset','root','add',rectNode);
        idRectify = thisR.get('asset','rectify','id');
        % Place all the previous children under rectify
        for ii=1:numel(idChildren)
            thisR.set('asset',idChildren(ii),'parent',idRectify);
        end
    end
else
    % There was more than one node.
    % Insert a rectify node below the root and before all other nodes
    rectNode = piAssetCreate('type','branch');
    rectNode.name = 'rectify';
    thisR.set('asset','root','add',rectNode);
    idRectify = thisR.get('asset','rectify','id');
    % Place all the previous children under rectify
    for ii=1:numel(idChildren)
        thisR.set('asset',idChildren(ii),'parent',idRectify);
    end
end

% thisR.show(); thisR.show('objects')

%%  Translation

% The camera is handled separately from the objects
from = thisR.get('from');
if ~isequal(from,[0,0,0])
    
    % Move the camera.  Maybe there is already a set for this?
    thisR.set('from',[0,0,0]);
    to = thisR.get('to');
    thisR.set('to',to - from);
    
    % I think this may be doing something more complicated than what I
    % want.
    %     piCameraTranslate(thisR,'xshift',-from(1), ...
    %         'yshift',-from(2), ...
    %         'zshift',-from(3));
    
    % Set the translation of the rectify node
    piAssetSet(thisR,idRectify,'translation',-from);
    % thisR.get('asset','rectify','translate')
    % piAssetGeometry(thisR);
    % piWrite(thisR); scene = piRender(thisR,'render type','radiance'); sceneWindow(scene);
end

%% Rotation around the new camera position at 0,0,0

% See if rotation was turned off
if ~p.Results.rotate, return; end

% Test whether we need to rotate the camera
% or the direction is already aligned with z axis.
[xAngle, yAngle] = direction2zaxis(thisR);
if xAngle == 0 && yAngle == 0, return; end

% Rotate to point the lookat direction along the z axis
rMatrix = piRotate([xAngle,yAngle,0]);
to = thisR.get('to');
thisR.set('to',(rMatrix*to(:)));  % Set to a row vector
% piWrite(thisR); scene = piRender(thisR,'render type','radiance'); sceneWindow(scene);

% Reset the position of every object, rotating by the same amount
objects = thisR.get('objects');
for ii=1:numel(objects)
    curPos = thisR.get('asset',objects(ii),'world position');
    newPos = rMatrix*curPos(:);
    thisR.set('asset',objects(ii),'world position',newPos);
    thisR.set('asset',objects(ii),'world rotate',[xAngle, yAngle, 0]);
end

% thisR.set('asset','rectify', 'world rotate', [-xAngle,-yAngle,0]);
% thisR.get('asset','rectify','rotation')
% piWrite(thisR); [scene,results] = piRender(thisR,'render type','radiance'); sceneWindow(scene);

end

function [xAngle, yAngle] = direction2zaxis(thisR)
%% Angles needed to align lookat with zaxis
%
%  0 = [0   cos(a)  -sin(a)]*direction(:)
%  0 = cos(a)*direction(2) - sin(a)*direction(3)
%  sin(a)*direction(3) = cos(a)*direction(2)
%  sin(a)/cos(a) = (direction(2)/direction(3))
%  tan(a) = (direction(2)/direction(3))
%  a = atan(direction(2)/direction(3))
%
% Rotate again, this time to be perpendicular to the x-axis (x=0). 
%
%  0 =  cos(b)*d2(1) + 0*d2(2) +  sin(b)*d2(3)
%  sin(b)/cos(b) = -d2(1)/d2(3)
%  b = atan(-d2(1)/d2(3))

%
xAngle = 0; yAngle = 0;   % Assume aligned

% Angle to the z axis
direction = thisR.get('lookat direction');   % Unit vector
zaxis = [0 0 1];
CosTheta = max(min(dot(direction,zaxis),1),-1);
ztheta = real(acosd(CosTheta));

% If the direction is different from down the z-axis, do the rest.
% Otherwise, return.  We consider 'different' to be within a tenth of a
% degree, I guess.
%
if ztheta < 0.1, return; end

% Find the rotations in deg around the x and y axes so that the new
% direction vector aligns with the zaxis. 
%
% First find a rotation angle around the x-axis into the x-z plane.
% The angle must satisfy y = 0.  So, we take out the row of the x-rotation
% matrix
%

% Test with different direction vectors
%
% direction = [1 2 0];
% direction = [-1 0 2];
xAngle = atan2d(direction(2),direction(3));   % Radians
xRotationMatrix = piRotate([rad2deg(xAngle),0,0]);
direction2 = xRotationMatrix*direction(:);

%{
% y entry of this vector should be 0
  direction2
%}

% Now solve for y rotation
yAngle = atan2d(-direction2(1),direction2(3));

%{
 % Should be aligned with z-axis
 cos(yAngle)*direction2(1) + sin(yAngle)*direction2(3)
 yRotationMatrix = piRotate([0,rad2deg(yAngle),0]);
 direction3 = yRotationMatrix*direction2(:)
%}

end

%{

rMatrix = piRotate([xAngle,yAngle,0]);

% We have the angles.  Rotate every object's position and its orientation
for ii=1:numel(objects)
    pos = thisR.get('asset',objects(ii),'world coordinate');
    pos = rMatrix*pos(:);
    thisR.set('asset',objects(ii),'world coordinate',pos);
    piAssetRotate('asset',objects(ii),[xAngle,yAngle,0]);
end

end
%}

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

%}
