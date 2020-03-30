function thisR = piTextureDeleteBasis(thisR, textureIdx, varargin)
% Delete basis functions for a target texture

%% Parse input
p = inputParser;

p.addRequired('thisR');
p.addRequired('textureIdx', @isnumeric);
p.parse(thisR, textureIdx, varargin{:});

thisR = p.Results.thisR;
textureIdx = p.Results.textureIdx;

%%
textureNames = fieldnames(thisR.textures.list);

% Remove three basis functions
% basis one
basisOne = thisR.textures.list.(textureNames{textureIdx}).spectrumbasisone;
if exist(basisOne, 'file')
    delete(basisOne);
end
thisR.textures.list.(textureNames{textureIdx}).spectrumbasisone = '';

% basis two
basisTwo = thisR.textures.list.(textureNames{textureIdx}).spectrumbasistwo;
if exist(basisTwo, 'file')
    delete(basisTwo);
end
thisR.textures.list.(textureNames{textureIdx}).spectrumbasistwo = '';

% basis three
basisThree = thisR.textures.list.(textureNames{textureIdx}).spectrumbasisthree;
if exist(basisThree, 'file')
    delete(basisThree);
end
thisR.textures.list.(textureNames{textureIdx}).spectrumbasisthree = '';


end