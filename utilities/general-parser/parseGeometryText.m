function [trees, parsedUntil] = parseGeometryText(thisR, txt, name)
%
% Inputs:
%   thisR       - a scene recipe
%   txt         - remaining text to parse
%   name        - current object name
%
% Outputs:
%   trees       - struct of results
%   parsedUntil - line number where the parsing ends
%
% Description:
%
%   The geometry text comes from C4D export. We parse the lines of text in
%   'txt' cell array and recrursively create a tree structure of geometric objects.
%
%   Logic explanation:
%   parseGeometryText will recursively parse the geometry text line by
%   line. If current text is:
%       a) 'AttributeBegin': this is the beginning of a section. We will
%       keep looking for node/object/light information until we reach the
%       'AttributeEnd'.
%       b) Node/object/light information: this could contain rotation,
%       position, scaling, shape, material properties, light spectrum
%       information. Upon seeing the information, parameters will be
%       created to store the value.
%       c) 'AttributeEnd': this is the end of a section. Depending on
%       parameters in this section, we will create different nodes and make
%       them as trees. Noted the 'branch' node will have children for sure,
%       so we assumed that before reaching the end of 'branch' seciton, we
%       already have some children, so we need to attach them under the
%       'branch'. 'Ojbect' and 'Light', on the other hand will have no child
%       as they will be children leaves. So we simply create leave nodes
%       for them and return.

% res = [];
% groupobjs = [];
% children = [];
subtrees = {};

i = 1;         objectIndex = 0;
while i <= length(txt)
    
    currentLine = txt{i};
    % ZLY: an emergent patch up for Brian's presentation tomorrow
    % If we found ObjectBegin, that means we won't parse anything
    if piContains(currentLine, 'ObjectBegin')
        trees = {};
        parsedUntil = i;
        return;
    end
    
    % Return if we've reached the end of current attribute
    
    if strcmp(currentLine,'AttributeBegin')
        % This is an Attribute inside an Attribute
        [subnodes, retLine] = parseGeometryText(thisR, txt(i+1:end), name);
        
        % Add object index: index_objectname_O
        if strcmp(subnodes.Node{1}.type, 'object')
            objectIndex = objectIndex+1;
            thisNode = subnodes.Node{1};
            thisNode.name = sprintf('%03d_%s',objectIndex, thisNode.name);
            subnodes = subnodes.set(1, thisNode);
        end
        
        subtrees = cat(1, subtrees, subnodes);

        %{
        groupobjs = cat(1, groupobjs, subnodes);
        
        
        % Give an index to the subchildren to make it different from its
        % parents and brothers (we are not sure if it works for more than
        % two levels). We name the subchildren based on the line number and
        % how many subchildren there are already.
        if ~isempty(subchildren)
            subchildren.name = sprintf('%d_%d_%s', i, numel(children)+1, subchildren.name);
        end
        children = cat(1, children, subchildren);
        %}
        %         assets = cat(1, assets, subassets);
        i =  i + retLine;
        
    elseif piContains(currentLine,'#ObjectName')
        [name, sz] = piParseObjectName(currentLine);
        
    elseif piContains(currentLine,'ConcatTransform') 
%         [rot, translation, ctform] = piParseConcatTransform(currentLine);
        [translation, rot, scale] = parseTransform(currentLine);
    elseif strncmp(currentLine,'Transform ',10)
