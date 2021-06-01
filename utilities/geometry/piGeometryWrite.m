function  piGeometryWrite(thisR,varargin)
% Write out a geometry file that matches the format and labeling objects
%
% Synopsis
%   piGeometryWrite(thisR,varargin)
%
% Input:
%       thisR: a render recipe
%       obj:   Returned by piGeometryRead, contains information about objects.
%
% Optional key/value pairs
%
% Output:
%       None for now.
%
% Description
%   We need a better description of objects and groups here.  Definitions
%   of 'assets'.
%
% Zhenyi, 2018
%
% See also
%   piGeometryRead
%
%%
p = inputParser;

% varargin =ieParamFormat(varargin);

p.addRequired('thisR',@(x)isequal(class(x),'recipe'));
% default is flase, will turn on for night scene
% p.addParameter('lightsFlag',false,@islogical);
% p.addParameter('thistrafficflow',[]);

p.parse(thisR,varargin{:});

% These were used but seem to be no longer used
%
% lightsFlag  = p.Results.lightsFlag;
% thistrafficflow = p.Results.thistrafficflow;

%% Create the default file name

[Filepath,scene_fname] = fileparts(thisR.outputFile);
fname = fullfile(Filepath,sprintf('%s_geometry.pbrt',scene_fname));[~,n,e]=fileparts(fname);

% Get the assets from the recipe
obj = thisR.assets;

%% Wrote the geometry file.

fname_obj = fullfile(Filepath,sprintf('%s%s',n,e));

% Open and write out the objects
fid_obj = fopen(fname_obj,'w');
fprintf(fid_obj,'# Exported by piGeometryWrite on %i/%i/%i %i:%i:%f \n  \n',clock);

% Traverse the tree from root
rootID = 1;
% Write object and light definition in main geoemtry and children geometry
% file
if ~isempty(obj)
    recursiveWriteNode(fid_obj, obj, rootID, Filepath, thisR.outputFile);
    
    % Write tree structure in main geometry file
    lvl = 0;
    recursiveWriteAttributes(fid_obj, obj, rootID, lvl, thisR.outputFile);
else
    for ii = numel(thisR.world)
        fprintf(fid_obj, thisR.world{ii});
    end
end
fclose(fid_obj);
% Not sure we want this most of the time, can un-comment as needed
%fprintf('%s is written out \n', fname_obj);

end

function recursiveWriteNode(fid, obj, nodeID, rootPath, outFilePath)
% Define each object in geometry.pbrt file. This section writes out
% (1) Material for every object
% (2) path to each children geometry files which store the shape and other
%     geometry info.
%
% The process will be:
%   (1) Get the children of this node
%   (2) For each child, check if it is an 'object' or 'light' node. If so,
%   write it out.
%   (3) If the child is a 'branch' node, put it in a list which will be
%   recursively checked in next level.

%% Get children of thisNode
children = obj.getchildren(nodeID);

%% Loop through all children at this level
% If 'object' node, write out. If 'branch' node, put in the list

% Create a list for next level recursion
nodeList = [];

