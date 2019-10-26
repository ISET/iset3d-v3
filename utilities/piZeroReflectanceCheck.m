function recipe = piZeroReflectanceCheck(recipe,varargin)
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
%
% Optional key/value pairs:
%   minReflectance     - Scalar. Minimum reflectance or RGB value.  Default
%                        0.03;
% See also
%   piRead, piWrite


% History:
%   Zhenyi, 2019
%

%% Parse input
p = inputParser;
p.addParameter('minReflectance',0.03,@isscalar);
p.parse(varargin{:});

%% Say hello
fprintf('Fixing very small reflectance values\n');

%% Set minimum reflectance
minReflVal = p.Results.minReflectance;

%% Figure out where recipe lives
[recipePath,recipeFile,recipeExt] = fileparts(recipe.inputFile);

%% Loop over all the materials
mlist = fieldnames(recipe.materials.list);
for ii = 1: length(mlist)
    % Grab current material
    thismaterial = recipe.materials.list.(mlist{ii});
    
    % Say hello
    fprintf('Material: %s\n',thismaterial.name);
    
    % Check and fix rgbKd, colorKd
    if (~isempty(thismaterial.colorkd))
        fprintf('\tMin color Kd: %g\n',min(thismaterial.colorkd));
        if any(thismaterial.colorkd < minReflVal)
            thismaterial.colorkd(thismaterial.colorkd < minReflVal) = minReflVal;
        end
    end
    
    if (~isempty(thismaterial.rgbkd))
        fprintf('\tMin color rgbkd: %g\n',min(thismaterial.rgbkd));
        if any(thismaterial.rgbkd < minReflVal)
            thismaterial.rgbkd(thismaterial.rgbkd < minReflVal) = minReflVal;
        end
    end
    
    % Check and fix diffuse SPD files
    if (~isempty(thismaterial.spectrumkd))
        fprintf('\tSpectrum file %s\n',thismaterial.spectrumkd);
        matrixData = piSpdFileRead(fullfile(recipePath,thismaterial.spectrumkd));
        temp = matrixData(:,2);
        fprintf('\t\tMin reflectance: %g\n',min(temp));
        if (any(temp < minReflVal))
            temp(temp < minReflVal) = minReflVal;
            matrixData(:,2) = temp;
            fprintf('\t\tWriting spectrum file %s\n',fullfile(recipePath,thismaterial.spectrumkd));
            piSpdFileWrite(matrixData,'outputFilename',fullfile(recipePath,thismaterial.spectrumkd));
        end
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
            writeFlag = false;
            uint8Flag = false;
            fprintf('\tReading %s%s\n',fileRoot,fileExt);
            texImg = imread(filename);
            if (isa(texImg,'uint8'))
                uint8Flag = true;
                texImg = double(texImg)/255;
            end
            [rows,cols,~] = size(texImg);
            minVal = Inf;
            for mm = 1:rows
                for nn = 1:cols
                    if (min(texImg(mm, nn, :)) < minVal)
                        minVal = min(texImg(mm, nn, :));
                    end
                    if any(texImg(mm, nn, :) < minReflVal)
                        temp = texImg(mm, nn, :);
                        temp(temp < minReflVal) = minReflVal;
                        texImg(mm, nn, :) = temp;
                        writeFlag = true;
                    end
                end
            end
            fprintf('\tMinimum value = %g\n',minVal);
            if (writeFlag)
                fprintf('\t\tWriting file %s\n',filename);
                if (uint8Flag)
                    texImg = uint8(texImg*255);
                end
                imwrite(texImg,filename);
            end
        else
            if (exist('importEXRImage') == 3)
                fprintf('\tReading EXR file %s\n',filename)
                writeFlag = false;
                [texImg, texChannelNames] = importEXRImage(filename);
                [rows,cols,~] = size(texImg);
                minVal = Inf;
                for mm = 1:rows
                    for nn = 1:cols
                        if (min(texImg(mm, nn, :)) < minVal)
                            minVal = min(texImg(mm, nn, :));
                        end
                        if any(texImg(mm, nn, :) < minReflVal)
                            temp = texImg(mm, nn, :);
                            temp(temp < minReflVal) = minReflVal;
                            texImg(mm, nn, :) = temp;
                            writeFlag = true;
                        end
                    end
                end
                fprintf('\tMinimum value = %g\n',minVal);
                if (writeFlag)
                    fprintf('\t\tWriting EXR file %s\n',filename);
                    exportEXRImage(filename, texImg, texChannelNames);
                end
            else
                fprintf('Skipping EXR file %s, because EXR read/write not available\n',filename);
            end
            
        end
    end
    
    % Put material back now that its been fixed up
    recipe.materials.list.(mlist{ii}) = thismaterial;
end
end