function thisR = piCameraRotate(thisR,varargin)
% Adjust camera look at matrix by rotation at camera coordinates.
% The methods works for Y-up coordinates: lookAt.up = [0 1 0] by default 
% zRot: positive degree -> clockwise
% Input
%  thisR: render recipe, which contains camera look at matrix
%
% Key/value pairs
%   xaxis - rotation in degrees
%   yaxis - same
%   zaxis - same
%
% see also: piCameraTranslate;
%{
thisR = piCameraRotate(thisR, 'xrot',5);
thisR = piCameraRotate(thisR, 'yrot',5);
thisR = piCameraRotate(thisR, 'zrot',5);
%}
varargin = ieParamFormat(varargin);

p = inputParser;
p.addParameter('xrot',0,@isscalar);
p.addParameter('yrot',0,@isscalar);
p.addParameter('zrot',0,@isscalar);
p.parse(varargin{:});

xRot = p.Results.xrot;
yRot = p.Results.yrot;
zRot = p.Results.zrot;
%%
thislookAt = thisR.lookAt;
newlookAt = thislookAt;
dir = norm(thislookAt.from - thislookAt.to);
norm(dir);
if zRot~=0
%     zRot = -zRot;
    newPoint = piPointRotate([0 1],...
        [0 0], zRot);
    newlookAt.up = [newPoint 0];
end
if yRot~=0
    newPoint = piPointRotate([thislookAt.to(1) thislookAt.to(3)],...
        [thislookAt.from(1) thislookAt.from(3)], yRot);
    newlookAt.to = [newPoint(1) thislookAt.to(2) newPoint(2)];
end
if xRot~=0
    newPoint = piPointRotate([thislookAt.to(2) thislookAt.to(3)],...
        [thislookAt.from(2) thislookAt.from(3)], xRot);
    newlookAt.to = [thislookAt.to(1) newPoint(1) newPoint(2)];
end
thisR.lookAt = newlookAt;
end