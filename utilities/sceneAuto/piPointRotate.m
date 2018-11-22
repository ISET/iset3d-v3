function rotpoint = piPointRotate(point, center, theta)
% point is 2d [x, y]
% center is where the point rotate around
% theta is the rotation degree


%% 
%Create rotation matrix
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
% Rotate your point(s)
% point = point'; 
% center  = center';
rotpoint = R*(point+center)'+center';
rotpoint = rotpoint';
end


