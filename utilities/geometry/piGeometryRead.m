function [renderRecipe,groupobj] = piGeometryRead(renderRecipe)
%% Read a geometry file exported by C4d and extract objects information
%
%Input
%   renderRecipe:  a recipe object describing the rendering parameters.  This
%       includes the inputFile and the outputFile, which are used to find the
%       directories containing all of the pbrt scene data.
%Return
%    obj: Objects information(Position,
%                             material assigned,...)
%
% Zhenyi, 2018
%%
p = inputParser;
p.addRequired('renderRecipe',@(x)isequal(class(x),'recipe'));
%% Check version number
if(renderRecipe.version ~= 3)
    error('Only PBRT version 3 Cinema 4D exporter is supported.');
end
%% give a geometry.pbrt
%
[Filepath,scene_fname] = fileparts(renderRecipe.inputFile);
fname = fullfile(Filepath,sprintf('%s_geometry.pbrt',scene_fname));
% save output obj struct to scenename.json file
AssetInfo = fullfile(Filepath,sprintf('%s.json',scene_fname));
%% open it
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n');
txtLines = tmp{1};
fclose(fileID);
% with indent
fileID = fopen(fname);
tmp_indent = textscan(fileID, '%s', 'delimiter', '\n', 'whitespace', '');
txtLines_indent = tmp_indent{1};
fclose(fileID);
%% Check flag-- if the geometry is converted by us
if contains(txtLines(1),'# PBRT geometry file converted from C4D exporter output')
    convertedflag = true;
else
    convertedflag = false;
end

