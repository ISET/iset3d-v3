function  piGeometryWrite(thisR,varargin)

%% Wirte out a new geometry file which matchs the format we used to label object instances
% Input:
%       thisR: a render recipe
%       obj:   Returned by piGeometryRead, contains information about objects.
% Output:
%       None for now.
%
% Zhenyi, 2018
%%
p = inputParser;

varargin =ieParamFormat(varargin);

p.addRequired('thisR',@(x)isequal(class(x),'recipe'));
% default is flase, will turn on for night scene
p.addParameter('lightsFlag',false,@islogical);
p.addParameter('thistrafficflow',[]);

p.parse(thisR,varargin{:});
lightsFlag  = p.Results.lightsFlag;
thistrafficflow = p.Results.thistrafficflow;
%%
[Filepath,scene_fname] = fileparts(thisR.outputFile);
fname = fullfile(Filepath,sprintf('%s_geometry.pbrt',scene_fname));[~,n,e]=fileparts(fname);
obj = thisR.assets;
%% Make parent obj files which includes all the children obj files

fname_obj = fullfile(Filepath,sprintf('%s%s',n,e));
fid_obj = fopen(fname_obj,'w');
fprintf(fid_obj,'# PBRT geometry file converted from C4D exporter output on %i/%i/%i %i:%i:%f \n  \n',clock);

recursiveWriteObjects(fid_obj, obj, Filepath);
recursiveWriteGroups(fid_obj, obj);

