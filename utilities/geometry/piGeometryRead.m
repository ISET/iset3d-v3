function renderRecipe = piGeometryRead(renderRecipe)
%% Read a C4d geometry file and extract object information into a recipe
%
% Syntax:
%   renderRecipe = piGeometryRead(renderRecipe)
%
% Input
%   renderRecipe:  an iset3d recipe object describing the rendering
%     parameters.  This includes the inputFile and the outputFile,
%     which are used to find the  directories containing all of the
%     pbrt scene data.
%
%Return
%    renderRecipe - Updated by the processing in this function
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

% Best practice is to initalize the ouputFile.  Sometimes people
% don't.  So we do this as the default behavior.
[inFilepath, scene_fname] = fileparts(renderRecipe.inputFile);
inputFile = fullfile(inFilepath,sprintf('%s_geometry.pbrt',scene_fname));

% Save the JSON file at AssetInfo
% outputFile  = renderRecipe.outputFile;
outFilepath = fileparts(renderRecipe.outputFile);
AssetInfo   = fullfile(outFilepath,sprintf('%s.json',scene_fname));

%% Open the geometry file

% Read all the text in the file.  Read this way the text indents are
% ignored.
fileID = fopen(inputFile);
tmp = textscan(fileID,'%s','Delimiter','\n');
txtLines = tmp{1};
fclose(fileID);

% Read it again, but this time with indents preserved
fileID = fopen(inputFile);
tmp_indent = textscan(fileID, '%s', 'delimiter', '\n', 'whitespace', '');
txtLines_indent = tmp_indent{1};
fclose(fileID);

%% Check whether the geometry have already been converted from C4D

% If it was converted, we don't need to do much work.
if piContains(txtLines(1),'# PBRT geometry file converted from C4D exporter output')
    convertedflag = true;
else
    convertedflag = false;
end

