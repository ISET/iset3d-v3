function thisR = ...
    piMaterialTextureAdd(renderRecipe, material, texture, varargin)
% Add a texture to a material
%
% Syntax:
%   thisR = ...
%       piMaterialTextureAdd(renderRecipe, material, texture, [varargin])
%
% Description:
%    Add a texture to an existing material.
%
% Inputs:
%    renderRecipe - Object. A recipe object.
%    material     - String. The name of a material. Some options include
%    WallMaterial, FloorMaterial
%    texture      - String. Texture to add to the aforementioned material.
%                   The current options include:
%       checkerboard: A checkerboard pattern.
%       dots:         Not yet implemented.
%       image map:    Not yet implemented.
%
% Outputs:
%    thisR        - Object. A recipe object representing the modified
%                   recipe renderRecipe.
%
% Optional key/value pairs:
%    uscale       - Numeric. The number of repetitions along the U axis. No
%                   default provided.
%    vscale       - Numeric. The number of repetitions along the V axis. No
%                   default provided.
%    color1       - Matrix. A 1x3 Matrix representing the R, G, B color
%                   values for the first color. Default [1 1 1].
%    color2       - Matrix. A 1x3 Matrix representing the R, G, B color
%                   values for the second color. Default [0 0 0].
%

% History:
%    XX/XX/XX  XXX  Created
%    04/03/19  JNM  Documentation pass

%%
p = inputParser;
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}) | ...
                isobject(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin = ieParamFormat(varargin);
end
p.addRequired('renderRecipe', @(x)isequal(class(x), 'recipe'));
p.addRequired('material', @ischar);
p.addRequired('texture', @ischar);
% p.addParameter('imagepath', @ischar);
p.addParameter('uscale', @isnumeric);
p.addParameter('vscale', @isnumeric);
p.addParameter('color1', [1 1 1], @isnumeric);
p.addParameter('color2', [0 0 0], @isnumeric);
p.parse(renderRecipe, material, texture, varargin{:});

thisR = p.Results.renderRecipe;
materialName = p.Results.material;
texture = p.Results.texture;
uscale = p.Results.uscale;
vscale = p.Results.vscale;
% imagepath = p.Results.imagepath;
color1 = p.Results.color1;
color2 = p.Results.color2;

%%
switch texture
    case 'checkerboard'
        if isempty(find(piContains(thisR.materials.txtLines, ...
                '"checkerboard"'), 1)) && isempty(...
                thisR.materials.list.(materialName).texturekd)
            checkerName = 'checker_1';
            thisTexLine = sprintf(strcat('Texture "%s" "spectrum" "', ...
                'checkerboard" "rgb tex1" [%f %f %f] "rgb tex2" ', ...
                '[%f %f %f] "float uscale" [%d] "float vscale" [%d]'), ...
                checkerName, color1, color2, uscale, vscale);
            thisR.materials.txtLines{...
                length(thisR.materials.txtLines) + 1} = thisTexLine;

            thisR.materials.list.(materialName).texturekd = checkerName;
            thisR.materials.list.(materialName).rgbkd = [];
        else
            index = randi(100, 1);
            checkerName = sprintf('checker_%d', index);
            thisTexLine = sprintf(strcat('Texture "%s" "spectrum" ', ...
                '"checkerboard" "rgb tex1" [%f %f %f] "rgb tex2" ', ...
                '[%f %f %f] "float uscale" [%d] "float vscale" [%d]'), ...
                checkerName, color1, color2, uscale, vscale);
            thisR.materials.txtLines{...
                length(thisR.materials.txtLines) + 1} = thisTexLine;

            thisR.materials.list.(materialName).texturekd = checkerName;
            thisR.materials.list.(materialName).rgbkd = [];
        end
    case 'dots'
        disp('Not Implemented yet.');
    case 'imagemap'
        disp('Not Implemented yet.');
end

end