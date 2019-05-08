function piTrafficlightAssign(fid_obj, obj)
% Assign a traffic light
%
% Syntax:
%   piTrafficlightAssign(fid_obj, obj)
%
% Description:
%    Assign a traffic light (obj) to an environment's file (fid_obj).
%
% Inputs:
%    fid_obj - Object. The environmental object (file). You are adding
%              information to the object to be written to its file outside
%              of this function.
%    obj     - Object. The traffic light object.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%

if piContains(obj.name, 'green')  % If the light is green
    from = obj.position;
    obj.position = [0 0 0];
    fprintf(fid_obj, 'AttributeBegin \n');
    if isempty(obj.position)
        fprintf(fid_obj, 'Translate 0 0 0 \n');
    else
        obj_position = obj.position;
        fprintf(fid_obj, 'Translate %f %f %f \n', obj_position(1), ...
            obj_position(2), obj_position(3));
    end
    if ~isempty(obj.rotate)&& ~isequal(obj.rotate, [0;0;0;0])
        obj_rotate = obj.rotate;
        fprintf(fid_obj, 'Rotate %f %f %f %f \n', obj_rotate(1), ...
            obj_rotate(2), obj_rotate(3), obj_rotate(4));
        fprintf(fid_obj, strcat('LightSource "point" "color I" ', ...
            '[0.01 0.5 0.01] "rgb scale" [3 3 3] "point from" ', ...
            '[%f %f %f] \n'), from(1), from(2), from(3));
        fprintf(fid_obj, 'AttributeEnd \n \n');
    end
end

if piContains(obj.name, 'yellow')  % If the light is yellow
    from = obj.position;
    obj.position = [0 0 0];
    fprintf(fid_obj, 'AttributeBegin \n');
    if isempty(obj.position)
        fprintf(fid_obj, 'Translate 0 0 0 \n');
    else
        obj_position = obj.position;
        fprintf(fid_obj, 'Translate %f %f %f \n', obj_position(1), ...
            obj_position(2), obj_position(3));
    end
    if ~isempty(obj.rotate)&& ~isequal(obj.rotate, [0;0;0;0])
        obj_rotate = obj.rotate;
        fprintf(fid_obj, 'Rotate %f %f %f %f \n', obj_rotate(1), ...
            obj_rotate(2), obj_rotate(3), obj_rotate(4));
        fprintf(fid_obj, strcat('LightSource "point" "color I" ', ...
            '[0.5 0.5 0.01] "rgb scale" [3 3 3] "point from" ', ...
            '[%f %f %f] \n'), from(1), from(2), from(3));
        fprintf(fid_obj, 'AttributeEnd \n \n');
    end
end

if piContains(obj.name, 'red')  % If the light is red
    from = obj.position;
    obj.position = [0 0 0];
    fprintf(fid_obj, 'AttributeBegin \n');
    if isempty(obj.position)
        fprintf(fid_obj, 'Translate 0 0 0 \n');
    else
        obj_position = obj.position;
        fprintf(fid_obj, 'Translate %f %f %f \n', obj_position(1), ...
            obj_position(2), obj_position(3));
    end
    if ~isempty(obj.rotate)&& ~isequal(obj.rotate, [0;0;0;0])
        obj_rotate = obj.rotate;
        fprintf(fid_obj, 'Rotate %f %f %f %f \n', obj_rotate(1), ...
            obj_rotate(2), obj_rotate(3), obj_rotate(4));
        fprintf(fid_obj, strcat('LightSource "point" "color I" ', ...
            '[0.5 0.01 0.01] "rgb scale" [3 3 3] "point from" ', ...
            '[%f %f %f] \n'), from(1), from(2), from(3));
        fprintf(fid_obj, 'AttributeEnd \n \n');
    end
end

end
