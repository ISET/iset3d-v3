function piTexturePrint(thisR)
% List texture names in recipe.
% This is just a temporary version.
% In the future we want to parse texture as material data.
%
% Inputs:
%   thisR   - recipe
%
% Outputs:
%   None
%
%
%
%%


fprintf('\n--- Texture names ---\n');
textureNames = thisR.get('texture', 'names');

for ii =1:numel(textureNames)
    rows{ii, :}  = num2str(ii);
    names{ii,:}  = textureNames{ii};
    format{ii,:} = thisR.textures.list(textureNames{ii}).format;
    types{ii,:}  = thisR.textures.list(textureNames{ii}).type;
end
T = table(categorical(names), categorical(format),categorical(types),'VariableNames',{'name','format', 'type'}, 'RowNames',rows);
disp(T);
fprintf('---------------------\n');

end