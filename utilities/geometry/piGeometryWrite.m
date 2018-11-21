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
thisR.world{length(thisR.world)-1} = sprintf('Include "%s_geometry.pbrt" ',scene_fname);
obj = thisR.assets;
%% Make parent obj files which includes all the children obj files

fname_obj = fullfile(Filepath,sprintf('%s%s',n,e));
fid_obj = fopen(fname_obj,'w');
fprintf(fid_obj,'# PBRT geometry file converted from C4D exporter output on %i/%i/%i %i:%i:%0.2f \n  \n',clock);
for ii = 1: length(obj)
    % If empty, the obj is a camera, which we do not write out.
    if ~isempty(obj(ii).children)
        fprintf(fid_obj,'ObjectBegin "%s"\n',obj(ii).name);
        for dd = 1:length(obj(ii).children)
            if isfield(obj(ii).children(dd),'material')
                fprintf(fid_obj, '%s\n', obj(ii).children(dd).material);
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
                            fprintf(fid_obj,'Translate %0.2f %0.2f %0.2f \n',obj_position(1),...
                                obj_position(2),obj_position(3));
                        end
                        if ~isempty(obj(ii).rotate)
                            obj_rotate = obj(ii).rotate;
                            % Write out ratationY
                            fprintf(fid_obj,'Rotate %0.2f %0.2f %0.2f %0.2f \n',obj_rotate(:,gg*3-2)); % Y
                            fprintf(fid_obj,'Rotate %0.2f %0.2f %0.2f %0.2f \n',obj_rotate(:,gg*3));   % Z
                            fprintf(fid_obj,'Rotate %0.2f %0.2f %0.2f %0.2f \n',obj_rotate(:,gg*3-1)); % X
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
                            fprintf(fid_obj,'Translate %0.2f %0.2f %0.2f \n',obj_position(1),...
                                obj_position(2),obj_position(3));
                        end
                        if ~isempty(obj(ii).rotate)
                            obj_rotate = obj(ii).rotate;
                            % Write out ratationY
                            fprintf(fid_obj,'Rotate %0.2f %0.2f %0.2f %0.2f \n',obj_rotate(:,gg*3-2)); % Y
                            fprintf(fid_obj,'Rotate %0.2f %0.2f %0.2f %0.2f \n',obj_rotate(:,gg*3));   % Z
                            fprintf(fid_obj,'Rotate %0.2f %0.2f %0.2f %0.2f \n',obj_rotate(:,gg*3-1)); % X
                        end
                        % ActiveTranform End
                        fprintf(fid_obj,'ActiveTransform EndTime \n');
                        if isempty(obj(ii).motion.position(:,gg))
                            fprintf(fid_obj,'Translate 0 0 0 \n');
                        else
                            obj_position = obj(ii).motion.position(:,gg);
                            fprintf(fid_obj,'Translate %0.2f %0.2f %0.2f \n',obj_position(1),...
                                obj_position(2),obj_position(3));
                        end
                        if ~isempty(obj(ii).motion.rotate)
                            obj_rotate = obj(ii).motion.rotate;
                            % Write out ratationY
                            fprintf(fid_obj,'Rotate %0.2f %0.2f %0.2f %0.2f \n',obj_rotate(:,gg*3-2)); % Y
                            fprintf(fid_obj,'Rotate %0.2f %0.2f %0.2f %0.2f \n',obj_rotate(:,gg*3));   % Z
                            fprintf(fid_obj,'Rotate %0.2f %0.2f %0.2f %0.2f \n',obj_rotate(:,gg*3-1)); % X
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
        if strfind(obj(ii).name,'_lightfront')
            from = obj(ii).position;
            obj(ii).position = [0 0 0];
            for gg = 1:n
                fprintf(fid_obj,'AttributeBegin \n');
                if isempty(obj(ii).position(:,gg))
                    fprintf(fid_obj,'Translate 0 0 0 \n');
                else
                    obj_position = obj(ii).position(:,gg);
                    fprintf(fid_obj,'Translate %0.2f %0.2f %0.2f \n',obj_position(1),...
                        obj_position(2),obj_position(3));
                end
                if ~isempty(obj(ii).rotate)&& ~isequal(obj(ii).rotate,[0;0;0;0])
                    obj_rotate = obj(ii).rotate(:,gg);
                    fprintf(fid_obj,'Rotate %0.2f %0.2f %0.2f %0.2f \n',obj_rotate(1),...
                        obj_rotate(2),obj_rotate(3),obj_rotate(4));
                end
                fprintf(fid_obj,'LightSource "point" "color I" [3 3 3] "rgb scale" [1.0 1.0 1.0] "point from" [%f %f %f] \n',...
                    from(1),from(2),from(3));
                fprintf(fid_obj,'AttributeEnd \n \n');
            end
        end
        if strfind(obj(ii).name,'_lightback')
            from = obj(ii).position;
            obj(ii).position = [0;0;0];
            for gg = 1:n
                fprintf(fid_obj,'AttributeBegin \n');
                if isempty(obj(ii).position(:,gg))
                    fprintf(fid_obj,'Translate 0 0 0 \n');
                else
                    obj_position = obj(ii).position(:,gg);
                    fprintf(fid_obj,'Translate %0.2f %0.2f %0.2f \n',obj_position(1),...
                        obj_position(2),obj_position(3));
                end
                if ~isempty(obj(ii).rotate)&& ~isequal(obj(ii).rotate,[0;0;0;0])
                    obj_rotate = obj(ii).rotate(:,gg);
                    fprintf(fid_obj,'Rotate %0.2f %0.2f %0.2f %0.2f \n',obj_rotate(1),...
                        obj_rotate(2),obj_rotate(3),obj_rotate(4));
                end
                fprintf(fid_obj,'LightSource "point" "color I" [0.5 0.5 0.5] "rgb scale" [0.5 0.5 0.5] "point from" [%f %f %f] \n',...
                    from(1),from(2),from(3));
                fprintf(fid_obj,'AttributeEnd \n \n');
            end
        end
    end
    % disable trafficlight for now, too many fireflies
    %
    if ~isempty(thistrafficflow)
        for jj = 1:8
            for mm = 1: length(obj)
                if mod(jj,4)~=0
                    num = mod(jj,4);
                else num = 4;
                end
                order = floor((jj+3)/4);
                if strfind(obj(mm).name,sprintf('trafficlight_%03d',num))...
                        && strfind(obj(mm).name,sprintf('_%d_',order)) ...
                        &&strfind(obj(mm).name,thistrafficflow.light(jj).State)...
                        &&isempty(obj(mm).children) && isfield(thistrafficflow,'light')
                    piTrafficlightAssign(fid_obj,obj(mm));
                end
            end
        end
    end
    %
end
fclose(fid_obj);
fprintf('%s is written out \n', fname_obj);
end


