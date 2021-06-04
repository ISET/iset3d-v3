function [materialMap, textureMap, txtLines] = parseMaterialTexture(txtLines)
% Parse the txtLines to specify the materials and textures
%
% Synopsis
%
%   [materialMap, textureMap, txtLines] = parseMaterialTexture(txtLines)
%
% Input
%   txtLines - Usually thisR.world text
%
% Outputs
%   materialMap - The material key-value pairs map
%   textureMap  - The texture key-value pairs map
%   txtLines     -  The txtLines that are NOT material or textures
%
% ZL and ZYL
%
% See also
%

%% Initialize the parameters we return

textureList    = [];
materialList  = [];

% Counters for the textures and materials
t_index = 0;
m_index = 0;
% map for textures and materials
textureMap  = containers.Map;
materialMap = containers.Map;
%% Loop over each line
for ii = numel(txtLines):-1:1
    % From the end to the beginning so we don't screw up line ordering.
    
    % Parse this line now
    thisLine = txtLines{ii};
    
    if strncmp(thisLine,'Texture',length('Texture'))
        t_index = t_index+1;
        textureList{t_index}   = parseBlockTexture(thisLine);  %#ok<AGROW>'
        textureMap(textureList{t_index}.name) = textureList{t_index};
        txtLines(ii) = [];
        
    elseif strncmp(thisLine,'MakeNamedMaterial',length('MakeNamedMaterial')) ||...
            strncmp(thisLine,'Material',length('Material'))
        m_index = m_index+1;
        materialList{m_index}  = parseBlockMaterial(thisLine); %#ok<AGROW>
        materialMap(materialList{m_index}.name) = materialList{m_index};
        txtLines(ii) = [];

    end
end

end