for ii = 1:numel(children)
    thisNode = obj.get(children(ii));
    % If node, put id in the nodeList
    if isequal(thisNode.type, 'branch')
        % do not write object instance repeatedly
        nodeList = [nodeList children(ii)];
          
        % Define object node
    elseif isequal(thisNode.type, 'object')
        while numel(thisNode.name) >= 8 &&...
                isequal(thisNode.name(5:6), 'ID')
            thisNode.name = thisNode.name(8:end);
        end
        fprintf(fid, 'ObjectBegin "%s"\n', thisNode.name);
        
        % Write out mediumInterface
        if ~isempty(thisNode.mediumInterface)
            fprintf(fid, strcat("MediumInterface ", '"', thisNode.mediumInterface, '" ','""', '\n'));
        end
        
        % Write out material
        if ~isempty(thisNode.material)
            %{
            % From dev branch
            if strcmp(thisNode.material,'none')
                fprintf(fid, strcat("Material ", '"none"', '\n'));
            else
                fprintf(fid, strcat("NamedMaterial ", '"',...
                            thisNode.material.namedmaterial, '"', '\n'));
            %}
            try
                fprintf(fid, strcat("NamedMaterial ", '"',...
                    thisNode.material.namedmaterial, '"', '\n'));
            catch
                materialTxt = piMaterialText(thisNode.material);
                fprintf(fid, strcat(materialTxt, '\n'));
            end
        end
        %{
            % I don't know what's this used for, but commenting here.
            if ~isempty(thisNode.output)
                % There is an output slot
                [~,output] = fileparts(thisNode.output);
                fprintf(fid, 'Include "scene/PBRT/pbrt-geometry/%s.pbrt" \n', output);
        %}
        if ~isempty(thisNode.shape)
            
            shapeText = piShape2Text(thisNode.shape);
            
            if ~isempty(thisNode.shape.filename)
                % If the shape has ply info, do this
                % Convert shape struct to text
                [~, ~, e] = fileparts(thisNode.shape.filename);
                if isequal(e, '.ply')
                    fprintf(fid, '%s \n',shapeText);
                else
                    % In this case it is a .pbrt file, we will write it
                    % out.
                    fprintf(fid, 'Include "%s" \n', thisNode.shape.filename);
                end
            else
                % If it does not have plt file, do this
                % There is a shape slot we also open the
                % geometry file.
                name = thisNode.name;
                geometryFile = fopen(fullfile(rootPath,'scene','PBRT','pbrt-geometry',sprintf('%s.pbrt',name)),'w');
                fprintf(geometryFile,'%s',shapeText);
                fclose(geometryFile);
                fprintf(fid, 'Include "scene/PBRT/pbrt-geometry/%s.pbrt" \n', name);
            end
        end
        
        fprintf(fid, 'ObjectEnd\n\n');
        
    elseif isequal(thisNode.type, 'light') || isequal(thisNode.type, 'marker') || isequal(thisNode.type, 'instance')
        % That's okay but do nothing.
    else
        % Something must be wrong if we get here.
        warning('Unknown node type: %s', thisNode.type)
    end
end

for ii = 1:numel(nodeList)
    recursiveWriteNode(fid, obj, nodeList(ii), rootPath, outFilePath);
end

end

function recursiveWriteAttributes(fid, obj, thisNode, lvl, outFilePath)
% Write attribute sections. The logic is:
%   1) Get the children of the current node
%   2) For each child, write out information accordingly
%
%% Get children of this node
children = obj.getchildren(thisNode);

%% Loop through children at this level

% Generate spacing to make the tree structure more beautiful
spacing = "";
for ii = 1:lvl
    spacing = strcat(spacing, "    ");
end

% indent spacing
indentSpacing = "    ";


