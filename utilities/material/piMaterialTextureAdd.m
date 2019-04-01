function thisR = piMaterialTextureAdd(renderRecipe,material, texture,varargin)
%% Add a texture to a material
% Required:
%         RenderRecipe;
%         Material: Name of a material;
%         Texture

%
% thisR = piMaterialTextureAdd(thisR,'frontplane','checkerboard','uscale',1024,'vscale',1024);

%%
p = inputParser;
% if length(varargin) > 1
%     for i = 1:length(varargin)
%         if ~(isnumeric(varargin{i}) | islogical(varargin{i}))
%             varargin{i} = ieParamFormat(varargin{i});
%         end
%     end
% else
%     
% end
varargin =ieParamFormat(varargin);
p.addRequired('renderRecipe',@(x)isequal(class(x),'recipe'));
p.addRequired('material',@ischar);
p.addRequired('texture',@ischar);
% p.addParameter('imagepath',@ischar);
p.addParameter('uscale',@isnumeric);
p.addParameter('vscale',@isnumeric);
p.addParameter('color1',[1 1 1],@isnumeric);
p.addParameter('color2',[0 0 0],@isnumeric);
p.parse(renderRecipe,material,texture,varargin{:});

thisR        = p.Results.renderRecipe;
materialName = p.Results.material;
texture      = p.Results.texture;
uscale       = p.Results.uscale;
vscale       = p.Results.vscale;
% imagepath    = p.Results.imagepath;
color1       = p.Results.color1;
color2       = p.Results.color2;

%%
switch texture
    case 'checkerboard'
        if isempty(find(piContains(thisR.materials.txtLines,'"checkerboard"'), 1)) &&...
                isempty(thisR.materials.list.(materialName).texturekd)
            checkerName = 'checker_1';
            thisTexLine = sprintf('Texture "%s" "spectrum" "checkerboard" "rgb tex1" [%f %f %f] "rgb tex2" [%f %f %f] "float uscale" [%d] "float vscale" [%d]',...
                checkerName,color1,color2,uscale,vscale);
            thisR.materials.txtLines{length(thisR.materials.txtLines)+1} = thisTexLine;

            thisR.materials.list.(materialName).texturekd = checkerName;
            thisR.materials.list.(materialName).rgbkd = [];
        else
            index = randi(100,1);
            checkerName = sprintf('checker_%d',index);
            thisTexLine = sprintf('Texture "%s" "spectrum" "checkerboard" "rgb tex1" [%f %f %f] "rgb tex2" [%f %f %f] "float uscale" [%d] "float vscale" [%d]',...
                checkerName,color1,color2,uscale,vscale);
            thisR.materials.txtLines{length(thisR.materials.txtLines)+1} = thisTexLine;

            thisR.materials.list.(materialName).texturekd = checkerName;
            thisR.materials.list.(materialName).rgbkd = [];
        end
    case 'dots'
        disp('Not Implemented yet.');
    case 'imagemap'
        disp('Not Implemented yet.');
end

end