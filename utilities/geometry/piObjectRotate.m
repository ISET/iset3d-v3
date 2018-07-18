function object=piObjectRotate(object,degree)
% only rotate around y axis is allowed 


for ii=1:length(object)
    % rotate car 
    
    if ~isempty(object(ii).child) && length(object(ii).child)>1
        object(ii).rotate = [degree 0 1 0];
        % rotate object's pmin and pmax for bounding box checking
        object_position = [object(ii).position(1) object(ii).position(3)];
        
        object(ii).size.pmin = piPointRotate(object(ii).size.pmin,object_position,degree);
        object(ii).size.pmax = piPointRotate(object(ii).size.pmax,object_position,degree);
    end
    % rotate lights
    if contains(object(ii).name,'light')
        light = [object(ii).position(1) object(ii).position(3)];
        position = piPointRotate(light,object_position,degree);
        object(ii).position = [position(1) object(ii).position(2) position(2)];
    end
end
end