for ii = 1:numel(children)
    thisNode = obj.get(children(ii));
    fprintf(fid, strcat(spacing, 'AttributeBegin\n'));
    
    if isequal(thisNode.type, 'branch')
        % get stripID for this Node
        while numel(thisNode.name) >= 8 &&...
                isequal(thisNode.name(5:6), 'ID')
            thisNode.name = thisNode.name(8:end);
        end
        % Write info
        fprintf(fid, strcat(spacing, indentSpacing,...
            sprintf('#ObjectName %s:Vector(%.5f, %.5f, %.5f)',thisNode.name,...
            thisNode.size.l,...
            thisNode.size.w,...
            thisNode.size.h), '\n'));
        % If a motion exists in the current object, prepare to write it out by
        % having an additional line below.
        if ~isempty(thisNode.motion)
            fprintf(fid, strcat(spacing, indentSpacing,...
                'ActiveTransform StartTime \n'));
        end
        
        % Translation
        
        % Rotation
        if ~isempty(thisNode.rotation)
            fprintf(fid, strcat(spacing, indentSpacing,...
                sprintf('Translate %.5f %.5f %.5f', thisNode.translation(1),...
                thisNode.translation(2),...
                thisNode.translation(3)), '\n'));
            fprintf(fid, strcat(spacing, indentSpacing,...
                sprintf('Rotate %.5f %.5f %.5f %.5f', thisNode.rotation(:, 1)), '\n'));
            fprintf(fid, strcat(spacing, indentSpacing,...
                sprintf('Rotate %.5f %.5f %.5f %.5f', thisNode.rotation(:, 2)), '\n'));
            fprintf(fid, strcat(spacing, indentSpacing,...
                sprintf('Rotate %.5f %.5f %.5f %.5f', thisNode.rotation(:, 3)), '\n'));
        else
            thisNode.concattransform(13:15) = thisNode.translation(:);
            fprintf(fid, strcat(spacing, indentSpacing,...
                sprintf('ConcatTransform [%.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f]', thisNode.concattransform(:)), '\n'));
        end
        % Scale
        fprintf(fid, strcat(spacing, indentSpacing,...
            sprintf('Scale %.5f %.5f %.5f', thisNode.scale), '\n'));
        
        % Write out motion
        if ~isempty(thisNode.motion)
            for jj = 1:size(thisNode.translation, 1)
                fprintf(fid, strcat(spacing, indentSpacing,...
                    'ActiveTransform EndTime \n'));
                if isempty(thisNode.motion.translation(jj, :))
                    fprintf(fid, strcat(spacing, indentSpacing,...
                        'Translate 0 0 0\n'));
                else
                    pos = thisNode.motion.translation(jj,:);
                    fprintf(fid, strcat(spacing, indentSpacing,...
                        sprintf('Translate %f %f %f', pos(1),...
                        pos(2),...
                        pos(3)), '\n'));
                end
                
                if isfield(thisNode.motion, 'rotation') && ~isempty(thisNode.motion.rotation)
                    rot = thisNode.motion.rotation;
                    
                    % Write out rotation
                    fprintf(fid, strcat(spacing, indentSpacing,...
                        sprintf('Rotate %f %f %f %f',rot(:,jj*3-2)), '\n')); % Z
                    fprintf(fid, strcat(spacing, indentSpacing,...
                        sprintf('Rotate %f %f %f %f',rot(:,jj*3-1)),'\n')); % Y
                    fprintf(fid, strcat(spacing, indentSpacing,...
                        sprintf('Rotate %f %f %f %f',rot(:,jj*3)), '\n'));   % X
                end
            end
        end
        
        recursiveWriteAttributes(fid, obj, children(ii), lvl + 1, outFilePath);
        
    elseif isequal(thisNode.type, 'object') || isequal(thisNode.type, 'instance')
        while numel(thisNode.name) >= 8 &&...
                isequal(thisNode.name(5:6), 'ID')
            % remove instance suffix
            endIndex = strfind(thisNode.name, '_I_');
            if ~isempty(endIndex)
                endIndex =endIndex-1;
            else
                endIndex = numel(thisNode.name);
            end
            thisNode.name = thisNode.name(8:endIndex);
        end
        fprintf(fid, strcat(spacing, indentSpacing, ...
            sprintf('ObjectInstance "%s"', thisNode.name), '\n'));

    elseif isequal(thisNode.type, 'light')
        % Create a tmp recipe
        tmpR = recipe;
        tmpR.outputFile = outFilePath;
        tmpR.lights = thisNode.lght;
        lightText = piLightWrite(tmpR, 'writefile', false);
        
        for jj = 1:numel(lightText)
            for kk = 1:numel(lightText{jj}.line)
                fprintf(fid,sprintf('%s%s%s\n',spacing, indentSpacing,...
                    sprintf('%s',lightText{jj}.line{kk})));
            end
        end
    else
        % Hopefully we never get here.
        warning('Unknown node type %s\n',thisNode.type);
    end
    
    
    fprintf(fid, strcat(spacing, 'AttributeEnd\n'));
end

end

