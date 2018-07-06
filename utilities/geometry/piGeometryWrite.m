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
[Filepath,scene_fname] = fileparts(thisR.inputFile);
fname = fullfile(Filepath,sprintf('%s_geometry.pbrt',scene_fname));[~,n,e]=fileparts(fname);

%% Make parent obj files which includes all the child obj files

fname_obj = fullfile(Filepath,sprintf('%s%s',n,e));
% if ~exist(Obj_filepath,'dir')
%     mkdir(Obj_filepath);
% end
fid_obj = fopen(fname_obj,'w');
for ii = 1: length(obj)
    % Make a pbrt file which inclues all grouped parents files.
    % If empty, the obj is a camera, which we do not write out.
    % we change the camera lookAt in thisR
    if ~isempty(obj(ii).child)
%         Obj_filepath  =fullfile(Filepath, 'scene','PBRT','pbrt-object');
%         fname_obj = fullfile(Obj_filepath,sprintf('%s%s',obj(ii).name,e));
        fprintf(fid_obj,'# PBRT geometry file converted from C4D exporter output on %i/%i/%i %i:%i:%0.2f \n  \n',clock);
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
            %if isfield(obj(ii),'concattransform')
                % 
%                 if ~isempty(obj(ii).concattransform)
%                     fprintf(fid_obj,'ConcatTransform [%f %f %f %f  %f %f %f %f  %f %f %f %f  %f %f %f %f]\n', obj(ii).concattransform.x,...
%                         obj(ii).concattransform.y,obj(ii).concattransform.z,obj(ii).concattransform.t);
%                 end
                % Default rotate needs to be [0 0 0 0] when we exported 3d
                % mesh to pbrt, we only read concattransform
                % translate is converted from concattransform. 
            %end
                fprintf(fid_obj,'Translate %f %f %f \n',obj(ii).position);
                fprintf(fid_obj,'Rotate %f %f %f %f \n',obj(ii).rotate);
            
            fprintf(fid_obj,'ObjectInstance "%s"\n', obj(ii).name);
            fprintf(fid_obj,'AttributeEnd \n \n');
        end
    end
end
fclose(fid_obj);
fprintf('%s is written out \n', fname_obj);
end
