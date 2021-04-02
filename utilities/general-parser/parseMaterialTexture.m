function [materialList, texureList]=parseMaterialTexture(txtLines)
% Parse the txtLines to specify the materials and textures
%
% ZL and ZYL

%% Initialize the parameters we return

texureList    = [];
materialList  = [];
% Commenting this out, in the future we don't need the lines anymore.
% materialLines = [];
% textureLines  = [];

% Counters for the textures and materials
t_index = 0;
m_index = 0;

%% Loop over each line
for ii = 1:numel(txtLines)
    
    % Parse this line now
    thisLine = txtLines{ii};
    
    if strncmp(thisLine,'Texture',length('Texture'))
        t_index = t_index+1;
        texureList{t_index}   = parseBlockTexture(thisLine); 
        % textureLines{t_index} = thisLine;
        
    elseif strncmp(thisLine,'MakeNamedMaterial',length('MakeNamedMaterial')) ||...
            strncmp(thisLine,'Material',length('Material'))
        m_index = m_index+1;
        materialList{m_index}  = parseBlockMaterial(thisLine);
       % materialLines{m_index} = thisLine; 
        
    end
end

end