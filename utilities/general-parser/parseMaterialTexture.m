function [materialList, texureList, txtLines] = parseMaterialTexture(txtLines)
% Parse the txtLines to specify the materials and textures
%
% Synopsis
%
%   [materialList, texureList, txtLines] = parseMaterialTexture(txtLines)
%
% Input
%   txtLines - Usually thisR.world text
%
% Outputs
%   materialList - The material txtLines
%   textureList  - The texture txtLines
%   txtLines     -  The txtLines that are NOT material or textures
%
% ZL and ZYL
%
% See also
%

%% Initialize the parameters we return

texureList    = [];
materialList  = [];

% Counters for the textures and materials
t_index = 0;
m_index = 0;

%% Loop over each line
for ii = numel(txtLines):-1:1
    % From the end to the beginning so we don't screw up line ordering.
    
    % Parse this line now
    thisLine = txtLines{ii};
    
    if strncmp(thisLine,'Texture',length('Texture'))
        t_index = t_index+1;
        texureList{t_index}   = parseBlockTexture(thisLine);  %#ok<AGROW>
        txtLines(ii) = [];
        
    elseif strncmp(thisLine,'MakeNamedMaterial',length('MakeNamedMaterial')) ||...
            strncmp(thisLine,'Material',length('Material'))
        m_index = m_index+1;
        materialList{m_index}  = parseBlockMaterial(thisLine); %#ok<AGROW>
        txtLines(ii) = [];

    end
end

end