function piTrafficlightAssign(fid_obj,obj)
if piContains(obj.name,'green')
    from = obj.position;
    obj.position = [0 0 0];
    fprintf(fid_obj,'AttributeBegin \n');
    if isempty(obj.position)
        fprintf(fid_obj,'Translate 0 0 0 \n');
    else
        obj_position = obj.position;
        fprintf(fid_obj,'Translate %f %f %f \n',obj_position(1),...
            obj_position(2),obj_position(3));
    end
    if ~isempty(obj.rotate)&& ~isequal(obj.rotate,[0;0;0;0])
        obj_rotate = obj.rotate;
        fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(1),...
            obj_rotate(2),obj_rotate(3),obj_rotate(4));
        fprintf(fid_obj,'LightSource "point" "color I" [0.01 0.5 0.01] "rgb scale" [3 3 3] "point from" [%f %f %f] \n',...
            from(1),from(2),from(3));
        fprintf(fid_obj,'AttributeEnd \n \n');
    end
end
if piContains(obj.name,'yellow')
    from = obj.position;
    obj.position = [0 0 0];
    fprintf(fid_obj,'AttributeBegin \n');
    if isempty(obj.position)
        fprintf(fid_obj,'Translate 0 0 0 \n');
    else
        obj_position = obj.position;
        fprintf(fid_obj,'Translate %f %f %f \n',obj_position(1),...
            obj_position(2),obj_position(3));
    end
    if ~isempty(obj.rotate)&& ~isequal(obj.rotate,[0;0;0;0])
        obj_rotate = obj.rotate;
        fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(1),...
            obj_rotate(2),obj_rotate(3),obj_rotate(4));
        fprintf(fid_obj,'LightSource "point" "color I" [0.5 0.5 0.01] "rgb scale" [3 3 3] "point from" [%f %f %f] \n',...
            from(1),from(2),from(3));
        fprintf(fid_obj,'AttributeEnd \n \n');
    end
end
if piContains(obj.name,'red')
    from = obj.position;
    obj.position = [0 0 0];
    fprintf(fid_obj,'AttributeBegin \n');
    if isempty(obj.position)
        fprintf(fid_obj,'Translate 0 0 0 \n');
    else
        obj_position = obj.position;
        fprintf(fid_obj,'Translate %f %f %f \n',obj_position(1),...
            obj_position(2),obj_position(3));
    end
    if ~isempty(obj.rotate)&& ~isequal(obj.rotate,[0;0;0;0])
        obj_rotate = obj.rotate;
        fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(1),...
            obj_rotate(2),obj_rotate(3),obj_rotate(4));
        fprintf(fid_obj,'LightSource "point" "color I" [0.5 0.01 0.01] "rgb scale" [3 3 3] "point from" [%f %f %f] \n',...
            from(1),from(2),from(3));
        fprintf(fid_obj,'AttributeEnd \n \n');
    end
end



end