%         ctform = [];
        [translation, rot, scale] = parseTransform(currentLine);
    elseif piContains(currentLine,'MediumInterface')
        % MediumInterface could be water or other scattering media.
        medium = currentLine;
        
    elseif piContains(currentLine,'NamedMaterial')
        mat = piParseGeometryMaterial(currentLine);
        
    elseif piContains(currentLine,'Material')
        mat = parseBlockMaterial(currentLine);
        
    elseif piContains(currentLine,'AreaLightSource')
        areaLight = currentLine;
        
    elseif piContains(currentLine,'LightSource') ||...
            piContains(currentLine, 'Rotate') ||...
            piContains(currentLine, 'Scale')
        % Usually light source contains only one line. Exception is there
        % are rotations or scalings
        if ~exist('lght','var')
            lght{1} = currentLine;
        else
            lght{end+1} = currentLine;
        end
        
    elseif piContains(currentLine,'Shape')
        shape = piParseShape(currentLine);
    elseif strcmp(currentLine,'AttributeEnd')
        
        % Assemble all the read attributes into either a groub object, or a
        % geometry object. Only group objects can have subnodes (not
        % children). This can be confusing but is somewhat similar to
        % previous representation.
        
        % More to explain this long if-elseif-else condition:
        %   First check if this is a light/arealight node. If so, parse the
        %   parameters.
        %   If it is not a light node, then we consider if it is a node
        %   node which records some common translation and rotation.
        %   Else, it must be an object node which contains material info
        %   and other things.
        
        if exist('areaLight','var') || exist('lght','var')
            % This is a 'light' node
            resLight = piAssetCreate('type', 'light');
            if exist('lght','var')
                % Wrap the light text into attribute section
                lghtWrap = [{'AttributeBegin'}, lght(:)', {'AttributeEnd'}];
                resLight.lght = piLightGetFromText(lghtWrap, 'print', false);
            end
            if exist('areaLight','var')
                resLight.lght = piLightGetFromText({areaLight}, 'print', false);
                
                if exist('shape', 'var')
                    resLight.lght{1}.shape = shape;
                end
                
                if exist('rot', 'var')
                    resLight.lght{1}.rotate = rot;
                end
                if exist('ctform', 'var')
                    resLight.lght{1}.concattransform = ctform;
                end                
                if exist('translation', 'var')
                    resLight.lght{1}.translation = translation;
                end
                
            end
            
            if exist('name', 'var'), resLight.name = sprintf('%s_L', name); end
            
            subtrees = cat(1, subtrees, tree(resLight));
            trees = subtrees;
            
        elseif exist('rot','var') || exist('translation','var') || ...
                exist('shape','var') || exist('mediumInterface','var') || exist('mat','var')
            if exist('shape','var') || exist('mediumInterface','var') || exist('mat','var')
                % resChildren = createGeometryObject();
                resObject = piAssetCreate('type', 'object');
                if exist('name','var')
                    resObject.name = sprintf('%s_O', name);
                    
                    % This was prepared for empty object name case.
                    
                    % If we parse a valid name already, do this. 
                    if ~isempty(name)
                        
                        % resObject.name = sprintf('%d_%d_%s',i, numel(subtrees)+1, name);
                        resObject.name = sprintf('%s_O', name);
                        
                    % Otherwise we set the role of assigning object name in
                    % with priority:
                    %   (1) Check if ply file exists
                    %   (2) Check if named material exists
                    %   (3) (Worst case) Only material type exists
                    else
                        if ~isempty(shape.filename)
                            [~, n, ~] = fileparts(shape.filename);
                            
                            % If there was a '_mat0' added to the object 
                            % name, remove it.
                            if contains(n,'_mat0')
                                n = erase(n,'_mat0');
                            end
                            
                            resObject.name = sprintf('%s_O', n);
                        elseif ~isempty(mat)
                            if ~isempty(mat.name)
                                warning('An object has been created with its material name: %s', mat.name)
                                resObject.name = sprintf('%s_O', mat.name);
                            else
                                warning('An object has been created with its material type: %s', mat.type)
                                resObject.name = sprintf('%s_O', mat.type);
                            end
                        end
                    end

                end
                
                if exist('shape','var')
                    resObject.shape = shape;
                end
                
                if exist('mat','var')
                    resObject.material = mat;
                end
                if exist('medium','var')
                    resObject.medium = medium;
                end
                
                subtrees = cat(1, subtrees, tree(resObject));
                trees = subtrees;
            end
            % This is a 'branch' node
            if exist('rot','var') || exist('translation','var')
                % resCurrent = createGroupObject();
                resCurrent = piAssetCreate('type', 'branch');
                
                % If present populate fields.
                if exist('name','var'), resCurrent.name = sprintf('%s_B', name); end
                if exist('sz','var'), resCurrent.size = sz; end
                if exist('rot','var'), resCurrent.rotation = rot; end
%                 if exist('ctform','var'), resCurrent.concattransform = ctform; end
                if exist('translation','var'), resCurrent.translation = translation; end
                if exist('scale','var'), resCurrent.scale = scale; end
                
                %{
                resCurrent.groupobjs = groupobjs;
                resCurrent.children = children;
                children = [];
                res = cat(1,res,resCurrent);
                %}
                trees = tree(resCurrent);
                for ii = 1:numel(subtrees)
                    % TODO: solve the empty node name problem here
                    trees = trees.graft(1, subtrees(ii));
                end
            end

        elseif exist('name','var')
            % resCurrent = createGroupObject();
            resCurrent = piAssetCreate('type', 'branch');
            if exist('name','var'), resCurrent.name = sprintf('%s_B', name); end
            
            %{
            resCurrent.groupobjs = groupobjs;
            resCurrent.children = children;
            children = [];
            res = cat(1,res,resCurrent);
            %}
            trees = tree(resCurrent);
            for ii = 1:numel(subtrees)
                trees = trees.graft(1, subtrees(ii));
            end
        end
        
        parsedUntil = i;
        return;
        
    else
       %  warning('Current line skipped: %s', currentLine); 
    end
    i = i+1;
end
parsedUntil = i;
%{
res = createGroupObject();
res.name = 'root';
res.groupobjs = groupobjs;
res.children = children;
%}
if ~isempty(subtrees)
    trees = tree('root');
    for ii = 1:numel(subtrees)
        trees = trees.graft(1, subtrees(ii));
    end
else
    trees=[];
end

end

function newMat = parseMaterial(curreline)

thisLine = strsplit(curreline, {' "', '" ', '"'});
thisLine = thisLine(~cellfun('isempty',thisLine));

% Create a new material
matName = ''; % Material name
matType = thisLine{2}; % Material type
newMat = piMaterialCreate(matName, 'type', matType);


% For strings 3 to the end, parse
for ss = 3:2:numel(thisLine)
    % Get parameter type and name
    keyTypeName = strsplit(thisLine{ss}, ' ');
    keyType = ieParamFormat(keyTypeName{1});
    keyName = ieParamFormat(keyTypeName{2});
    
    % Some corner cases
    % "index" should be replaced with "eta"
    switch keyName
        case 'index'
            keyName = 'eta';
    end
    
    switch keyType
        case {'string', 'texture'}
            thisVal = thisLine{ss + 1};
        case {'float', 'rgb', 'color', 'photolumi'}
            % Parse a float number from string
            % str2num can convert string to vector. str2double can't.
            thisVal = str2num(thisLine{ss + 1});
        case {'spectrum'}
            [~, ~, e] = fileparts(thisLine{ss + 1});
            if isequal(e, '.spd')
                % Is a file
                thisVal = thisLine{ss + 1};
            else
                % Is vector
                thisVal = str2num(thisLine{ss + 1});
            end
        case 'bool'
            if isequal(thisLine{ss + 1}, 'true')
                thisVal = true;
            elseif isequal(thisLine{ss + 1}, 'false')
                thisVal = false;
            end
        otherwise
            warning('Could not resolve the parameter type: %s', keyType);
            continue;
    end
    
    newMat = piMaterialSet(newMat, sprintf('%s value', keyName),...
        thisVal);
end
end