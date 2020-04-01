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
if isempty(thisR.textures.list)
    textureNames = {};
else
    textureNames = fieldnames(thisR.textures.list);
end
fprintf('--- Texture names ---\n');
for ii=1:numel(textureNames)
    thisTexture = textureNames{ii};
    fprintf('%d. Name: %s\n', ii, thisTexture);
end
fprintf('---------------------\n');

end