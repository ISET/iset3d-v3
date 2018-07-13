function object = piObjectTranslate(object,heading,side)
% translte car and lights
% positive x is heading direction
% default center of the car  is 0 0 0, we adjust the y(up) of the car to
% place it in a correct position.
for ii=1:length(object)
y = 0;
x = heading;
z = side;
if isempty(object(ii).position)
    object(ii).position = [x y z];
else
    object(ii).position = object(ii).position + [x y z];
end
% object(ii).size.pmin = object(ii).size.pmin +[x z];
% object(ii).size.pmax = object(ii).size.pmax +[x z];
end
end