%{
for ii = 1: length(obj)
    % If empty, the obj is a camera, which we do not write out.
    % Do not write out arealight here, it has been written in scene.pbrt
    if ~isempty(obj(ii).children) && ~piContains(lower(obj(ii).name), 'arealight')
        fprintf(fid_obj,'ObjectBegin "%s"\n',obj(ii).name);
        for dd = 1:length(obj(ii).children)
            
            if ~isempty(obj(ii).children(dd).mediumInterface)
                fprintf(fid_obj, '%s\n', obj(ii).children(dd).mediumInterface);
            end
            if ~isempty(obj(ii).children(dd).material)
                fprintf(fid_obj, '%s\n', obj(ii).children(dd).material);
            end
            if ~isempty(obj(ii).children(dd).areaLight)
                fprintf(fid_obj, '%s\n', obj(ii).children(dd).areaLight);
            end
            
            [~,output] = fileparts(obj(ii).children(dd).output);
            fprintf(fid_obj, 'Include "scene/PBRT/pbrt-geometry/%s.pbrt" \n', output);
        end
        fprintf(fid_obj,'ObjectEnd \n \n');
        
        if ~isfield(obj(ii),'motion')||isempty(obj(ii).motion)
            for kk = 1:length(obj(ii))
                % if more than one object instance are neeeded, write out all
                % ot them
                [m, n]= size(obj(ii).position);
                if m ==3 && n >= 1
                    for gg = 1:n
                        fprintf(fid_obj,'AttributeBegin \n');
                        if isempty(obj(ii).position(:,gg))
                            fprintf(fid_obj,'Translate 0 0 0 \n');
                        else
                            obj_position = obj(ii).position(:,gg);
                            fprintf(fid_obj,'Translate %f %f %f \n',obj_position(1),...
                                obj_position(2),obj_position(3));
                        end
                        if ~isempty(obj(ii).rotate)
                            obj_rotate = obj(ii).rotate;
                            % Write out rotation
                            fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(:,gg*3-2)); % Z
                            fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(:,gg*3-1)); % Y
                            fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(:,gg*3));   % X 
                        end
                        % Write out scaling
                        if isfield(obj(ii),'scale')
                        if ~isempty(obj(ii).scale)
                            obj_scale = obj(ii).scale(:,gg);
                            fprintf(fid_obj,'Scale %f %f %f\n',obj_scale(1),...
                                obj_scale(2),obj_scale(3)); % Y
                        end
                        end
                        fprintf(fid_obj,'ObjectInstance "%s"\n', obj(ii).name);
                        fprintf(fid_obj,'AttributeEnd \n \n');
                    end
                else
                    error('Position should be a 3 by n matrix \n')
                end
            end
            
        else
            for kk = 1:length(obj(ii))
                % if more than one object instance are neeeded, write out all
                % ot them
                [m, n]= size(obj(ii).position);
                if m ==3 && n >= 1
                    for gg = 1:n
                        fprintf(fid_obj,'AttributeBegin \n');
                        % ActiveTranform Start
                        fprintf(fid_obj,'ActiveTransform StartTime \n');
                        if isempty(obj(ii).position(:,gg))
                            fprintf(fid_obj,'Translate 0 0 0 \n');
                        else
                            obj_position = obj(ii).position(:,gg);
                            fprintf(fid_obj,'Translate %f %f %f \n',obj_position(1),...
                                obj_position(2),obj_position(3));
                        end
                        if ~isempty(obj(ii).rotate)
                            obj_rotate = obj(ii).rotate;
                            % Write out rotation
                            fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(:,gg*3-2)); % Z
                            fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(:,gg*3-1)); % Y
                            fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(:,gg*3));   % X 
                        end
                        % Write out scaling
                        if isfield(obj(ii),'scale')
                        if ~isempty(obj(ii).scale)
                            obj_scale = obj(ii).scale(:,gg);
                            fprintf(fid_obj,'Scale %f %f %f\n',obj_scale(1),...
                                obj_scale(2),obj_scale(3)); % Y
                        end
                        end
                        % ActiveTranform End
                        fprintf(fid_obj,'ActiveTransform EndTime \n');
                        if isempty(obj(ii).motion.position(:,gg))
                            fprintf(fid_obj,'Translate 0 0 0 \n');
                        else
                            obj_position = obj(ii).motion.position(:,gg);
                            fprintf(fid_obj,'Translate %f %f %f \n',obj_position(1),...
                                obj_position(2),obj_position(3));
                        end
                        if ~isempty(obj(ii).motion.rotate)
                            obj_rotate = obj(ii).motion.rotate;
                            % Write out rotation
                            fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(:,gg*3-2)); % Z
                            fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(:,gg*3-1)); % Y
                            fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(:,gg*3));   % X 
                        end
                        fprintf(fid_obj,'ObjectInstance "%s"\n', obj(ii).name);
                        fprintf(fid_obj,'AttributeEnd \n \n');
                    end
                else
                    error('Position should be a 3 by n matrix \n')
                end
            end
        end
    end
    % add a lightsFlag, we dont use lights for day scene.
    if lightsFlag
        if piContains(obj(ii).name,'_lightfront')
            from = obj(ii).position;
            obj(ii).position = [0 0 0];
            for gg = 1:n
                fprintf(fid_obj,'AttributeBegin \n');
                if isempty(obj(ii).position(:,gg))
                    fprintf(fid_obj,'Translate 0 0 0 \n');
                else
                    obj_position = obj(ii).position(:,gg);
                    fprintf(fid_obj,'Translate %f %f %f \n',obj_position(1),...
                        obj_position(2),obj_position(3));
                end
                if ~isempty(obj(ii).rotate)&& ~isequal(obj(ii).rotate,[0;0;0;0])
                    obj_rotate = obj(ii).rotate(:,gg);
                    fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(1),...
                        obj_rotate(2),obj_rotate(3),obj_rotate(4));
                end
                fprintf(fid_obj,'LightSource "point" "color I" [3 3 3] "rgb scale" [1.0 1.0 1.0] "point from" [%f %f %f] \n',...
                    from(1),from(2),from(3));
                fprintf(fid_obj,'AttributeEnd \n \n');
            end
        end
        if piContains(obj(ii).name,'_lightback')
            from = obj(ii).position;
            obj(ii).position = [0;0;0];
            for gg = 1:n
                fprintf(fid_obj,'AttributeBegin \n');
                if isempty(obj(ii).position(:,gg))
                    fprintf(fid_obj,'Translate 0 0 0 \n');
                else
                    obj_position = obj(ii).position(:,gg);
                    fprintf(fid_obj,'Translate %f %f %f \n',obj_position(1),...
                        obj_position(2),obj_position(3));
                end
                if ~isempty(obj(ii).rotate)&& ~isequal(obj(ii).rotate,[0;0;0;0])
                    obj_rotate = obj(ii).rotate(:,gg);
                    fprintf(fid_obj,'Rotate %f %f %f %f \n',obj_rotate(1),...
                        obj_rotate(2),obj_rotate(3),obj_rotate(4));
                end
                fprintf(fid_obj,'LightSource "point" "color I" [0.5 0.5 0.5] "rgb scale" [0.5 0.5 0.5] "point from" [%f %f %f] \n',...
                    from(1),from(2),from(3));
                fprintf(fid_obj,'AttributeEnd \n \n');
            end
        end
    end
end
if ~isempty(thistrafficflow)
    for jj = 1:8
        for mm = 1: length(obj)
            if mod(jj,4)~=0
                num = mod(jj,4);
            else num = 4;
            end
            order = floor((jj+3)/4);
            if contains(obj(mm).name,sprintf('trafficlight_%03d',num))...
                    && contains(obj(mm).name,sprintf('_%d_',order)) ...
                    &&contains(obj(mm).name,thistrafficflow.light(jj).State)...
                    &&isempty(obj(mm).children) && isfield(thistrafficflow,'light')
                piTrafficlightAssign(fid_obj,obj(mm));
            end
        end
    end