if ~convertedflag
    %% It was not converted, so we go to work.
    % Check if a nested structure is exists
    
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
    disp('piGeometryRead starting...')
    
    %% Extract objects information and write out children objects
    
    hh = 1;
    for dd = 1:length(nestbegin)
        ll = 1; jj = 1;
        for ii = nestbegin(dd): nestend(dd)
            % Find the name of a grouped object
            if piContains(txtLines{nestbegin(dd)+1}, '#ObjectName ')
                GroupObj_name_tmp = erase(txtLines{nestbegin(dd)+1},'#ObjectName ');
                index = strfind(GroupObj_name_tmp, ':');
                Groupobj_name = GroupObj_name_tmp(1:(index-1));
                Groupobj_size = GroupObj_name_tmp((index+8):end);
                Groupobj_size = erase(Groupobj_size, ')');
                size_num = str2num(Groupobj_size);
                
                % size
                groupobj(hh).size.l = size_num(1)*2;
                groupobj(hh).size.h = size_num(2)*2;
                groupobj(hh).size.w = size_num(3)*2;
                groupobj(hh).size.pmin = [-size_num(1) -size_num(3)];
                groupobj(hh).size.pmax = [size_num(1) size_num(3)];
                
                % Always add a scaling factor
                groupobj(hh).scale = [1;1;1];
                
                groupobj(hh).name = sprintf('%s',Groupobj_name);
                if piContains(txtLines{nestbegin(dd)+2}, 'ConcatTransform')
                    tmp = txtLines{nestbegin(dd)+2};
                    tmp  = textscan(tmp, '%s [%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
                    values = cell2mat(tmp(2:end));
                    transform = reshape(values,[4,4]);
                    dcm = [transform(1:3);transform(5:7);transform(9:11)];
                    
                    [rotz,roty,rotx]= piDCM2angle(dcm);
                    rotx = rotx*180/pi;
                    roty = roty*180/pi;
                    rotz = rotz*180/pi;
                    
                    groupobj(hh).rotate(:,3)   = [rotx;1;0;0];
                    groupobj(hh).rotate(:,2)   = [roty;0;1;0];
                    groupobj(hh).rotate(:,1)   = [rotz;0;0;1];
                    groupobj(hh).position = reshape(transform(13:15),[3,1]);
                    % Add type of the object, get it from the file name,
                    % could be wrong, but this is how we named the object
                else
                    groupobj(hh).rotate(:,3) = [0;1;0;0];
                    groupobj(hh).rotate(:,2) = [0;0;1;0];
                    groupobj(hh).rotate(:,1) = [0;0;0;1];
                    groupobj(hh).position = [0;0;0];
                end
                
                
            end
            % find children objects
            
            if piContains(txtLines(ii),'Shape')
                obj(jj).index = ii;
                % Name is created by a pattern: '#ObjectName' + 'objname' + ':' +'Vector' + '(width(x), height(y), lenght(z))'
                % Check if concattranform is contained in a children attribute.
                if piContains(txtLines(ii-1),':Vector(')
                    name = erase(txtLines(ii-1),'#ObjectName ');
                elseif piContains(txtLines(ii-2),':Vector(')
                    name = erase(txtLines(ii-3),'#ObjectName ');
                elseif piContains(txtLines(ii-3),':Vector(')
                    name = erase(txtLines(ii-3),'#ObjectName ');
                elseif piContains(txtLines(ii-4),':Vector(')
                    name = erase(txtLines(ii-4),'#ObjectName ');
                else
                    name = erase(txtLines(obj(jj-1).index-4),'#ObjectName ');
                end
                name = name{1};
                index = strfind(name, ':');
                obj_name = name(1:(index-1));
                obj(jj).name = sprintf('%d_%s',jj,groupobj(hh).name);
                
                if piContains(txtLines(ii-2),'MediumInterface')
                    obj(jj).mediumInterface = sprintf('%s',cell2mat(txtLines(ii-2)));
                else
                    obj(jj).mediumInterface = [];
                end
                if piContains(txtLines(ii-1),'NamedMaterial')
                    obj(jj).material = sprintf('%s',cell2mat(txtLines(ii-1)));
                else
                    obj(jj).material = [];
                end
                
                % save obj to a pbrt file
                output_name = sprintf('%s.pbrt', obj(jj).name);
                output_folder = fullfile(outFilepath,'scene','PBRT','pbrt-geometry');
                outputGeometry = fullfile('scene','PBRT','pbrt-geometry',output_name);
                fprintf('piGeometryRead: Saving geometry file %s.\n',outputGeometry);

                obj(jj).output = outputGeometry;

                if ~exist(output_folder,'dir')
                    mkdir(output_folder);
                end
                
                outputFileGeometry = fullfile(output_folder,output_name);
                
                fid = fopen(outputFileGeometry,'w');
                fprintf(fid,'# %s\n',obj(jj).name);
                currLine = cell2mat(txtLines(ii));
                
                % Find 'integer indices', point P, normal N and put
                % them in their own geometry file.  We write the data
                % here.
                integer = strfind(currLine,'"integer indices"');
                point = strfind(currLine, '"point P"');
                normal = strfind(currLine, '"normal N"');
                texturemap = strfind(currLine, '"float uv"');
                fprintf(fid,'%s\n',currLine(1:(integer-1)));
                fprintf(fid,'  %s\n',currLine(integer:(point-1)));
                fprintf(fid,'  %s\n',currLine(point:(normal-1)));
                fprintf(fid,'  %s\n',currLine(normal:(texturemap-1)));
                fprintf(fid,'  %s\n',currLine(texturemap:end));
                fclose(fid);
                groupobj(hh).children(ll) = obj(jj);jj= jj+1;ll=ll+1;
                
            end
        end
        fprintf('Object:%s has %d children object(s) \n',groupobj(hh).name,jj-1);
        hh = hh+1;
    end
    
    % Save the render recipe, which can save us a lot of time in the
    % future.  The next time through, use the JSON file, which then
    % passes this function to the else condition.
    renderRecipe.assets = groupobj;
    jsonwrite(AssetInfo,renderRecipe);
    fprintf('piGeometryRead done.\nSaving render recipe as a JSON file %s.\n',AssetInfo);
    
else
    % The converted flag is true, so AssetInfo is already stored in a
    % JSON file with the recipe information.  We just copy it into the
    % recipe.
    renderRecipe_tmp = jsonread(AssetInfo);
    
    % There may be a utility that accomplishes this.  We should find
    % it and use it here.
    fds = fieldnames(renderRecipe_tmp);
    renderRecipe = recipe;
    
    % Assign the each field in the struct to a recipe class
    for dd = 1:length(fds)
        renderRecipe.(fds{dd})= renderRecipe_tmp.(fds{dd});
    end
    
end

end

