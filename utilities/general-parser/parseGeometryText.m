function [trees, parsedUntil] = parseGeometryText(thisR, txt, name)
%
% Inputs:
%   thisR       - a scene recipe
%   txt         - remaining text to parse
%   name        - current object name
%
% Outputs:
%   trees       - A tree class that describes the assets and their geometry
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
    % ZLY: an emergency patch for Brian's presentation tomorrow If we found
    % ObjectBegin, that means we won't parse anything
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
        i =  i + retLine;
        
    elseif piContains(currentLine,'#ObjectName')
        [name, sz] = piParseObjectName(currentLine);
        
    elseif piContains(currentLine,'ConcatTransform') 
        % [rot, translation, ctform] = piParseConcatTransform(currentLine);
        [translation, rot, scale] = parseTransform(currentLine);
    elseif strncmp(currentLine,'Transform ',10)
        % ctform = [];
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
            lght{end+1} = currentLine; %#ok<AGROW>
        end
        
    elseif piContains(currentLine,'Shape')
        shape = piParseShape(currentLine);
    elseif strcmp(currentLine,'AttributeEnd')
               
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
            % This is a branch or an object

            if exist('shape','var') || exist('mediumInterface','var') || exist('mat','var')
                % This path if it is an object
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
                            % We need a way to assign a name to this
                            % object.  We want them unique.  So for now, we
                            % just pick a random number.  Some chance of a
                            % duplicate, but not much.
                            
                            resObject.name = sprintf('%s-%d_O',mat.namedmaterial,randi(1e6,1));                            
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
            
            % This path if it is a 'branch' node
            if exist('rot','var') || exist('translation','var')                
                resCurrent = piAssetCreate('type', 'branch');
                
                % If present populate fields.
                if exist('name','var'), resCurrent.name = sprintf('%s_B', name); end
                if exist('sz','var'), resCurrent.size = sz; end
                if exist('rot','var'), resCurrent.rotation = rot; end
                if exist('translation','var'), resCurrent.translation = translation; end
                if exist('scale','var'), resCurrent.scale = scale; end
                
                trees = tree(resCurrent);
                for ii = 1:numel(subtrees)
                    % TODO: solve the empty node name problem here
                    trees = trees.graft(1, subtrees(ii));
                end
            end

        elseif exist('name','var')
            % Create a branch, add it to the main tree.
            resCurrent = piAssetCreate('type', 'branch');
            if exist('name','var'), resCurrent.name = sprintf('%s_B', name); end            
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

% We build the main tree from any defined subtrees.  Each subtree is an
% asset.
if ~isempty(subtrees)
    trees = tree('root');
    % Add each of the subtrees to the root
    for ii = 1:numel(subtrees)
        trees = trees.graft(1, subtrees(ii));
    end
else
    trees=[];
end

end

