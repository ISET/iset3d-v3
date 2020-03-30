function piTextureList(thisR)
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
textureNames = fieldnames(thisR.textures.list);

fprintf('--- Texture names ---\n');
for ii=1:numel(textureNames)
    thisTexture = textureNames{ii};
    fprintf('%d. eName: %s\n', ii, thisTexture);
end
fprintf('---------------------\n');

end