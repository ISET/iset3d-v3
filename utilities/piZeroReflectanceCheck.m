function recipe = piZeroReflectanceCheck(recipe)
% Check if there is zero reflectance for the materials of the objects
%
%    recipe = piZeroReflectanceCheck(recipe)
%
% Brief description:
%    We take a render recipe read from pbrt files as input. 
%    We return a modified render recipe.
%
% Inputs
%   recipe -  render recipe
%
%
% Output
%   recipe -  render recipe
%
% Zhenyi, 2019
%
% See also
%   piRead
%% First
mlist = fieldnames(recipe.materials.list);
for ii = 1: length(mlist)
    thismaterial = recipe.materials.list.(mlist{ii});
    % check rgbKd, colorKd
    if thismaterial.colorkd == 0
        thismaterial.colorkd = [0.0001 0.0001 0.0001];
    end
    if thismaterial.rgbkd == 0
        thismaterial.rgbkd = [0.0001 0.0001 0.0001];
    end
    if ~isempty(thismaterial.texturekd)
        tmpLine = recipe.materials.txtLines(piContains(recipe.materials.txtLines, thismaterial.texturekd));
        thisTexture = tmpLine{piContains(tmpLine, 'Texture ')};
        scenefolder = fileparts(recipe.inputFile);
        thisLine_tmp= strsplit(thisTexture,' ');
        thisLine_tmp = thisLine_tmp(~cellfun(@isempty,thisLine_tmp));
        for jj = 1:length(thisLine_tmp)
            if piContains(thisLine_tmp{jj},'filename')
                index = jj;
            end
        end
        texFile = strrep(thisLine_tmp{index+1},'"','');
        filename = fullfile(scenefolder, texFile);
        texImg = imread(filename);
        [rows,cols] = size(texImg);
        for mm = 1:rows
            for nn = 1:cols
                if texImg(mm, nn, :) == 0
                    texImg(mm, nn, :) = [0.0001 0.0001 0.0001];
                end
            end
        end
        imsave(texImg,filename);
    end 
    recipe.materials.list.(mlist{ii}) = thismaterial;
end
end