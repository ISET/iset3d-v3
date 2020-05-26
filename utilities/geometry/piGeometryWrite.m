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

% varargin =ieParamFormat(varargin);

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
        if ~isempty(objects.children(i).light)
            if ~isempty(objects.children(i).light)
                for ii = 1:numel(objects.children(i).light)
                    fprintf(fid, '%s\n', objects.children(i).light{ii});
                end
            end 
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
        
        %{
        % Not sure if we need this
            if isfield(objects.children(i), 'motion') &&...
                    ~isempty(objects.children(i).motion)
                for kk = 1:size(objects.children(i).position, 2)
                    fprintf(fid, 'ActiveTransform EndTime \n');
                    if isempty(objects.children(i).motion.position(:,kk))
                        fprintf(fid,'Translate 0 0 0 \n');
                    else
                        pos = objects.children(i).motion.position(:,kk);
                        fprintf(fid,'Translate %f %f %f \n',pos(1),...
                            pos(2),pos(3));
                    end

                    if ~isempty(objects.children(i).motion.rotate)
                        rot = objects.children(i).motion.rotate;
                        % Write out rotation
                        fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3-2)); % Z
                        fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3-1)); % Y
                        fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3));   % X
                    end
                end
            end
        %}
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
    % If a motion exists in the current object, prepare to write it out by
    % having an additional line below.
    if isfield(currentObject, 'motion') &&...
            ~isempty(currentObject.motion)
        fprintf(fid,'ActiveTransform StartTime \n');
    end
    fprintf(fid,'Translate %.3f %.3f %.3f\n',currentObject.position(1), currentObject.position(2), currentObject.position(3));
    fprintf(fid,'Rotate %.3f %.3f %.3f %.3f \n',currentObject.rotate(:,1)); % Z
    fprintf(fid,'Rotate %.3f %.3f %.3f %.3f \n',currentObject.rotate(:,2)); % Y
    fprintf(fid,'Rotate %.3f %.3f %.3f %.3f \n',currentObject.rotate(:,3));   % X 
    fprintf(fid,'Scale %.3f %.3f %.3f \n',currentObject.scale);
    
    % Write out this motion
    if isfield(currentObject, 'motion') &&...
            ~isempty(currentObject.motion)
        for kk = 1:size(currentObject.position, 2)
            fprintf(fid, 'ActiveTransform EndTime \n');
            if isempty(currentObject.motion.position(:,kk))
                fprintf(fid,'Translate 0 0 0 \n');
            else
                pos = currentObject.motion.position(:,kk);
                fprintf(fid,'Translate %f %f %f \n',pos(1),...
                    pos(2),pos(3));
            end
            
            if ~isempty(currentObject.motion.rotate)
                rot = currentObject.motion.rotate;
                % Write out rotation
                fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3-2)); % Z
                fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3-1)); % Y
                fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3));   % X
            end
        end
    end
    
    for j=1:length(currentObject.children)
       if isempty(currentObject.children(j).areaLight)
           if ~isempty(currentObject.children(j).mediumInterface)
               fprintf(fid, '%s\n', currentObject.children(j).mediumInterface);
           end
           if ~isempty(currentObject.children(j).material)
               fprintf(fid, '%s\n', currentObject.children(j).material);
           end
           
           if ~isempty(currentObject.children(j).areaLight)
               fprintf(fid, '%s\n', currentObject.children(j).areaLight);
           end
           
           if ~isempty(currentObject.children(j).shape)
               fprintf(fid, 'Include "scene/PBRT/pbrt-geometry/%s.pbrt" \n', currentObject.children(j).name);
           end
           %{
           % Not sure if we need this
           if isfield(currentObject.children(j), 'motion') &&...
                   ~isempty(currentObject.children(j).motion)
               for kk = 1:size(currentObject.children(j).position, 2)
                   fprintf(fid, 'ActiveTransform EndTime \n');
                   if isempty(currentObject.children(j).motion.position(:,kk))
                       fprintf(fid,'Translate 0 0 0 \n');
                   else
                       pos = currentObject.children(j).motion.position(:,kk);
                       fprintf(fid,'Translate %f %f %f \n',pos(1),...
                           pos(2),pos(3));
                   end
                   
                   if ~isempty(currentObject.children(j).motion.rotate)
                       rot = currentObject.children(j).motion.rotate;
                       % Write out rotation
                       fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3-2)); % Z
                       fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3-1)); % Y
                       fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3));   % X
                   end
               end
           end
           %}
                   
       else
           fprintf(fid,'ObjectInstance "%s"\n',currentObject.children(j).name);
       end
    end
    
    for j=1:length(currentObject.groupobjs)
        recursiveWriteGroups(fid,currentObject.groupobjs(j));
    end
    fprintf(fid,'AttributeEnd\n');
end
fprintf(fid,'\n');

end


