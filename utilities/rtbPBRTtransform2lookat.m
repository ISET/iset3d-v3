function [from to up] = rtbPBRTtransform2lookat(world2Cam);

cam2World = inv(world2Cam);
from = cam2World*[0 0 0 1]';
dir = cam2World*[0 0 1 0]';
to = from  + dir;
to = to(1:3);
from = from(1:3);
if det(world2Cam) < 0
    up = cam2World*[0 -1 0 0]';
else
    up = cam2World*[0 1 0 0]';
end
up = up(1:3);
end