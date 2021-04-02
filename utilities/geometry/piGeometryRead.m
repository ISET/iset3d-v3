function thisR = piGeometryRead(thisR)
% Read a C4d geometry file and extract object information into a recipe
%
% Syntax:
%   renderRecipe = piGeometryRead(renderRecipe)
%
% Input
%   renderRecipe:  an iset3d recipe object describing the rendering
%     parameters.  This object includes the inputFile and the
%     outputFile, which are used to find the  directories containing
%     all of the pbrt scene data.
%
% Return
%    renderRecipe - Updated by the processing in this function
%
% Zhenyi, 2018
% Henryk Blasinski 2020
%
% Description
%   This includes a bunch of sub-functions and a logic that needs further
%   description.
%
% See also
%   piGeometryWrite

%%
p = inputParser;
p.addRequired('thisR',@(x)isequal(class(x),'recipe'));

%% Check version number
if(thisR.version ~= 3)
    error('Only PBRT version 3 Cinema 4D exporter is supported.');
end

%% give a geometry.pbrt

% Best practice is to initalize the ouputFile.  Sometimes peopleF
% don't.  So we do this as the default behavior.
[inFilepath, scene_fname] = fileparts(thisR.inputFile);
inputFile = fullfile(inFilepath,sprintf('%s_geometry.pbrt',scene_fname));
%% Open the geometry file

% Read all the text in the file.  Read this way the text indents are
% ignored.
fileID = fopen(inputFile);
tmp = textscan(fileID,'%s','Delimiter','\n');
txtLines = tmp{1};
fclose(fileID);

%% Check whether the geometry have already been converted from C4D

% If it was converted into ISET3d format, we don't need to do much work.

% It was not converted, so we go to work.
thisR.assets = parseGeometryText(thisR, txtLines,'');

% jsonwrite(AssetInfo,renderRecipe);
% fprintf('piGeometryRead done.\nSaving render recipe as a JSON file %s.\n',AssetInfo);


%{
    % The converted flag is true, so AssetInfo is already stored in a
    % JSON file with the recipe information.  We just copy it isnto the
    % recipe.
    % Save the JSON file at AssetInfo
    % outputFile  = renderRecipe.outputFile;
    outFilepath = fileparts(thisR.outputFile);
    AssetInfo   = fullfile(outFilepath,sprintf('%s.json',scene_fname));
    renderRecipe_tmp = jsonread(AssetInfo);
    
    % There may be a utility that accomplishes this.  We should find
    % it and use it here.
    fds = fieldnames(renderRecipe_tmp);
    thisR = recipe;
    
    % Assign the each field in the struct to a recipe class
    for dd = 1:length(fds)
        thisR.(fds{dd})= renderRecipe_tmp.(fds{dd});
    end
%}



%% Make the node name unique
[thisR.assets, ~] = thisR.assets.uniqueNames;
end

%%
%
function [trees, parsedUntil] = parseGeometryText(thisR, txt, name)
%
% Inputs:
%
%   txt         - remaining text to parse
%   name        - current object name
%
% Outputs:
%   res         - struct of results
%   children    - Attributes under the current object
%   parsedUntil - line number of the parsing end
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

i = 1;
while i <= length(txt)
    
    currentLine = txt{i};
    
    % Return if we've reached the end of current attribute
    
    if strcmp(currentLine,'AttributeBegin')
        % This is an Attribute inside an Attribute
        [subnodes, retLine] = parseGeometryText(thisR, txt(i+1:end), name);
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
        [rot, translation, ctform] = piParseConcatTransform(currentLine);
        
    elseif piContains(currentLine,'MediumInterface')
        % MediumInterface could be water or other scattering media.
        medium = currentLine;
        
    elseif piContains(currentLine,'NamedMaterial')
        mat = piParseGeometryMaterial(currentLine);
        
    elseif piContains(currentLine,'Matieral') 
        % in case there is no NamedMaterial
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

        elseif exist('rot','var') || exist('translation','var')
           % This is a 'branch' node
           
            % resCurrent = createGroupObject();
            resCurrent = piAssetCreate('type', 'branch');
            
            % If present populate fields.
            if exist('name','var'), resCurrent.name = sprintf('%s_B', name); end
            if exist('sz','var'), resCurrent.size = sz; end
            if exist('rot','var'), resCurrent.rotation = rot; end
            if exist('ctform','var'), resCurrent.concattransform = ctform; end
            if exist('translation','var'), resCurrent.translation = translation; end
            
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
            
        elseif exist('shape','var') || exist('mediumInterface','var') || exist('mat','var')
            % resChildren = createGeometryObject();
            resObject = piAssetCreate('type', 'object');
            if exist('name','var')
                % resObject.name = sprintf('%d_%d_%s',i, numel(subtrees)+1, name); 
                resObject.name = sprintf('%s_O', name);
            end

            if exist('shape','var'), resObject.shape = shape; end
            
            if exist('mat','var')
                resObject.material = mat; 
            end
            if exist('medium','var')
                resObject.medium = medium; 
            end
            
            subtrees = cat(1, subtrees, tree(resObject));
            trees = subtrees;
           
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

%{
res = createGroupObject();
res.name = 'root';
res.groupobjs = groupobjs;
res.children = children;
%}
trees = tree('root');
for ii = 1:numel(subtrees)
    trees = trees.graft(1, subtrees(ii));
end
parsedUntil = i;

end
