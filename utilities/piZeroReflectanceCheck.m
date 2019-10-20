function recipe = piZeroReflectanceCheck(recipe)
% Check if there is zero reflectance for the materials of the objects
%
% Synopsis:
%    recipe = piZeroReflectanceCheck(recipe)
%
% Description:
%    We take a render recipe read from pbrt files as input. 
%    We return a modified render recipe.
%
% Inputs:
%   recipe -  render recipe
%
% Outputs:
%   recipe -  render recipe
%
% Zhenyi, 2019
%
% See also
%   piRead, prWrite

%% Say hello
fprintf('Fixing very small reflectance values\n');

%% Set minimum reflectance
minReflVal = 0.01;

%% Loop over all the materials
mlist = fieldnames(recipe.materials.list);
for ii = 1: length(mlist)
    % Grab current material
    thismaterial = recipe.materials.list.(mlist{ii});
    
    % Check and fix rgbKd, colorKd
    if any(thismaterial.colorkd < minReflVal)
        thismaterial.colorkd(thismaterial.colorkd < minReflVal) = minReflVal;
    end
    if any(thismaterial.rgbkd < minReflVal)
        thismaterial.rgbkd(thismaterial.rgbkd < minReflVal) = minReflVal;
    end
    
    % Check if there is a spectral file
    if (~isempty(thismaterial.spectrumkd))
        % Need to find or write piSpdFileRead
        fprintf('\tNeed to handle spectrum files %s\n',thismaterial.spectrumkd);
        %piSpdFileWrite(  );
    end
    
    % If it's a texture map file, get file fix RGB values, and 
    if ~isempty(thismaterial.texturekd)
        % Parse out the file name
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
        
        % Need to figure out how to read/write exr files
        % For now just skip
        [~,fileRoot,fileExt] = fileparts(filename);
        if (~strcmpi(fileExt,'.exr'))
            fprintf('\tFixing %s%s\n',fileRoot,fileExt);
            texImg = imread(filename);
            [rows,cols,~] = size(texImg);
            for mm = 1:rows
                for nn = 1:cols
                    if any(texImg(mm, nn, :) == 0)
                        temp = texImg(mm, nn, :);
                        temp(temp < minReflVal) = minReflVal;
                        texImg(mm, nn, :) = temp;
                    end
                end
            end
            imwrite(texImg,filename);
        else
            fprintf('\tFigure out how to handle EXR files: %s\n',fileRoot)
        end
    end 
    
    % Put material back now that its been fixed up
    recipe.materials.list.(mlist{ii}) = thismaterial;
end
end