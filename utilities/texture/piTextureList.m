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


fprintf('--- Texture names ---\n');
if isfield(thisR.textures, 'list')
    for ii=1:numel(thisR.textures.list)
        thisTexture = thisR.textures.list{ii};
        fprintf('%d. Name: %s\n', ii, thisTexture.name);
    end
end
fprintf('---------------------\n');

end