function  piGeometryWrite(thisR,obj)

%% Wirte out a new geometry file which matchs the format we used to label object instances
% Input: 
%       thisR: a render recipe
%       obj:   Returned by piGeometryRead, contains information about objects.  
% Output:
%       None for now.
%
% Zhenyi, 2018
%%
[Filepath,scene_fname] = fileparts(thisR.outputFile);
fname = fullfile(Filepath,sprintf('%s_geometry.pbrt',scene_fname));[~,n,e]=fileparts(fname);

%% Make parent obj files which includes all the child obj files

fname_obj = fullfile(Filepath,sprintf('%s%s',n,e));
% if ~exist(Obj_filepath,'dir')
%     mkdir(Obj_filepath);
% end
fid_obj = fopen(fname_obj,'w');
fprintf(fid_obj,'# PBRT geometry file converted from C4D exporter output on %i/%i/%i %i:%i:%0.2f \n  \n',clock);
for ii = 1: length(obj)
    % Make a pbrt file which inclues all grouped parents files.
    % If empty, the obj is a camera, which we do not write out.
    % we change the camera lookAt in thisR
    if ~isempty(obj(ii).child)
%         Obj_filepath  =fullfile(Filepath, 'scene','PBRT','pbrt-object');
%         fname_obj = fullfile(Obj_filepath,sprintf('%s%s',obj(ii).name,e));
        
        fprintf(fid_obj,'ObjectBegin "%s"\n',obj(ii).name);
        % Write out obj information
            for dd = 1:length(obj(ii).child)
                if isfield(obj(ii).child(dd),'material')
                    fprintf(fid_obj, '%s\n', obj(ii).child(dd).material);
                end
                [~,output] = fileparts(obj(ii).child(dd).output);
                fprintf(fid_obj, 'Include "scene/PBRT/pbrt-geometry/%s.pbrt" \n', output);
            end
            fprintf(fid_obj,'ObjectEnd \n \n');

        for kk = 1:length(obj(ii))
            fprintf(fid_obj,'AttributeBegin \n');
            if isempty(obj(ii).position)
                fprintf(fid_obj,'Translate 0 0 0 \n');
            else
                fprintf(fid_obj,'Translate %f %f %f \n',obj(ii).position);
            end
            if ~isempty(obj(ii).rotate)&& ~isequal(obj(ii).rotate,[0 0 0 0])
                fprintf(fid_obj,'Rotate %f %f %f %f \n',obj(ii).rotate);
            end 
            fprintf(fid_obj,'ObjectInstance "%s"\n', obj(ii).name);
            fprintf(fid_obj,'AttributeEnd \n \n');
        end
    end
    % create a spot light point from current position along x axis
    % will come back later and modify the parameters here, meters and
    % coneangle/ conedeltaangle
    % front light point to front, give 10 meters here, might change later
    if contains(obj(ii).name,'_lightfront')
        from = obj(ii).position;
        to = obj(ii).position + [20 0 0];
        obj(ii).position = [0 0 0];
        fprintf(fid_obj,'AttributeBegin \n');
        fprintf(fid_obj,'Translate %f %f %f \n',obj(ii).position);
        if ~isequal(obj(ii).rotate,[0 0 0 0])
        fprintf(fid_obj,'Rotate %f %f %f %f \n',obj(ii).rotate);
        end
        fprintf(fid_obj,'LightSource "spot" "color I" [1.0 1.0 1.0] "rgb scale" [100.0 100.0 100.0] "point from" [%f %f %f] "point to" [%f %f %f] "float coneangle" [30] "float conedeltaangle" [5] \n',from,to);
        fprintf(fid_obj,'AttributeEnd \n \n');
    end
    if contains(obj(ii).name,'_lightback')
        from = obj(ii).position;
        to = obj(ii).position + [-5 0 0];
        obj(ii).position = [0 0 0];
        fprintf(fid_obj,'AttributeBegin \n');
        fprintf(fid_obj,'Translate %f %f %f \n',obj(ii).position);
        if ~isequal(obj(ii).rotate,[0 0 0 0])
        fprintf(fid_obj,'Rotate %f %f %f %f \n',obj(ii).rotate);
        end
        fprintf(fid_obj,'LightSource "spot" "color I" [1.0 1.0 1.0] "rgb scale" [100.0 100.0 100.0] "point from" [%f %f %f] "point to" [%f %f %f] "float coneangle" [30] "float conedeltaangle" [5] \n',from,to);
        fprintf(fid_obj,'AttributeEnd \n \n');
    end
end
fclose(fid_obj);
fprintf('%s is written out \n', fname_obj);
end