end

%}
fclose(fid_obj);
fprintf('%s is written out \n', fname_obj);
end


function recursiveWriteObjects(fid, objects, rootPath)

% Parse the geometry tree structure and for every geometry object print the
% corresponding shape into a separate pbrt geometry file.

if isempty(objects)
    return;
end

for i=1:length(objects.children)
    
    if isempty(objects.children(i).areaLight)
        % Area lights are not supported with object instances.
        
        fprintf(fid, 'ObjectBegin "%s"\n', objects.children(i).name);
        if ~isempty(objects.children(i).mediumInterface)
            fprintf(fid, '%s\n', objects.children(i).mediumInterface);
        end
        if ~isempty(objects.children(i).material)
            fprintf(fid, '%s\n', objects.children(i).material);
        end
        if ~isempty(objects.children(i).areaLight)
            fprintf(fid, '%s\n', objects.children(i).areaLight);
        end

        if ~isempty(objects.children(i).output)
            [~,output] = fileparts(objects.children(i).output);
            fprintf(fid, 'Include "scene/PBRT/pbrt-geometry/%s.pbrt" \n', output);
        else
            if ~isempty(objects.children(i).shape)
                name = objects.children(i).name;
                geometryFile = fopen(fullfile(rootPath,'scene','PBRT','pbrt-geometry',sprintf('%s.pbrt',name)),'w');
                fprintf(geometryFile,'%s',objects.children(i).shape);
                fclose(geometryFile);
                fprintf(fid, 'Include "scene/PBRT/pbrt-geometry/%s.pbrt" \n', name);
            end
        end
        fprintf(fid, 'ObjectEnd\n\n');
    else
        
        if ~isempty(objects.children(i).shape)
            name = objects.children(i).name;
            geometryFile = fopen(fullfile(rootPath,'scene','PBRT','pbrt-geometry',sprintf('%s.pbrt',name)),'w');
            fprintf(geometryFile,'%s',objects.children(i).shape);
            fclose(geometryFile);
        end
    end
end

for j=1:length(objects.groupobjs)
    recursiveWriteObjects(fid,objects.groupobjs(j), rootPath);
end


end



function recursiveWriteGroups(fid, objects)

% Parse the geometry object tree and for every group object replace the
% actuall geometry with the 'Include' directive.

if isempty(objects)
    return;
end

for n=1:length(objects)
    
    currentObject = objects(n);
    
    fprintf(fid,'AttributeBegin\n');
    fprintf(fid,'#ObjectName %s:Vector(%.3f, %.3f, %.3f)\n',currentObject.name, ...
                                                            currentObject.size.l, ...
                                                            currentObject.size.w, ...
                                                            currentObject.size.h);
    fprintf(fid,'Translate %.3f %.3f %.3f\n',currentObject.position(1), currentObject.position(2), currentObject.position(3));
    fprintf(fid,'Rotate %.3f %.3f %.3f %.3f \n',currentObject.rotate(:,1)); % Z
    fprintf(fid,'Rotate %.3f %.3f %.3f %.3f \n',currentObject.rotate(:,2)); % Y
    fprintf(fid,'Rotate %.3f %.3f %.3f %.3f \n',currentObject.rotate(:,3));   % X 
    fprintf(fid,'Scale %.3f %.3f %.3f \n',currentObject.scale);
    
    for j=1:length(currentObject.children)
       if isempty(currentObject.children(j).areaLight)
            fprintf(fid,'ObjectInstance "%s"\n',currentObject.children(j).name); 
       else
           if ~isempty(objects.children(j).mediumInterface)
            fprintf(fid, '%s\n', objects.children(j).mediumInterface);
           end
            if ~isempty(objects.children(j).material)
                fprintf(fid, '%s\n', objects.children(j).material);
            end
            if ~isempty(objects.children(j).areaLight)
                fprintf(fid, '%s\n', objects.children(j).areaLight);
            end

            if ~isempty(objects.children(j).shape)
                fprintf(fid, 'Include "scene/PBRT/pbrt-geometry/%s.pbrt" \n', objects.children(j).name);
            end
       end
    end
    
    for j=1:length(currentObject.groupobjs)
        recursiveWriteGroups(fid,currentObject.groupobjs(j));
    end
    fprintf(fid,'AttributeEnd\n');
end
fprintf(fid,'\n');

end