if ~convertedflag
    %% Check if a nested structure is exsited:
    % if exsited
    % Check pattern in names
    % obj.child = obj;
    % else
    % obj = obj
    % Find AttributeBegin/End Line Number.
    kk = 1; gg=1;
    for nn = 1: length(txtLines_indent)
        if isequal(txtLines_indent{nn}, 'AttributeBegin')
            nestbegin(kk) = nn;
            kk = kk+1;
        elseif isequal(txtLines_indent{nn}, 'AttributeEnd')
            nestend(gg) = nn;
            gg=gg+1;
        end
    end
    %%
    disp('Starting...')
    %% Extract objects information and write out child objects
    
    hh = 1;
    for dd = 1:length(nestbegin)
        ll = 1; jj = 1;
        for ii = nestbegin(dd): nestend(dd)
            % Find the name of a grouped object
            if contains(txtLines{nestbegin(dd)+1}, "#ObjectName ")
                GroupObj_name_tmp = erase(txtLines{nestbegin(dd)+1},"#ObjectName ");
                index = strfind(GroupObj_name_tmp, ':');
                Groupobj_name = GroupObj_name_tmp(1:(index-1));
                Groupobj_size = GroupObj_name_tmp((index+8):end);
                Groupobj_size = erase(Groupobj_size, ')');
                size_num = str2num(Groupobj_size);
                % size
                groupobj(hh).size.l = size_num(1);
                groupobj(hh).size.h = size_num(2);
                groupobj(hh).size.w = size_num(3);
                groupobj(hh).size.pmin = [-size_num(1)/2 -size_num(3)/2];
                groupobj(hh).size.pmax = [size_num(1)/2 size_num(3)/2];
                
                %         %
                %         Groupobj(hh).center = mean(Groupobj(hh).box);
                groupobj(hh).name = sprintf('%s',Groupobj_name);
                if contains(txtLines{nestbegin(dd)+2}, "ConcatTransform")
                    tmp = txtLines{nestbegin(dd)+2};
                    tmp  = textscan(tmp, '%s [%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
                    values = cell2mat(tmp(2:end));
                    transform = reshape(values,[4 4]);
                    %             Groupobj(hh).concattransform.x = transform(1:4);
                    %             Groupobj(hh).concattransform.y = transform(5:8);
                    %             Groupobj(hh).concattransform.z = transform(9:12);
                    %                     groupobj(hh).translate = transform(13:15);
                    groupobj(hh).rotate    = [0 0 0 0];
                    groupobj(hh).position = transform(13:15);
                    % Add type of the object, get it from the file name,
                    % could be wrong, but this is how we named the object
                else
                    groupobj(hh).rotate    = [0 0 0 0];
                    groupobj(hh).position = [0 0 0];
                end
                
            end
            % find child objects
            
            if contains(txtLines(ii),'Shape')
                obj(jj).index = ii;
                % Name is created by a pattern: '#ObjectName' + 'objname' + ':' +'Vector' + '(width(x), height(y), lenght(z))'
                % Check if concattranform is contained in a child attribute.
                if contains(txtLines(ii-1),':Vector(')
                    name = erase(txtLines(ii-1),"#ObjectName ");
                elseif contains(txtLines(ii-3),':Vector(')
                    name = erase(txtLines(ii-3),"#ObjectName ");
                elseif contains(txtLines(ii-4),':Vector(')
                    name = erase(txtLines(ii-4),"#ObjectName ");
                else
                    name = erase(txtLines(obj(jj-1).index-4),"#ObjectName ");
                end
                name = name{1};
                index = strfind(name, ':');
                obj_name = name(1:(index-1));
                %             obj_size = name((index+8):end);
                %             obj_size = erase(obj_size, ')');
                %             obj(jj).size = obj_size;
                %             pmin = [0, 0, 0]; % local
                %             pmax = str2num(obj(jj).size);
                %             obj(jj).box  = [pmin;pmax];
                %             obj(jj).center = mean(obj(jj).box);
                obj(jj).name = sprintf('%d_%s',jj,groupobj(hh).name);
                % for the case there is no material assigned.
                if contains(txtLines(ii-1),'NamedMaterial')
                    obj(jj).material = sprintf('%s',cell2mat(txtLines(ii-1)));
                end
                % save obj to a pbrt file
                output_name = sprintf('%s.pbrt', obj(jj).name);
                output_folder = sprintf(fullfile(Filepath,'scene','PBRT','pbrt-geometry'));
                output = fullfile('scene','PBRT','pbrt-geometry',output_name);
                obj(jj).output = output;
                %             if contains(txtLines(ii-3),'ConcatTransform')
                %                 obj(jj).concattransform = txtLines{ii-3};
                %             end
                if ~exist(output_folder,'dir')
                    mkdir(output_folder);
                end
                outputFile = fullfile(Filepath,output);
                fid = fopen(outputFile,'w');
                fprintf(fid,'# %s\n',obj(jj).name);
                currLine = cell2mat(txtLines(ii));
                % Find 'integer indices'
                integer = strfind(currLine,'"integer indices"');
                point = strfind(currLine, '"point P"');
                normal = strfind(currLine, '"normal N"');
                fprintf(fid,'%s\n',currLine(1:(integer-1)));
                fprintf(fid,'  %s\n',currLine(integer:(point-1)));
                fprintf(fid,'  %s\n',currLine(point:(normal-1)));
                fprintf(fid,'  %s\n',currLine(normal:end));
                fclose(fid);
                groupobj(hh).child(ll) = obj(jj);jj= jj+1;ll=ll+1;
                
            end
        end
        fprintf('Object:%s has %d child object(s) \n',groupobj(hh).name,jj-1);hh = hh+1;
    end
    renderRecipe.assets = groupobj;
    jsonwrite(AssetInfo,renderRecipe);
    disp('All done.');
else
    
    renderRecipe_tmp = jsonread(AssetInfo);
    fds = fieldnames(renderRecipe_tmp);
    renderRecipe = recipe;
    % assign the struct to a recipe class
    for dd = 1:length(fds)
        renderRecipe.(fds{dd})= renderRecipe_tmp.(fds{dd});
    end
    groupobj = renderRecipe.assets;
end
end

