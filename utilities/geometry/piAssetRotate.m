function object=piAssetRotate(object,degree)
% only rotate around y axis is allowed 


for ii=1:length(object)
    % rotate car
    if ~isempty(object(ii).child) && length(object(ii).child)>2
        object(ii).rotate = [degree 0 1 0];
        % find car position
        object_position = [object(ii).position(1) object(ii).position(3)];
        % rotate object's pmin and pmax for bounding box checking
        object(ii).size.pmin = piPointRotate(object(ii).size.pmin,object_position,-degree);
        object(ii).size.pmax = piPointRotate(object(ii).size.pmax,object_position,-degree);
    end
end
% rotate lights
for jj=1:length(object)
    if contains(object(jj).name,'light')
        light = [object(jj).position(1) object(jj).position(3)];
%         plot([object_position(1) light(1)],[object_position(2) light(2)]);hold on
        axis([-15 15 -15 15]);
        position = piPointRotate(light,object_position,-degree);
%         plot([object_position(1) position(1)],[object_position(2) position(2)]);
        object(jj).position = [position(1) object(jj).position(2) position(2)];
    end
end
end